import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/participant.dart';
import 'topic_suggestions_widget.dart';
import 'manual_agent_form_widget.dart';

class AgentManagerDialog extends ConsumerStatefulWidget {
  final void Function(Participant agent) onAddAgent;
  final void Function(String topic)? onSetTopic;

  const AgentManagerDialog({
    super.key,
    required this.onAddAgent,
    this.onSetTopic,
  });

  @override
  ConsumerState<AgentManagerDialog> createState() =>
      _AgentManagerDialogState();
}

class _AgentManagerDialogState extends ConsumerState<AgentManagerDialog> {
  bool _showManual = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add AI Agent',
                      style: theme.textTheme.headlineSmall?.copyWith(
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
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _showManual
                      ? ManualAgentFormWidget(
                          onAddAgent: (agent) {
                            widget.onAddAgent(agent);
                            Navigator.pop(context);
                          },
                          onSwitchToTopic: () =>
                              setState(() => _showManual = false),
                        )
                      : TopicSuggestionsWidget(
                          onSelectAgents: (agents) {
                            for (final agent in agents) {
                              widget.onAddAgent(agent);
                            }
                            Navigator.pop(context);
                          },
                          onSwitchToManual: () =>
                              setState(() => _showManual = true),
                          onSetTopic: widget.onSetTopic,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
