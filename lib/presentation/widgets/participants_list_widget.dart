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
  final VoidCallback onNudge;
  final bool isNudging;
  final bool hasAgents;
  final void Function(String) onRemoveParticipant;

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
    required this.onNudge,
    required this.isNudging,
    required this.hasAgents,
    required this.onRemoveParticipant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        border: Border(
          left: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _actionButton(
                  context,
                  icon: Icons.smart_toy,
                  label: 'Add AI Agents',
                  onTap: onAddAgent,
                ),
                _actionButton(
                  context,
                  icon: Icons.share,
                  label: 'Invite People',
                  onTap: onInvite,
                ),
                _actionButton(
                  context,
                  icon: Icons.add,
                  label: 'New Chat',
                  onTap: onNewChat,
                ),
                _actionButton(
                  context,
                  icon: Icons.description,
                  label: 'End & Summarize',
                  onTap: messagesCount > 0 ? onSummarize : null,
                ),
                _actionButton(
                  context,
                  icon: Icons.download,
                  label: 'Download',
                  onTap: messagesCount > 0 ? onDownload : null,
                ),
                _actionButton(
                  context,
                  icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  label: isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onTap: onToggleDarkMode,
                ),
              ],
            ),
          ),

          // Participants header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PARTICIPANTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Participants list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final p = participants[index];
                final isAgent = p.type == 'agent';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8),
                    leading: Stack(
                      children: [
                        AvatarWidget(
                          name: p.name,
                          isAgent: isAgent,
                          size: 32,
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
                                      : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.cardColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: isAgent
                        ? Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.model?.split('/').last ?? 'AI Agent',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (p.expertise != null)
                                Text(
                                  p.expertise!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          )
                        : Text(
                            'Human',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.status == 'typing')
                          Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () =>
                              onRemoveParticipant(p.id),
                          visualDensity: VisualDensity.compact,
                          color: Colors.red.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Nudge button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasAgents && !isNudging ? onNudge : null,
                icon: isNudging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.bolt),
                label: Text(isNudging ? 'Nudging...' : 'Nudge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.7)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
