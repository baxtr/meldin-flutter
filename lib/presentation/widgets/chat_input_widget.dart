import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message.dart';
import '../../data/models/participant.dart';
import '../../data/models/websocket_message.dart';
import '../../data/services/websocket_service.dart';

class ChatInputWidget extends StatefulWidget {
  final WebSocketService wsService;
  final String conversationId;
  final String userId;
  final String userName;
  final bool isConnected;
  final List<Participant> participants;
  final void Function(String text)? onSendText;

  const ChatInputWidget({
    super.key,
    required this.wsService,
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.isConnected,
    this.participants = const [],
    this.onSendText,
  });

  @override
  State<ChatInputWidget> createState() => ChatInputWidgetState();
}

class ChatInputWidgetState extends State<ChatInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  // @ mention state
  final _layerLink = LayerLink();
  OverlayEntry? _mentionOverlay;
  String _mentionQuery = '';
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
    _checkMention();
  }

  void insertText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _focusNode.requestFocus();
  }

  void _checkMention() {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    if (cursor < 0 || cursor > text.length) {
      _hideMentionOverlay();
      return;
    }

    // Find the last @ before cursor
    int atIndex = -1;
    for (int i = cursor - 1; i >= 0; i--) {
      if (text[i] == '@') {
        // Only valid if at start or preceded by whitespace
        if (i == 0 || text[i - 1] == ' ' || text[i - 1] == '\n') {
          atIndex = i;
        }
        break;
      }
      // Stop if we hit whitespace (no @ in this "word")
      if (text[i] == ' ' || text[i] == '\n') break;
    }

    if (atIndex >= 0) {
      final query = text.substring(atIndex + 1, cursor).toLowerCase();
      _mentionStartIndex = atIndex;
      _mentionQuery = query;
      _showMentionOverlay();
    } else {
      _hideMentionOverlay();
    }
  }

  List<Participant> get _filteredParticipants {
    if (_mentionQuery.isEmpty) return widget.participants;
    return widget.participants
        .where((p) => p.name.toLowerCase().contains(_mentionQuery))
        .toList();
  }

  void _showMentionOverlay() {
    final filtered = _filteredParticipants;
    if (filtered.isEmpty) {
      _hideMentionOverlay();
      return;
    }

    _mentionOverlay?.remove();
    _mentionOverlay = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Positioned(
          width: 260,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, -8),
            followerAnchor: Alignment.bottomLeft,
            targetAnchor: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: isDark ? const Color(0xFF252830) : Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final isAgent = p.type == 'agent';
                      return InkWell(
                        onTap: () => _insertMention(p),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isAgent
                                      ? theme.colorScheme.primary
                                          .withValues(alpha: 0.12)
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    p.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isAgent
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isAgent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_mentionOverlay!);
  }

  void _insertMention(Participant p) {
    final text = _controller.text;
    final before = text.substring(0, _mentionStartIndex);
    final after = text.substring(_controller.selection.baseOffset);
    final newText = '$before@${p.name} $after';
    _controller.text = newText;
    final cursorPos = _mentionStartIndex + p.name.length + 2; // @Name + space
    _controller.selection = TextSelection.collapsed(offset: cursorPos);
    _hideMentionOverlay();
    _focusNode.requestFocus();
  }

  void _hideMentionOverlay() {
    _mentionOverlay?.remove();
    _mentionOverlay = null;
    _mentionStartIndex = -1;
    _mentionQuery = '';
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.onSendText != null) {
      widget.onSendText!(text);
    } else {
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
    }
    _controller.clear();
    _hideMentionOverlay();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _hideMentionOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canSend = widget.isConnected && _hasText;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
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
                          ? 'Message... (@ to mention)'
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
      ),
    );
  }
}
