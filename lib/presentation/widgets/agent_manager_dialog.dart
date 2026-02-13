import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/participant.dart';
import 'topic_suggestions_widget.dart';
import 'manual_agent_form_widget.dart';
import 'agent_presets_widget.dart';

enum _AgentMode { teams, generate, manual }

class AgentManagerDialog extends ConsumerStatefulWidget {
  final void Function(Participant agent) onAddAgent;
  final void Function(String topic)? onSetTopic;
  final String? initialTopic;

  const AgentManagerDialog({
    super.key,
    required this.onAddAgent,
    this.onSetTopic,
    this.initialTopic,
  });

  @override
  ConsumerState<AgentManagerDialog> createState() =>
      _AgentManagerDialogState();
}

class _AgentManagerDialogState extends ConsumerState<AgentManagerDialog> {
  _AgentMode _mode = _AgentMode.teams;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              // Title + close
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add AI Agents',
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
              // Mode selector
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252830)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _modeTab(
                      theme,
                      isDark,
                      icon: Icons.groups_outlined,
                      label: 'Teams',
                      selected: _mode == _AgentMode.teams,
                      onTap: () => setState(() => _mode = _AgentMode.teams),
                    ),
                    _modeTab(
                      theme,
                      isDark,
                      icon: Icons.auto_awesome_outlined,
                      label: 'AI Generate',
                      selected: _mode == _AgentMode.generate,
                      onTap: () =>
                          setState(() => _mode = _AgentMode.generate),
                    ),
                    _modeTab(
                      theme,
                      isDark,
                      icon: Icons.tune_outlined,
                      label: 'Manual',
                      selected: _mode == _AgentMode.manual,
                      onTap: () => setState(() => _mode = _AgentMode.manual),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modeTab(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? const Color(0xFF1A1D27) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface
                          .withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _AgentMode.teams:
        return AgentPresetsWidget(
          onSelectAgents: (agents) {
            for (final agent in agents) {
              widget.onAddAgent(agent);
            }
            Navigator.pop(context);
          },
          onSetTopic: widget.onSetTopic,
        );
      case _AgentMode.generate:
        return TopicSuggestionsWidget(
          initialTopic: widget.initialTopic,
          onSelectAgents: (agents) {
            for (final agent in agents) {
              widget.onAddAgent(agent);
            }
            Navigator.pop(context);
          },
          onSwitchToManual: () =>
              setState(() => _mode = _AgentMode.manual),
          onSetTopic: widget.onSetTopic,
        );
      case _AgentMode.manual:
        return ManualAgentFormWidget(
          onAddAgent: (agent) {
            widget.onAddAgent(agent);
            Navigator.pop(context);
          },
          onSwitchToTopic: () =>
              setState(() => _mode = _AgentMode.generate),
        );
    }
  }
}
