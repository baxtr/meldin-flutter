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
    final theme = Theme.of(context);

    return statusAsync.when(
      loading: () => _badge(theme, Colors.grey, 'Connecting...', true),
      error: (e, s) => _badge(theme, Colors.red, 'Error', false),
      data: (status) => switch (status) {
        ConnectionStatus.open => _dot(Colors.green),
        ConnectionStatus.connecting =>
          _badge(theme, Colors.grey, 'Connecting...', true),
        ConnectionStatus.reconnecting =>
          _badge(theme, Colors.orange, 'Reconnecting...', true),
        ConnectionStatus.closed =>
          _badge(theme, Colors.red, 'Offline', false),
      },
    );
  }

  Widget _dot(Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(ThemeData theme, Color color, String label, bool animate) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 8,
              height: 8,
              child: animate
                  ? CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: color,
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
