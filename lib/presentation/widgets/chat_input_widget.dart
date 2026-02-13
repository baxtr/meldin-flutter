import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message.dart';
import '../../data/models/websocket_message.dart';
import '../../data/services/websocket_service.dart';

class ChatInputWidget extends StatefulWidget {
  final WebSocketService wsService;
  final String conversationId;
  final String userId;
  final String userName;
  final bool isConnected;

  const ChatInputWidget({
    super.key,
    required this.wsService,
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.isConnected,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      id: const Uuid().v4(),
      content: text,
      senderId: widget.userId,
      senderName: widget.userName,
      senderType: 'human',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: widget.conversationId,
    );

    widget.wsService.send(WsMessageChat(message));
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.isConnected,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                maxLines: null,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: widget.isConnected ? _send : null,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
