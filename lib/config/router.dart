import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/conversation_list_screen.dart';
import '../presentation/screens/join_screen.dart';
import '../presentation/screens/chat_screen.dart';

CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _fadePage(const ConversationListScreen(), state),
    ),
    GoRoute(
      path: '/join/:conversationId',
      pageBuilder: (context, state) {
        final id = state.pathParameters['conversationId']!;
        return _fadePage(JoinScreen(conversationId: id), state);
      },
    ),
    GoRoute(
      path: '/chat/:conversationId',
      pageBuilder: (context, state) {
        final id = state.pathParameters['conversationId']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ChatScreen(conversationId: id),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(
                  CurveTween(curve: Curves.easeOut).animate(animation)),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
      },
    ),
  ],
);
