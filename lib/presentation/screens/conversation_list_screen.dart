import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/conversation_providers.dart';
import '../providers/theme_provider.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    try {
      final conv = await ref
          .read(conversationRepoProvider)
          .createConversation(title: 'New Conversation');
      ref.invalidate(localConversationsProvider);
      if (mounted) {
        context.push('/join/${conv.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to create conversation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(localConversationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/meldin-icon.png', height: 30),
            const SizedBox(width: 10),
            Text(
              'Meldin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 22,
            ),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: conversationsAsync.when(
        loading: () => _buildSkeletonList(theme, isDark),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_off_outlined,
                      size: 36, color: theme.colorScheme.error),
                ),
                const SizedBox(height: 20),
                Text(
                  'Could not connect',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(localConversationsProvider),
                  child: const Text('Try Again'),
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
                  Image.asset('assets/meldin-logo.png', height: 80),
                  const SizedBox(height: 20),
                  Text(
                    'No conversations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to start your first conversation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter conversations by search query
          final query = _searchController.text.toLowerCase();
          final filtered = conversations.where((c) {
            if (query.isEmpty) return true;
            if (c.title.toLowerCase().contains(query)) return true;
            if (c.messages.isNotEmpty &&
                c.messages.last.content
                    .toLowerCase()
                    .contains(query)) return true;
            return false;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(localConversationsProvider),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      prefixIcon:
                          const Icon(Icons.search, size: 20),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                // Conversation list
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No matching conversations',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              16, 8, 16, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final conv = filtered[index];
                            final agents = conv.participants
                                .where((p) => p.type == 'agent')
                                .length;
                            final humans = conv.participants
                                .where((p) => p.type == 'human')
                                .length;
                            final lastMessage =
                                conv.messages.isNotEmpty
                                    ? conv.messages.last.content
                                    : 'No messages yet';
                            final timeStr =
                                conv.messages.isNotEmpty
                                    ? _formatTime(conv
                                        .messages.last.timestamp)
                                    : '';

                            return Card(
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () => context
                                    .push('/join/${conv.id}'),
                                borderRadius:
                                    BorderRadius.circular(16),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              conv.title,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                fontSize: 15,
                                              ),
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                          if (timeStr.isNotEmpty)
                                            Text(
                                              timeStr,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(
                                                        alpha:
                                                            0.4),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        lastMessage,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: theme
                                              .colorScheme
                                              .onSurface
                                              .withValues(
                                                  alpha: 0.55),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _statChip(
                                              context,
                                              Icons
                                                  .person_outline,
                                              '$humans'),
                                          const SizedBox(
                                              width: 8),
                                          _statChip(
                                              context,
                                              Icons
                                                  .smart_toy_outlined,
                                              '$agents'),
                                          const SizedBox(
                                              width: 8),
                                          _statChip(
                                              context,
                                              Icons
                                                  .chat_bubble_outline,
                                              '${conv.messages.length}'),
                                          const Spacer(),
                                          Icon(
                                              Icons
                                                  .arrow_forward_ios,
                                              size: 14,
                                              color: theme
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(
                                                      alpha:
                                                          0.25)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createConversation,
        elevation: 2,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // --- Skeleton loading ---
  Widget _buildSkeletonList(ThemeData theme, bool isDark) {
    final baseColor =
        isDark ? const Color(0xFF252830) : const Color(0xFFE5E7EB);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(
      BuildContext context, IconData icon, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.35)),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
