import '../../domain/entities/dsa_topic.dart';

/// State for the DSA Tracker feature.
class DsaState {
  final List<DsaTopic> topics;
  final bool isLoading;
  final String? error;
  final DsaCategory? selectedCategory; // null = show all
  final DsaDifficulty? selectedDifficulty; // null = show all

  const DsaState({
    this.topics = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.selectedDifficulty,
  });

  /// Filtered list based on selected category + difficulty
  List<DsaTopic> get filtered {
    return topics.where((t) {
      final matchCat = selectedCategory == null || t.category == selectedCategory;
      final matchDiff = selectedDifficulty == null || t.difficulty == selectedDifficulty;
      return matchCat && matchDiff;
    }).toList();
  }

  int get totalCount   => topics.length;
  int get solvedCount  => topics.where((t) => t.isSolved).length;
  int get pendingCount => topics.where((t) => !t.isSolved).length;

  /// Streak: count of consecutive days with at least one topic solved
  int get streak {
    final solvedDates = topics
        .where((t) => t.isSolved && t.solvedDate != null)
        .map((t) => t.solvedDate!)
        .toSet()
        .toList()
      ..sort();

    if (solvedDates.isEmpty) return 0;

    int streak = 1;
    final today = DateTime.now();
    DateTime prev = DateTime.tryParse(solvedDates.last) ?? today;

    // Walk backwards through sorted unique dates
    for (int i = solvedDates.length - 2; i >= 0; i--) {
      final current = DateTime.tryParse(solvedDates[i]);
      if (current == null) break;
      final diff = prev.difference(current).inDays;
      if (diff == 1) {
        streak++;
        prev = current;
      } else {
        break;
      }
    }
    return streak;
  }

  DsaState copyWith({
    List<DsaTopic>? topics,
    bool? isLoading,
    String? error,
    DsaCategory? selectedCategory,
    DsaDifficulty? selectedDifficulty,
    bool clearCategory = false,
    bool clearDifficulty = false,
    bool clearError = false,
  }) {
    return DsaState(
      topics:             topics ?? this.topics,
      isLoading:          isLoading ?? this.isLoading,
      error:              clearError ? null : (error ?? this.error),
      selectedCategory:   clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDifficulty: clearDifficulty ? null : (selectedDifficulty ?? this.selectedDifficulty),
    );
  }
}
