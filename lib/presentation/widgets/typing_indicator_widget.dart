import 'package:flutter/material.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final String participantName;

  const TypingIndicatorWidget({super.key, required this.participantName});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) controller.repeat(reverse: true);
      });
      return controller;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _controllers[i],
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.2 + _controllers[i].value * 0.4,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.participantName} is typing...',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
