import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/offline_cache_service.dart';
import '../../domain/entities/dsa_topic.dart';
import '../../data/providers/dsa_repository_provider.dart';
import '../../data/models/dsa_topic_model.dart';
import '../providers/dsa_state.dart';

final dsaNotifierProvider = NotifierProvider<DsaNotifier, DsaState>(DsaNotifier.new);

class DsaNotifier extends Notifier<DsaState> {
  @override
  DsaState build() {
    Future.microtask(() async {
      // 1. Instantly display cached topics (0ms wait)
      final cached = await OfflineCacheService().getCachedDsaTopics();
      if (cached.isNotEmpty) {
        state = state.copyWith(topics: cached, isLoading: false);
      }
      // 2. Fetch latest in background
      await fetchAll(silent: cached.isNotEmpty);
    });
    return const DsaState(isLoading: true);
  }

  Future<void> fetchAll({bool silent = false}) async {
    if (!silent && state.topics.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final topics = await ref.read(dsaRepositoryProvider).getAll();
      state = state.copyWith(topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: state.topics.isEmpty ? e.toString() : null,
      );
    }
  }

  Future<bool> create(DsaTopic topic) async {
    try {
      final created = await ref.read(dsaRepositoryProvider).create(
        DsaTopicModel.fromEntity(topic),
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
        DsaTopicModel.fromEntity(topic),
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
    final nextRev = !topic.isSolved ? today.add(const Duration(days: 7)) : null;
    final nextRevStr = nextRev != null
        ? '${nextRev.year}-${nextRev.month.toString().padLeft(2, '0')}-${nextRev.day.toString().padLeft(2, '0')}'
        : null;

    await update(topic.copyWith(
      isSolved: !topic.isSolved,
      solvedDate: !topic.isSolved ? dateStr : null,
      nextRevisionDate: nextRevStr,
      revisionIntervalDays: 7,
      needsRevision: false,
      practiceCount: topic.practiceCount + (!topic.isSolved ? 1 : 0),
    ));
  }

  /// Complete a spaced repetition review for a topic.
  Future<bool> reviewTopic(DsaTopic topic) async {
    try {
      final updated = await ref.read(dsaRepositoryProvider).reviewTopic(topic.id);
      state = state.copyWith(
        topics: state.topics.map((t) => t.id == updated.id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Sync statistics and problems from LeetCode or Codeforces.
  Future<Map<String, dynamic>?> syncProfile({
    required String platform,
    required String username,
    bool importProblems = true,
  }) async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      final stats = await ref.read(dsaRepositoryProvider).syncProfile(
        platform: platform,
        username: username,
        importProblems: importProblems,
      );
      final topics = await ref.read(dsaRepositoryProvider).getAll();
      state = state.copyWith(
        topics: topics,
        isSyncing: false,
        lastSyncStats: stats,
      );
      return stats;
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
      return null;
    }
  }

  void toggleDueRevisionsFilter() {
    state = state.copyWith(
      showOnlyDueRevisions: !state.showOnlyDueRevisions,
    );
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
