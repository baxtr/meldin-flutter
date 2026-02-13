import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../config/app_config.dart';

class InviteDialog extends StatelessWidget {
  final String conversationId;

  const InviteDialog({super.key, required this.conversationId});

  String get _inviteUrl =>
      '${AppConfig.apiUrl.replaceFirst('http', 'https')}?c=$conversationId';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Invite People'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share this link to invite others:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              _inviteUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conversation ID: $conversationId',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _inviteUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link copied to clipboard')),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Share.share('Join my Meldin conversation: $_inviteUrl');
          },
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
        ),
      ],
    );
  }
}
