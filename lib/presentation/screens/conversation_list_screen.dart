import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../providers/conversation_providers.dart';
import '../providers/theme_provider.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Melden',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Could not connect to server',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(conversationsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to start a new conversation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(conversationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final agents = conv.participants
                    .where((p) => p.type == 'agent')
                    .length;
                final humans = conv.participants
                    .where((p) => p.type == 'human')
                    .length;
                final lastMessage = conv.messages.isNotEmpty
                    ? conv.messages.last.content
                    : 'No messages yet';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    title: Text(
                      conv.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 2),
                            Text('$humans',
                                style: theme.textTheme.labelSmall),
                            const SizedBox(width: 10),
                            Icon(Icons.smart_toy, size: 14,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 2),
                            Text('$agents',
                                style: theme.textTheme.labelSmall),
                            const SizedBox(width: 10),
                            Icon(Icons.message, size: 14,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 2),
                            Text('${conv.messages.length}',
                                style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/join/${conv.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newId = const Uuid().v4();
          try {
            await ref
                .read(conversationRepoProvider)
                .createConversation(title: 'New Conversation');
            ref.invalidate(conversationsProvider);
          } catch (_) {
            // Even if server create fails, we can still join via WS
          }
          if (context.mounted) {
            context.push('/join/$newId');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }
}
