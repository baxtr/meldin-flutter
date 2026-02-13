import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionState {
  final String conversationId;
  final String userId;
  final String userName;
  final bool hasJoined;

  const SessionState({
    required this.conversationId,
    required this.userId,
    this.userName = '',
    this.hasJoined = false,
  });

  SessionState copyWith({
    String? userId,
    String? userName,
    bool? hasJoined,
  }) {
    return SessionState(
      conversationId: conversationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      hasJoined: hasJoined ?? this.hasJoined,
    );
  }
}

final sessionProvider =
    StateNotifierProvider.family<SessionNotifier, SessionState, String>(
  (ref, conversationId) => SessionNotifier(conversationId),
);

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(String conversationId)
      : super(SessionState(conversationId: conversationId, userId: '')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cid = state.conversationId;
    final savedName = prefs.getString('meldin_user_$cid') ?? '';
    final savedJoined = prefs.getBool('meldin_joined_$cid') ?? false;
    var savedUserId = prefs.getString('meldin_userId_$cid');
    if (savedUserId == null) {
      savedUserId = const Uuid().v4();
      await prefs.setString('meldin_userId_$cid', savedUserId);
    }
    state = state.copyWith(
      userId: savedUserId,
      userName: savedName,
      hasJoined: savedJoined,
    );
  }

  Future<void> join(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final cid = state.conversationId;
    await prefs.setString('meldin_user_$cid', name);
    await prefs.setBool('meldin_joined_$cid', true);
    state = state.copyWith(userName: name, hasJoined: true);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cid = state.conversationId;
    await prefs.remove('meldin_user_$cid');
    await prefs.remove('meldin_joined_$cid');
    await prefs.remove('meldin_userId_$cid');
    state = SessionState(conversationId: cid, userId: const Uuid().v4());
  }
}
