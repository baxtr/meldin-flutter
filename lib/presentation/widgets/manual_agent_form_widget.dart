import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_config.dart';
import '../../data/models/participant.dart';

class ManualAgentFormWidget extends StatefulWidget {
  final void Function(Participant agent) onAddAgent;
  final VoidCallback onSwitchToTopic;

  const ManualAgentFormWidget({
    super.key,
    required this.onAddAgent,
    required this.onSwitchToTopic,
  });

  @override
  State<ManualAgentFormWidget> createState() => _ManualAgentFormWidgetState();
}

class _ManualAgentFormWidgetState extends State<ManualAgentFormWidget> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  String _selectedModel = AppConfig.availableModels.first.id;
  double _temperature = 0.7;

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _submit() {
    final agent = Participant(
      id: const Uuid().v4(),
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Agent ${DateTime.now().millisecondsSinceEpoch}',
      type: 'agent',
      status: 'online',
      model: _selectedModel,
      systemPrompt: _promptController.text.trim().isNotEmpty
          ? _promptController.text.trim()
          : null,
      temperature: _temperature,
    );
    widget.onAddAgent(agent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                'Manual Setup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onSwitchToTopic,
              child: const Text('Generate from Topic'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Agent Name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Agent Name',
            hintText: 'e.g., Expert Analyst',
          ),
        ),
        const SizedBox(height: 16),

        // Model dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedModel,
          decoration: const InputDecoration(labelText: 'Model'),
          items: AppConfig.availableModels.map((m) {
            return DropdownMenuItem(value: m.id, child: Text(m.name));
          }).toList(),
          onChanged: (v) => setState(() => _selectedModel = v!),
        ),
        const SizedBox(height: 16),

        // System Prompt
        TextField(
          controller: _promptController,
          decoration: const InputDecoration(
            labelText: 'System Prompt (Optional)',
            hintText: "Define the agent's personality and expertise...",
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          minLines: 3,
        ),
        const SizedBox(height: 16),

        // Temperature slider
        Text(
          'Temperature: ${_temperature.toStringAsFixed(1)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: _temperature,
          min: 0,
          max: 1,
          divisions: 10,
          label: _temperature.toStringAsFixed(1),
          onChanged: (v) => setState(() => _temperature = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Focused',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                )),
            Text('Creative',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                )),
          ],
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Agent'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
