import 'package:flutter/material.dart';
import '../../data/models/message.dart';
import 'avatar_widget.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isAnnouncement) return _buildAnnouncement(context);
    return _buildMessage(context);
  }

  Widget _buildAnnouncement(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                      const Color(0xFF312E81).withValues(alpha: 0.3),
                    ]
                  : [const Color(0xFFEFF6FF), const Color(0xFFEEF2FF)],
            ),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E40AF).withValues(alpha: 0.5)
                  : const Color(0xFFBFDBFE),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AvatarWidget(
                  name: message.senderName, isAgent: true, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            message.senderName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'joined',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (message.senderModel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Model: ${message.senderModel!.split('/').last}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (message.senderExpertise != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        message.senderExpertise!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAgent = message.senderType == 'agent';
    final time = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isAgent ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAgent) ...[
            AvatarWidget(
                name: message.senderName, isAgent: true, size: 32),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: isAgent
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isAgent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAgent
                          ? (isDark
                              ? const Color(0xFF1E3A5F).withValues(alpha: 0.5)
                              : const Color(0xFFDBEAFE))
                          : (isDark
                              ? const Color(0xFF166534)
                              : const Color(0xFF4ADE80)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isAgent
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isAgent) ...[
            const SizedBox(width: 10),
            AvatarWidget(
                name: message.senderName, isAgent: false, size: 32),
          ],
        ],
      ),
    );
  }
}
