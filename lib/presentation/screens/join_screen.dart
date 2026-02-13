import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../providers/websocket_provider.dart';
import '../../data/models/websocket_message.dart';
import '../../data/models/participant.dart';
import '../../data/services/websocket_service.dart';

class JoinScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const JoinScreen({super.key, required this.conversationId});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _nameController = TextEditingController();
  bool _autoJoined = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedSession());
  }

  void _checkSavedSession() {
    final session = ref.read(sessionProvider(widget.conversationId));
    if (session.hasJoined && session.userName.isNotEmpty) {
      _nameController.text = session.userName;
      _doJoin(session.userName);
    }
  }

  void _doJoin(String name) {
    if (name.trim().isEmpty) return;

    final session = ref.read(sessionProvider(widget.conversationId));
    ref.read(sessionProvider(widget.conversationId).notifier).join(name.trim());

    final wsService = ref.read(wsServiceProvider(widget.conversationId));
    wsService.send(WsJoin(Participant(
      id: session.userId,
      name: name.trim(),
      type: 'human',
      status: 'online',
    )));

    if (mounted) {
      context.go('/chat/${widget.conversationId}');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen(connectionStatusProvider(widget.conversationId), (prev, next) {
      next.whenData((status) {
        if (status == ConnectionStatus.open && !_autoJoined) {
          final session = ref.read(sessionProvider(widget.conversationId));
          if (session.hasJoined && session.userName.isNotEmpty) {
            _autoJoined = true;
            _doJoin(session.userName);
          }
        }
      });
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F1117), const Color(0xFF141720)]
                : [const Color(0xFFF0FDFA), const Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/meldin-logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Where humans and AI converse',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Join card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Join conversation',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Your name',
                                prefixIcon:
                                    Icon(Icons.person_outline, size: 20),
                              ),
                              textInputAction: TextInputAction.go,
                              autofocus: true,
                              onSubmitted: (_) =>
                                  _doJoin(_nameController.text),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _doJoin(_nameController.text),
                                child: const Text('Join'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Feature pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _featurePill(context, Icons.groups_outlined,
                            'Multi-agent AI'),
                        _featurePill(context, Icons.bolt_outlined,
                            'Real-time chat'),
                        _featurePill(context, Icons.psychology_outlined,
                            'Multiple models'),
                        _featurePill(context, Icons.people_outline,
                            'Collaborative'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featurePill(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
