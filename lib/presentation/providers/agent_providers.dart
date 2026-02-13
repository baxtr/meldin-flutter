import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/participant.dart';
import 'conversation_providers.dart';

class AgentSuggestionState {
  final bool isLoading;
  final String? error;
  final List<Participant> suggestions;
  final Set<String> selectedIds;

  const AgentSuggestionState({
    this.isLoading = false,
    this.error,
    this.suggestions = const [],
    this.selectedIds = const {},
  });

  AgentSuggestionState copyWith({
    bool? isLoading,
    String? error,
    List<Participant>? suggestions,
    Set<String>? selectedIds,
  }) {
    return AgentSuggestionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      suggestions: suggestions ?? this.suggestions,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

final agentSuggestionProvider = StateNotifierProvider.autoDispose<
    AgentSuggestionNotifier, AgentSuggestionState>(
  (ref) => AgentSuggestionNotifier(ref),
);

class AgentSuggestionNotifier extends StateNotifier<AgentSuggestionState> {
  final Ref _ref;

  AgentSuggestionNotifier(this._ref)
      : super(const AgentSuggestionState());

  Future<void> generateSuggestions(String topic) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(conversationRepoProvider);
      final agents = await repo.suggestAgents(topic);
      state = state.copyWith(
        isLoading: false,
        suggestions: agents,
        selectedIds: agents.map((a) => a.id).toSet(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleAgent(String id) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedIds: selected);
  }

  void reset() {
    state = const AgentSuggestionState();
  }
}
