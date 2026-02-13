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
    // Check for saved session after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedSession());
  }

  void _checkSavedSession() {
    final session = ref.read(sessionProvider(widget.conversationId));
    if (session.hasJoined && session.userName.isNotEmpty) {
      _nameController.text = session.userName;
      // Auto-rejoin
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
  Widget build(BuildContext context, ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for connection + auto-rejoin
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF111827), const Color(0xFF1F2937)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo placeholder
                        Icon(
                          Icons.forum_rounded,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Melden',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Where humans and AI converse',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Name input
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textInputAction: TextInputAction.go,
                          autofocus: true,
                          onSubmitted: (_) =>
                              _doJoin(_nameController.text),
                        ),
                        const SizedBox(height: 16),

                        // Join button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _doJoin(_nameController.text),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'Join Conversation',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Feature list
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _featureItem(
                                theme,
                                'Invite colleagues and add AI experts to dynamic group conversations',
                              ),
                              const SizedBox(height: 10),
                              _featureItem(
                                theme,
                                'Brainstorming sessions with diverse perspectives',
                              ),
                              const SizedBox(height: 10),
                              _featureItem(
                                theme,
                                'Expert panels where AI agents debate and collaborate',
                              ),
                              const SizedBox(height: 10),
                              _featureItem(
                                theme,
                                'Team problem solving with specialized AI consultants',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureItem(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
