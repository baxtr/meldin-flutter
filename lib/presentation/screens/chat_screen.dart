import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
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
  bool _isNudging = false;
  String? _meetingTopic;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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

  Future<void> _handleNudge() async {
    setState(() => _isNudging = true);
    try {
      await ref
          .read(conversationRepoProvider)
          .nudge(widget.conversationId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to nudge conversation')),
        );
      }
    } finally {
      if (mounted) setState(() => _isNudging = false);
    }
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
      title: 'Melden Conversation',
      messages: messages,
      participants: participants,
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/melden-${widget.conversationId.substring(0, 8)}.txt');
    await file.writeAsString(content);

    await Share.shareXFiles([XFile(file.path)]);
  }

  void _handleNewChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start New Chat?'),
        content: const Text(
          'This will close the current conversation. Make sure to download or summarize if you want to save it.',
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
              final newId = const Uuid().v4();
              context.go('/join/$newId');
            },
            child: const Text('New Chat'),
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

    // Scroll to bottom on new messages
    ref.listen(messagesProvider(widget.conversationId), (prev, next) {
      if (prev != null && next.length > prev.length) {
        _scrollToBottom();
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
      onNudge: _handleNudge,
      isNudging: _isNudging,
      onRemoveParticipant: _handleRemoveParticipant,
      hasAgents: hasAgents,
    );

    Widget chatArea = Column(
      children: [
        // Messages
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState(theme, hasAgents)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: messages.length + typingParticipants.length,
                  itemBuilder: (context, index) {
                    if (index < messages.length) {
                      return ChatMessageWidget(
                          message: messages[index]);
                    }
                    final tp =
                        typingParticipants[index - messages.length];
                    return TypingIndicatorWidget(
                        participantName: tp.name);
                  },
                ),
        ),
        // Meeting topic banner
        if (_meetingTopic != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              border: Border(
                top: BorderSide(
                  color:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.topic,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _meetingTopic!,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Input
        ChatInputWidget(
          wsService: wsService,
          conversationId: widget.conversationId,
          userId: session.userId,
          userName: session.userName,
          isConnected: isConnected,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Melden',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          ConnectionStatusWidget(
              conversationId: widget.conversationId),
          if (!isWide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
        ],
      ),
      endDrawer: isWide ? null : Drawer(width: 300, child: sidebar),
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

  Widget _buildEmptyState(ThemeData theme, bool hasAgents) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (!hasAgents) ...[
              const SizedBox(height: 8),
              Text(
                'Get started by adding AI agents or inviting others',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAgentManager(),
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('Add AI Agents'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showInviteDialog(),
                    icon: const Icon(Icons.share),
                    label: const Text('Invite People'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                    ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AgentManagerDialog(
        onAddAgent: _handleAddAgent,
        onSetTopic: (topic) => setState(() => _meetingTopic = topic),
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
