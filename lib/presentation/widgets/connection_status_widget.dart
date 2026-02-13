import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import '../../data/services/websocket_service.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  final String conversationId;

  const ConnectionStatusWidget({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(connectionStatusProvider(conversationId));

    return statusAsync.when(
      loading: () => _dot(Colors.grey, 'Connecting'),
      error: (e, s) => _dot(Colors.red, 'Error'),
      data: (status) => switch (status) {
        ConnectionStatus.open => _dot(Colors.green, 'Connected'),
        ConnectionStatus.connecting => _dot(Colors.grey, 'Connecting'),
        ConnectionStatus.reconnecting =>
          _dot(Colors.orange, 'Reconnecting'),
        ConnectionStatus.closed => _dot(Colors.red, 'Disconnected'),
      },
    );
  }

  Widget _dot(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
