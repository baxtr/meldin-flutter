import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/session_provider.dart';
import '../providers/websocket_provider.dart';
import '../providers/chat_providers.dart';
import '../providers/conversation_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/participants_list_widget.dart';
import '../widgets/agent_manager_dialog.dart';
import '../widgets/invite_dialog.dart';
import '../widgets/summary_dialog.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/connection_status_widget.dart';
import '../../data/models/websocket_message.dart';
import '../../data/models/participant.dart';
import '../../data/models/message.dart';
import '../../data/services/websocket_service.dart';
import '../../utils/message_formatter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _inputKey = GlobalKey<ChatInputWidgetState>();
  String? _meetingTopic;
  bool _showScrollToBottom = false;
  int _unreadCount = 0;
  final Set<String> _bookmarkedIds = {};
  bool _showBookmarks = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.position.maxScrollExtent -
            _scrollController.offset <
        100;
    if (_showScrollToBottom == atBottom) {
      setState(() {
        _showScrollToBottom = !atBottom;
        if (atBottom) _unreadCount = 0;
      });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    setState(() => _unreadCount = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _handleAddAgent(Participant agent) {
    final wsService = ref.read(wsServiceProvider(widget.conversationId));
    wsService.send(WsJoin(agent));
  }

  void _handleRemoveParticipant(String participantId) {
    final wsService = ref.read(wsServiceProvider(widget.conversationId));
    wsService.send(WsLeave(participantId));
  }

  Future<void> _handleSummarize() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => SummaryDialog(
        conversationId: widget.conversationId,
      ),
    );
  }

  Future<void> _handleDownload() async {
    final messages = ref.read(messagesProvider(widget.conversationId));
    final participants =
        ref.read(participantsProvider(widget.conversationId));

    final content = formatConversationForDownload(
      title: 'Meldin Conversation',
      messages: messages,
      participants: participants,
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/meldin-${widget.conversationId.substring(0, 8)}.txt');
    await file.writeAsString(content);

    await Share.shareXFiles([XFile(file.path)]);
  }

  void _handleNewChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start New Chat?'),
        content: const Text(
          'This will leave the current conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(sessionProvider(widget.conversationId).notifier)
                  .clearSession();
              context.go('/');
            },
            child: const Text('New Chat'),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(String messageId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_bookmarkedIds.contains(messageId)) {
        _bookmarkedIds.remove(messageId);
      } else {
        _bookmarkedIds.add(messageId);
      }
    });
  }

  void _showBookmarksSheet() {
    final messages = ref.read(messagesProvider(widget.conversationId));
    final bookmarked =
        messages.where((m) => _bookmarkedIds.contains(m.id)).toList();
    final session = ref.read(sessionProvider(widget.conversationId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                  Row(
                    children: [
                      Icon(Icons.bookmark_rounded,
                          color: Colors.amber.shade600, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bookmarks (${bookmarked.length})',
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: bookmarked.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 48,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No bookmarks yet',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Long-press any message to bookmark it',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: bookmarked.length,
                            itemBuilder: (context, index) {
                              final msg = bookmarked[index];
                              return ChatMessageWidget(
                                message: msg,
                                isOwnMessage:
                                    msg.senderId == session.userId,
                                isBookmarked: true,
                                onToggleBookmark: (id) {
                                  _toggleBookmark(id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Quick action prompts ---
  static const _quickActions = [
    _QuickAction(Icons.forum_outlined, 'Debate this', 'Let\'s have a structured debate about this. Each of you take a different position and argue your case.'),
    _QuickAction(Icons.lightbulb_outline, 'Brainstorm', 'Let\'s brainstorm creative ideas. Think outside the box and build on each other\'s suggestions.'),
    _QuickAction(Icons.compare_arrows, 'Compare', 'Compare and contrast the different approaches or perspectives discussed so far. What are the trade-offs?'),
    _QuickAction(Icons.psychology_outlined, 'Challenge', 'Challenge the assumptions being made. What are we getting wrong? Play devil\'s advocate.'),
    _QuickAction(Icons.school_outlined, 'Explain simply', 'Explain this in simple terms that anyone could understand. Use analogies and examples.'),
    _QuickAction(Icons.groups_outlined, 'Everyone reply', 'I\'d like to hear from each of you. Everyone please share your perspective.'),
    _QuickAction(Icons.checklist, 'Action items', 'Summarize the key takeaways and create a list of actionable next steps from this discussion.'),
    _QuickAction(Icons.trending_up, 'Go deeper', 'Let\'s go deeper on this topic. What are the second-order effects and implications we haven\'t explored?'),
  ];

  void _sendQuickAction(String text) {
    final session = ref.read(sessionProvider(widget.conversationId));
    final wsService = ref.read(wsServiceProvider(widget.conversationId));
    final message = Message(
      id: const Uuid().v4(),
      content: text,
      senderId: session.userId,
      senderName: session.userName,
      senderType: 'human',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: widget.conversationId,
    );
    HapticFeedback.lightImpact();
    wsService.send(WsMessageChat(message));
  }

  // --- Message grouping ---
  bool _shouldShowHeader(List<Message> messages, int index) {
    if (index == 0) return true;
    final msg = messages[index];
    final prev = messages[index - 1];
    if (msg.isAnnouncement || prev.isAnnouncement) return true;
    if (msg.senderId != prev.senderId) return true;
    if (msg.timestamp - prev.timestamp > 120000) return true; // 2 min gap
    return false;
  }

  // --- Date separators ---
  bool _isSameDay(int ts1, int ts2) {
    final d1 = DateTime.fromMillisecondsSinceEpoch(ts1);
    final d2 = DateTime.fromMillisecondsSinceEpoch(ts2);
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _dateSeparator(BuildContext context, int timestamp) {
    final theme = Theme.of(context);
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;

    String label;
    if (diff == 0) {
      label = 'Today';
    } else if (diff == 1) {
      label = 'Yesterday';
    } else if (diff < 7) {
      label = DateFormat('EEEE').format(date);
    } else {
      label = DateFormat('MMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.35),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider(widget.conversationId));
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final participants =
        ref.watch(participantsProvider(widget.conversationId));
    final isConnected =
        ref.watch(isConnectedProvider(widget.conversationId));
    final wsService = ref.watch(wsServiceProvider(widget.conversationId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 768;

    // Auto-rejoin on reconnect
    ref.listen(connectionStatusProvider(widget.conversationId), (prev, next) {
      next.whenData((status) {
        if (status == ConnectionStatus.open &&
            session.hasJoined &&
            session.userName.isNotEmpty) {
          wsService.send(WsJoin(Participant(
            id: session.userId,
            name: session.userName,
            type: 'human',
            status: 'online',
          )));
        }
      });
    });

    // Scroll to bottom on new messages (or increment unread count)
    ref.listen(messagesProvider(widget.conversationId), (prev, next) {
      if (prev != null && next.length > prev.length) {
        if (_showScrollToBottom) {
          setState(
              () => _unreadCount += next.length - prev.length);
        } else {
          _scrollToBottom();
        }
      }
    });

    final typingParticipants =
        participants.where((p) => p.status == 'typing').toList();
    final hasAgents = participants.any((p) => p.type == 'agent');

    Widget sidebar = ParticipantsListWidget(
      participants: participants,
      onAddAgent: () => _showAgentManager(),
      onInvite: () => _showInviteDialog(),
      onNewChat: _handleNewChat,
      onSummarize: _handleSummarize,
      onDownload: _handleDownload,
      onToggleDarkMode: () =>
          ref.read(themeModeProvider.notifier).toggle(),
      isDarkMode: isDark,
      messagesCount: messages.length,
      onRemoveParticipant: _handleRemoveParticipant,
      hasAgents: hasAgents,
      bookmarkCount: _bookmarkedIds.length,
      onShowBookmarks: _showBookmarksSheet,
      onChatHistory: () => context.push('/history'),
    );

    Widget chatArea = Column(
      children: [
        // Meeting topic banner
        if (_meetingTopic != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              border: Border(
                bottom: BorderSide(
                  color:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _meetingTopic!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Messages
        Expanded(
          child: Stack(
            children: [
              messages.isEmpty
                  ? _buildEmptyState(theme, hasAgents)
                  : ListView.builder(
                      controller: _scrollController,
                      padding:
                          const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: messages.length +
                          typingParticipants.length,
                      itemBuilder: (context, index) {
                        if (index < messages.length) {
                          final msg = messages[index];
                          final showDate = index == 0 ||
                              !_isSameDay(
                                messages[index - 1].timestamp,
                                msg.timestamp,
                              );
                          final showHeader =
                              _shouldShowHeader(messages, index);

                          return Column(
                            children: [
                              if (showDate)
                                _dateSeparator(
                                    context, msg.timestamp),
                              ChatMessageWidget(
                                message: msg,
                                isOwnMessage:
                                    msg.senderId == session.userId,
                                showHeader: showHeader,
                                isBookmarked:
                                    _bookmarkedIds.contains(msg.id),
                                onToggleBookmark: _toggleBookmark,
                              ),
                            ],
                          );
                        }
                        final tp = typingParticipants[
                            index - messages.length];
                        return TypingIndicatorWidget(
                            participantName: tp.name);
                      },
                    ),
              // Scroll to bottom FAB with unread badge
              if (_showScrollToBottom)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _scrollToBottom(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF252830)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                _unreadCount > 99
                                    ? '99+'
                                    : '$_unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Quick Actions Bar
        if (hasAgents && messages.isNotEmpty)
          _buildQuickActionsBar(theme, isDark),
        // Input
        ChatInputWidget(
          key: _inputKey,
          wsService: wsService,
          conversationId: widget.conversationId,
          userId: session.userId,
          userName: session.userName,
          isConnected: isConnected,
          participants: participants,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/meldin-logo.png', height: 26),
            const SizedBox(width: 8),
            Text(
              'Meldin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          ConnectionStatusWidget(
              conversationId: widget.conversationId),
          if (!isWide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
        ],
      ),
      endDrawer: isWide
          ? null
          : Drawer(
              width: 300,
              child: SafeArea(child: sidebar),
            ),
      body: isWide
          ? Row(
              children: [
                Expanded(child: chatArea),
                SizedBox(width: 300, child: sidebar),
              ],
            )
          : chatArea,
    );
  }

  Widget _buildQuickActionsBar(ThemeData theme, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1D27)
            : const Color(0xFFFAFAFB),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final action = _quickActions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _sendQuickAction(action.prompt),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action.icon,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      action.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool hasAgents) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/meldin-logo.png', height: 80),
            const SizedBox(height: 20),
            Text(
              hasAgents
                  ? 'Start the conversation'
                  : 'Set up your conversation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAgents
                  ? 'Send a message to begin chatting with the AI agents'
                  : 'Add AI agents or invite people to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasAgents) ...[
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAgentManager(),
                    icon:
                        const Icon(Icons.smart_toy_outlined, size: 18),
                    label: const Text('Add AI Agents'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showInviteDialog(),
                    icon: const Icon(Icons.person_add_outlined,
                        size: 18),
                    label: const Text('Invite'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAgentManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AgentManagerDialog(
        onAddAgent: _handleAddAgent,
        onSetTopic: (topic) {
          setState(() => _meetingTopic = topic);
          // Update conversation title on the server
          ref.read(conversationRepoProvider).updateTitle(
                widget.conversationId,
                topic,
              );
        },
        initialTopic: _meetingTopic,
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (_) =>
          InviteDialog(conversationId: widget.conversationId),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String prompt;
  const _QuickAction(this.icon, this.label, this.prompt);
}
