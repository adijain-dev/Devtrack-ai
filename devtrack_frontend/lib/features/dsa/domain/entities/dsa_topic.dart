/// Domain entity representing a DSA (Data Structures & Algorithms) topic.
class DsaTopic {
  final String id;
  final String topicName;
  final DsaCategory category;
  final DsaDifficulty difficulty;
  final bool isSolved;
  final String? solvedDate; // ISO date string e.g. "2026-06-07"
  final String? notes;
  final int practiceCount;

  const DsaTopic({
    required this.id,
    required this.topicName,
    required this.category,
    required this.difficulty,
    this.isSolved = false,
    this.solvedDate,
    this.notes,
    this.practiceCount = 0,
  });
}

enum DsaCategory {
  arrays,
  strings,
  linkedList,
  trees,
  graphs,
  dp,
  sorting,
  greedy,
  backtracking,
  other,
}

enum DsaDifficulty { easy, medium, hard }

// ── Extension helpers ────────────────────────────────────────────────────────

extension DsaCategoryLabel on DsaCategory {
  String get label {
    switch (this) {
      case DsaCategory.arrays:       return 'Arrays';
      case DsaCategory.strings:      return 'Strings';
      case DsaCategory.linkedList:   return 'Linked List';
      case DsaCategory.trees:        return 'Trees';
      case DsaCategory.graphs:       return 'Graphs';
      case DsaCategory.dp:           return 'Dynamic Programming';
      case DsaCategory.sorting:      return 'Sorting';
      case DsaCategory.greedy:       return 'Greedy';
      case DsaCategory.backtracking: return 'Backtracking';
      case DsaCategory.other:        return 'Other';
    }
  }
}

extension DsaDifficultyLabel on DsaDifficulty {
  String get label {
    switch (this) {
      case DsaDifficulty.easy:   return 'Easy';
      case DsaDifficulty.medium: return 'Medium';
      case DsaDifficulty.hard:   return 'Hard';
    }
  }
}
