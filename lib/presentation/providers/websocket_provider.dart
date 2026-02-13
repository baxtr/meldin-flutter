import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/websocket_service.dart';

final wsServiceProvider =
    Provider.family.autoDispose<WebSocketService, String>(
  (ref, conversationId) {
    final service = WebSocketService(conversationId);
    ref.onDispose(() => service.dispose());
    return service;
  },
);

final connectionStatusProvider =
    StreamProvider.family.autoDispose<ConnectionStatus, String>(
  (ref, conversationId) {
    final service = ref.watch(wsServiceProvider(conversationId));
    return service.statusStream;
  },
);

final isConnectedProvider =
    Provider.family.autoDispose<bool, String>(
  (ref, conversationId) {
    final status = ref.watch(connectionStatusProvider(conversationId));
    return status.valueOrNull == ConnectionStatus.open;
  },
);
