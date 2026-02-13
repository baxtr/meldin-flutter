import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/conversation_providers.dart';

class SummaryDialog extends ConsumerStatefulWidget {
  final String conversationId;

  const SummaryDialog({super.key, required this.conversationId});

  @override
  ConsumerState<SummaryDialog> createState() => _SummaryDialogState();
}

class _SummaryDialogState extends ConsumerState<SummaryDialog> {
  bool _isLoading = true;
  String? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final summary = await ref
          .read(conversationRepoProvider)
          .generateSummary(widget.conversationId);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _summary = summary;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to generate summary. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Conversation Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Markdown(
                    data: _summary ?? '',
                    selectable: true,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_summary != null) ...[
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _summary!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Summary copied')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
