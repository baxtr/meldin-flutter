import 'package:flutter/material.dart';
import '../../data/models/participant.dart';
import 'avatar_widget.dart';

class ParticipantsListWidget extends StatelessWidget {
  final List<Participant> participants;
  final VoidCallback onAddAgent;
  final VoidCallback onInvite;
  final VoidCallback onNewChat;
  final VoidCallback onSummarize;
  final VoidCallback onDownload;
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;
  final int messagesCount;
  final bool hasAgents;
  final void Function(String) onRemoveParticipant;
  final int bookmarkCount;
  final VoidCallback? onShowBookmarks;
  final VoidCallback? onChatHistory;

  const ParticipantsListWidget({
    super.key,
    required this.participants,
    required this.onAddAgent,
    required this.onInvite,
    required this.onNewChat,
    required this.onSummarize,
    required this.onDownload,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.messagesCount,
    required this.hasAgents,
    required this.onRemoveParticipant,
    this.bookmarkCount = 0,
    this.onShowBookmarks,
    this.onChatHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark
                ? const Color(0xFF2A2D37)
                : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Action buttons — vertical full-width list
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Column(
              children: [
                _actionButton(context, Icons.smart_toy_outlined,
                    'Add AI Agents', onAddAgent),
                _actionButton(context, Icons.person_add_outlined,
                    'Invite People', onInvite),
                _actionButton(context, Icons.add_comment_outlined,
                    'New Chat', onNewChat),
                _actionButton(context, Icons.history,
                    'Chat History', onChatHistory),
                if (messagesCount > 0) ...[
                  _actionButton(context, Icons.summarize_outlined,
                      'Summarize', onSummarize),
                  _actionButton(context, Icons.download_outlined,
                      'Export', onDownload),
                ],
                if (bookmarkCount > 0)
                  _actionButton(
                    context,
                    Icons.bookmark_rounded,
                    'Bookmarks ($bookmarkCount)',
                    onShowBookmarks,
                    iconColor: Colors.amber.shade600,
                  ),
                _actionButton(
                  context,
                  isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onToggleDarkMode,
                ),
              ],
            ),
          ),

          // Participants header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'PARTICIPANTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${participants.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Participants list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final p = participants[index];
                final isAgent = p.type == 'agent';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            // Avatar with status dot
                            Stack(
                              children: [
                                AvatarWidget(
                                  name: p.name,
                                  isAgent: isAgent,
                                  size: 34,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: p.status == 'typing'
                                          ? Colors.amber
                                          : p.status == 'online'
                                              ? Colors.green
                                              : const Color(0xFF6B7280),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF1A1D27)
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Name + details
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color:
                                          theme.colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  if (isAgent) ...[
                                    Text(
                                      p.model?.split('/').last ??
                                          'AI Agent',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            theme.colorScheme.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (p.expertise != null &&
                                        p.expertise!.isNotEmpty)
                                      Text(
                                        p.expertise!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme
                                              .colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                  ] else
                                    Text(
                                      'Human',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme
                                            .colorScheme.onSurface
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Typing or remove
                            if (p.status == 'typing')
                              Text(
                                'typing...',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.7),
                                ),
                              )
                            else
                              IconButton(
                                icon: Icon(Icons.close,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.25)),
                                onPressed: () =>
                                    onRemoveParticipant(p.id),
                                visualDensity: VisualDensity.compact,
                                splashRadius: 16,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap, {
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: onTap != null ? 1.0 : 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: iconColor ??
                        theme.colorScheme.onSurface
                            .withValues(alpha: 0.6)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
