import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/websocket_message.dart';
import '../../config/app_config.dart';

enum ConnectionStatus { connecting, open, reconnecting, closed }

class WebSocketService with WidgetsBindingObserver {
  final String conversationId;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  final _messageController = StreamController<WsMessage>.broadcast();

  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  Stream<WsMessage> get messageStream => _messageController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.connecting;
  ConnectionStatus get currentStatus => _currentStatus;

  bool _shouldReconnect = true;
  bool _isConnecting = false;
  int _reconnectAttempt = 0;
  int _recentHandshakeFailures = 0;
  bool _reconnectLock = false;

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _heartbeatTimer;
  Timer? _handshakeDecayTimer;

  DateTime _lastPong = DateTime.now();
  DateTime _lastAnyMessage = DateTime.now();
  String? _lastMessageId;

  final List<WsMessage> _outbox = [];
  StreamSubscription? _connectivitySub;

  WebSocketService(this.conversationId) {
    WidgetsBinding.instance.addObserver(this);
    _startConnectivityListener();
    connect();
    _startHeartbeat();
  }

  // ---------- Reconnect delay (port of useWebSocket.ts lines 34-41) ----------

  int _getReconnectDelay(int attempt, bool isTransient) {
    final basePow =
        isTransient ? min(attempt, 6) : max(4, min(attempt, 6));
    var delay = pow(2, basePow).toInt() * 1000;
    delay += Random().nextInt(1000);
    if (_recentHandshakeFailures >= 2) delay = max(delay, 30000);
    return delay;
  }

  static const _transientCodes = [0, 1001, 1005, 1006, 1012, 1013];

  // ---------- Connection ----------

  void connect() {
    if (!_shouldReconnect || _isConnecting) return;
    if (_channel != null) return;

    _setStatus(_reconnectAttempt > 0
        ? ConnectionStatus.reconnecting
        : ConnectionStatus.connecting);
    _isConnecting = true;

    final uri =
        Uri.parse('${AppConfig.wsUrl}?conversationId=$conversationId');

    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _isConnecting = false;
      _recentHandshakeFailures++;
      _scheduleHandshakeDecay();
      _scheduleReconnect(0);
      return;
    }

    _channelSub = _channel!.stream.listen(
      _onData,
      onError: (Object error) {
        _recentHandshakeFailures++;
        _scheduleHandshakeDecay();
        _isConnecting = false;
      },
      onDone: () {
        final code = _channel?.closeCode ?? 0;
        _isConnecting = false;
        _stopPings();
        _channel = null;
        _channelSub = null;
        _setStatus(ConnectionStatus.closed);

        if (_shouldReconnect) {
          _scheduleReconnect(code);
        }
      },
    );

    // WebSocketChannel.connect doesn't have an onopen callback.
    // The channel is considered open once the stream starts delivering data.
    // We handle "open" state on first successful data or via a ready future.
    _channel!.ready.then((_) {
      _isConnecting = false;
      _setStatus(ConnectionStatus.open);
      _reconnectAttempt = 0;
      _recentHandshakeFailures = 0;
      _lastPong = DateTime.now();

      // Send resume
      send(WsResume(conversationId, _lastMessageId));
      _startPings();
      _flushOutbox();
    }).catchError((_) {
      _isConnecting = false;
      _recentHandshakeFailures++;
      _scheduleHandshakeDecay();
      _channel = null;
      _channelSub?.cancel();
      _channelSub = null;
      _scheduleReconnect(0);
    });
  }

  void _onData(dynamic data) {
    _lastAnyMessage = DateTime.now();

    WsMessage msg;
    try {
      msg = WsMessage.decode(data as String);
    } catch (_) {
      return;
    }

    if (msg is WsPong) {
      _lastPong = DateTime.now();
      return;
    }

    _messageController.add(msg);

    if (msg is WsMessageChat) {
      _lastMessageId = msg.payload.id;
    }
  }

  // ---------- Send ----------

  void send(WsMessage message) {
    if (_currentStatus == ConnectionStatus.open && _channel != null) {
      try {
        _channel!.sink.add(message.encode());
      } catch (_) {
        _outbox.add(message);
      }
    } else {
      _outbox.add(message);
    }
  }

  void _flushOutbox() {
    if (_currentStatus != ConnectionStatus.open || _channel == null) return;
    for (final msg in _outbox) {
      try {
        _channel!.sink.add(msg.encode());
      } catch (_) {
        break;
      }
    }
    _outbox.clear();
  }

  // ---------- Ping / Pong ----------

  void _startPings() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentStatus == ConnectionStatus.open && _channel != null) {
        try {
          _channel!.sink.add(WsPing().encode());
        } catch (_) {}

        if (DateTime.now().difference(_lastPong).inSeconds > 10) {
          // No pong for >10s — likely dead connection
          _closeAndReconnect();
        }
      }
    });
  }

  void _stopPings() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // ---------- Reconnection ----------

  void _scheduleReconnect(int closeCode) {
    if (!_shouldReconnect) return;
    final isTransient = _transientCodes.contains(closeCode);
    final delay = _getReconnectDelay(_reconnectAttempt, isTransient);
    _setStatus(ConnectionStatus.reconnecting);
    _reconnectAttempt++;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      _channel = null;
      _channelSub = null;
      connect();
    });
  }

  void _reconnectNow() {
    if (_reconnectLock) return;
    _reconnectLock = true;

    _closeChannel();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnecting = false;
    _reconnectAttempt = 0;
    connect();

    Timer(const Duration(milliseconds: 250), () {
      _reconnectLock = false;
    });
  }

  void _closeAndReconnect() {
    _closeChannel();
    _reconnectNow();
  }

  void _closeChannel() {
    _stopPings();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channelSub?.cancel();
    _channel = null;
    _channelSub = null;
  }

  // ---------- Heartbeat safety net ----------

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_shouldReconnect &&
          _currentStatus != ConnectionStatus.open &&
          !_isConnecting) {
        _reconnectTimer?.cancel();
        connect();
      }
    });
  }

  // ---------- Connectivity ----------

  void _startConnectivityListener() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection =
          results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        _validateOrReconnect();
      } else {
        _setStatus(ConnectionStatus.closed);
        _stopPings();
      }
    });
  }

  void _validateOrReconnect() {
    if (_currentStatus != ConnectionStatus.open) {
      _reconnectNow();
      return;
    }
    // Send a ping and check for response
    final started = DateTime.now();
    _lastPong = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      _channel?.sink.add(WsPing().encode());
    } catch (_) {}

    Timer(const Duration(milliseconds: 1500), () {
      final pongFresh = _lastPong.isAfter(started);
      final trafficFresh =
          DateTime.now().difference(_lastAnyMessage).inMilliseconds < 2000;
      if (!pongFresh && !trafficFresh) {
        _closeAndReconnect();
      }
    });
  }

  // ---------- App lifecycle ----------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startPings();
        _validateOrReconnect();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _stopPings();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _closeChannel();
    }
  }

  // ---------- Helpers ----------

  void _setStatus(ConnectionStatus s) {
    _currentStatus = s;
    if (!_statusController.isClosed) {
      _statusController.add(s);
    }
  }

  void _scheduleHandshakeDecay() {
    _handshakeDecayTimer?.cancel();
    _handshakeDecayTimer = Timer(const Duration(seconds: 60), () {
      _recentHandshakeFailures = 0;
    });
  }

  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _heartbeatTimer?.cancel();
    _handshakeDecayTimer?.cancel();
    _connectivitySub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _closeChannel();
    _statusController.close();
    _messageController.close();
  }
}
