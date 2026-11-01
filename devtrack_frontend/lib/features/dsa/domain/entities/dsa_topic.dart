class DsaTopic {
  final String id;
  final String topicName;
  final DsaCategory category;
  final DsaDifficulty difficulty;
  final bool isSolved;
  final String? solvedDate; // ISO date string e.g. "2026-06-07"
  final String? nextRevisionDate;
  final int revisionIntervalDays;
  final bool needsRevision;
  final String? platform;
  final String? problemUrl;
  final String? notes;
  final int practiceCount;

  const DsaTopic({
    required this.id,
    required this.topicName,
    required this.category,
    required this.difficulty,
    this.isSolved = false,
    this.solvedDate,
    this.nextRevisionDate,
    this.revisionIntervalDays = 7,
    this.needsRevision = false,
    this.platform = 'MANUAL',
    this.problemUrl,
    this.notes,
    this.practiceCount = 0,
  });

  DsaTopic copyWith({
    String? id,
    String? topicName,
    DsaCategory? category,
    DsaDifficulty? difficulty,
    bool? isSolved,
    String? solvedDate,
    String? nextRevisionDate,
    int? revisionIntervalDays,
    bool? needsRevision,
    String? platform,
    String? problemUrl,
    String? notes,
    int? practiceCount,
  }) {
    return DsaTopic(
      id: id ?? this.id,
      topicName: topicName ?? this.topicName,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isSolved: isSolved ?? this.isSolved,
      solvedDate: solvedDate ?? this.solvedDate,
      nextRevisionDate: nextRevisionDate ?? this.nextRevisionDate,
      revisionIntervalDays: revisionIntervalDays ?? this.revisionIntervalDays,
      needsRevision: needsRevision ?? this.needsRevision,
      platform: platform ?? this.platform,
      problemUrl: problemUrl ?? this.problemUrl,
      notes: notes ?? this.notes,
      practiceCount: practiceCount ?? this.practiceCount,
    );
  }
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

  String get shortLabel {
    switch (this) {
      case DsaCategory.arrays:       return 'ARR';
      case DsaCategory.strings:      return 'STR';
      case DsaCategory.linkedList:   return 'LL';
      case DsaCategory.trees:        return 'TREE';
      case DsaCategory.graphs:       return 'GRP';
      case DsaCategory.dp:           return 'DP';
      case DsaCategory.sorting:      return 'SORT';
      case DsaCategory.greedy:       return 'GRD';
      case DsaCategory.backtracking: return 'BT';
      case DsaCategory.other:        return 'OTH';
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
