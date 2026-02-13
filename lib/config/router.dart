import 'package:go_router/go_router.dart';
import '../presentation/screens/conversation_list_screen.dart';
import '../presentation/screens/join_screen.dart';
import '../presentation/screens/chat_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ConversationListScreen(),
    ),
    GoRoute(
      path: '/join/:conversationId',
      builder: (context, state) {
        final id = state.pathParameters['conversationId']!;
        return JoinScreen(conversationId: id);
      },
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final id = state.pathParameters['conversationId']!;
        return ChatScreen(conversationId: id);
      },
    ),
  ],
);
