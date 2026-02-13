import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

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

    HapticFeedback.lightImpact();
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
    final isDark = theme.brightness == Brightness.dark;
    final canSend = widget.isConnected && _hasText;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252830)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.isConnected,
                  decoration: InputDecoration(
                    hintText: widget.isConnected
                        ? 'Message...'
                        : 'Connecting...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: canSend
                    ? theme.colorScheme.primary
                    : (isDark
                        ? const Color(0xFF252830)
                        : const Color(0xFFE5E7EB)),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canSend ? _send : null,
                  borderRadius: BorderRadius.circular(22),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: canSend
                        ? Colors.white
                        : (isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF)),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
