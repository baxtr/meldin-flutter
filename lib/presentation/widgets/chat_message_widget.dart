import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../data/models/message.dart';
import 'avatar_widget.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final bool showHeader;
  final bool isBookmarked;
  final void Function(String messageId)? onToggleBookmark;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.isOwnMessage = false,
    this.showHeader = true,
    this.isBookmarked = false,
    this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isAnnouncement) return _buildAnnouncement(context);
    return _buildMessage(context);
  }

  void _showMessageActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
              title: Text(isBookmarked ? 'Remove bookmark' : 'Bookmark'),
              onTap: () {
                Navigator.pop(ctx);
                onToggleBookmark?.call(message.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(ctx);
                Share.share('${message.senderName}: ${message.content}');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncement(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            AvatarWidget(name: message.senderName, isAgent: true, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          message.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'joined',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (message.senderModel != null ||
                      message.senderExpertise != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (message.senderModel != null)
                          message.senderModel!.split('/').last,
                        if (message.senderExpertise != null)
                          message.senderExpertise!,
                      ].join(' \u00B7 '),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
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
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    if (isOwnMessage) {
      return _buildOwnMessage(context, theme, isDark, timeStr);
    }

    return GestureDetector(
      onLongPress: () => _showMessageActions(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: showHeader ? 10 : 2,
          bottom: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              AvatarWidget(
                name: message.senderName,
                isAgent: isAgent,
                size: 34,
              )
            else
              const SizedBox(width: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader) ...[
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAgent) ...[
                          const SizedBox(width: 6),
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
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        if (isBookmarked) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.bookmark_rounded,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Render markdown for agent messages, plain text for humans
                  if (isAgent)
                    MarkdownBody(
                      data: message.content,
                      selectable: false,
                      styleSheet: _markdownStyle(theme, isDark),
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.88),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnMessage(
      BuildContext context, ThemeData theme, bool isDark, String timeStr) {
    return GestureDetector(
      onLongPress: () => _showMessageActions(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: 64,
          right: 16,
          top: showHeader ? 6 : 2,
          bottom: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showHeader) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBookmarked) ...[
                          Icon(
                            Icons.bookmark_rounded,
                            size: 12,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          message.senderName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: Radius.circular(showHeader ? 18 : 12),
                        bottomLeft: const Radius.circular(18),
                        bottomRight: const Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(ThemeData theme, bool isDark) {
    final textColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.88);
    final codeBackground =
        isDark ? const Color(0xFF1E2030) : const Color(0xFFF3F4F6);
    final codeBorder =
        isDark ? const Color(0xFF2A2D37) : const Color(0xFFE5E7EB);

    return MarkdownStyleSheet(
      p: TextStyle(fontSize: 15, height: 1.5, color: textColor),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      em: const TextStyle(fontStyle: FontStyle.italic),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: textColor,
        backgroundColor: codeBackground,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: codeBorder),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      h1: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1.3),
      h2: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1.3),
      h3: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.4),
      h4: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
      h5: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      h6: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
      ),
      blockquotePadding:
          const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      blockquote: TextStyle(
        fontSize: 15,
        height: 1.5,
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      listBullet: TextStyle(fontSize: 15, color: textColor),
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor:
            theme.colorScheme.primary.withValues(alpha: 0.4),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      ),
      tableHead: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      tableBody: TextStyle(fontSize: 14, color: textColor),
      tableBorder: TableBorder.all(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      ),
      blockSpacing: 8,
    );
  }
}
