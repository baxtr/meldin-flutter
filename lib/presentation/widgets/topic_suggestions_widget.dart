import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/participant.dart';
import '../providers/agent_providers.dart';

class TopicSuggestionsWidget extends ConsumerStatefulWidget {
  final void Function(List<Participant> agents) onSelectAgents;
  final VoidCallback onSwitchToManual;
  final void Function(String topic)? onSetTopic;

  const TopicSuggestionsWidget({
    super.key,
    required this.onSelectAgents,
    required this.onSwitchToManual,
    this.onSetTopic,
  });

  @override
  ConsumerState<TopicSuggestionsWidget> createState() =>
      _TopicSuggestionsWidgetState();
}

class _TopicSuggestionsWidgetState
    extends ConsumerState<TopicSuggestionsWidget> {
  final _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _topicController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(agentSuggestionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with switch
        Row(
          children: [
            Expanded(
              child: Text(
                'Generate AI Participants from Topic',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onSwitchToManual,
              child: const Text('Manual Setup'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Topic input
        TextField(
          controller: _topicController,
          decoration: const InputDecoration(
            labelText: 'Meeting Topic',
            hintText:
                "e.g., 'Building a sustainable energy startup'",
          ),
          maxLines: 3,
          minLines: 2,
          enabled: !state.isLoading,
        ),
        const SizedBox(height: 12),

        // Generate button
        ElevatedButton(
          onPressed: state.isLoading ||
                  _topicController.text.trim().isEmpty
              ? null
              : () {
                  ref
                      .read(agentSuggestionProvider.notifier)
                      .generateSuggestions(_topicController.text.trim());
                },
          child: Text(
            state.isLoading
                ? 'Generating Suggestions...'
                : 'Generate AI Participants',
          ),
        ),

        // Add selected button (above suggestions)
        if (state.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: state.selectedIds.isEmpty
                ? null
                : () {
                    final selected = state.suggestions
                        .where(
                            (a) => state.selectedIds.contains(a.id))
                        .toList();
                    widget.onSetTopic
                        ?.call(_topicController.text.trim());
                    widget.onSelectAgents(selected);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: Text(
              'Add ${state.selectedIds.length} Selected Agent${state.selectedIds.length != 1 ? "s" : ""}',
            ),
          ),
        ],

        // Error
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color:
                      theme.colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Text(
              state.error!,
              style:
                  TextStyle(color: theme.colorScheme.error, fontSize: 13),
            ),
          ),
        ],

        // Suggestions list
        if (state.suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 8),
          Text(
            'Suggested AI Participants (${state.suggestions.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...state.suggestions.map((agent) {
            final isSelected = state.selectedIds.contains(agent.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => ref
                    .read(agentSuggestionProvider.notifier)
                    .toggleAgent(agent.id),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => ref
                            .read(agentSuggestionProvider.notifier)
                            .toggleAgent(agent.id),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Model: ${agent.model?.split("/").last ?? "Unknown"}',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            if (agent.expertise != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                agent.expertise!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                            if (agent.systemPrompt != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  agent.systemPrompt!,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          }),
        ],
      ],
    );
  }
}
