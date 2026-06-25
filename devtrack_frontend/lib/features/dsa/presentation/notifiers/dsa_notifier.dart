import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dsa_topic.dart';
import '../../data/providers/dsa_repository_provider.dart';
import '../../data/models/dsa_topic_model.dart';
import '../providers/dsa_state.dart';

final dsaNotifierProvider = NotifierProvider<DsaNotifier, DsaState>(DsaNotifier.new);

class DsaNotifier extends Notifier<DsaState> {
  @override
  DsaState build() {
    Future.microtask(() => fetchAll());
    return const DsaState(isLoading: true);
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final topics = await ref.read(dsaRepositoryProvider).getAll();
      state = state.copyWith(topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> create(DsaTopic topic) async {
    try {
      final created = await ref.read(dsaRepositoryProvider).create(
        DsaTopicModel(
          id: topic.id,
          topicName: topic.topicName,
          category: topic.category,
          difficulty: topic.difficulty,
          isSolved: topic.isSolved,
          solvedDate: topic.solvedDate,
          notes: topic.notes,
          practiceCount: topic.practiceCount,
        ),
      );
      state = state.copyWith(topics: [...state.topics, created]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> update(DsaTopic topic) async {
    try {
      final updated = await ref.read(dsaRepositoryProvider).update(
        DsaTopicModel(
          id: topic.id,
          topicName: topic.topicName,
          category: topic.category,
          difficulty: topic.difficulty,
          isSolved: topic.isSolved,
          solvedDate: topic.solvedDate,
          notes: topic.notes,
          practiceCount: topic.practiceCount,
        ),
      );
      state = state.copyWith(
        topics: state.topics.map((t) => t.id == updated.id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Toggle solved/unsolved quickly from the list screen.
  Future<void> toggleSolved(DsaTopic topic) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await update(DsaTopicModel(
      id: topic.id,
      topicName: topic.topicName,
      category: topic.category,
      difficulty: topic.difficulty,
      isSolved: !topic.isSolved,
      solvedDate: !topic.isSolved ? dateStr : null,
      notes: topic.notes,
      practiceCount: topic.practiceCount + (!topic.isSolved ? 1 : 0),
    ));
  }

  Future<bool> delete(String id) async {
    try {
      await ref.read(dsaRepositoryProvider).delete(id);
      state = state.copyWith(topics: state.topics.where((t) => t.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void filterByCategory(DsaCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  void filterByDifficulty(DsaDifficulty? difficulty) {
    state = state.copyWith(
      selectedDifficulty: difficulty,
      clearDifficulty: difficulty == null,
    );
  }
}
