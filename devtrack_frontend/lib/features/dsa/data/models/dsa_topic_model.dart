import '../../domain/entities/dsa_topic.dart';

/// Data model with manual JSON serialization — no build_runner needed.
class DsaTopicModel extends DsaTopic {
  const DsaTopicModel({
    required super.id,
    required super.topicName,
    required super.category,
    required super.difficulty,
    super.isSolved,
    super.solvedDate,
    super.nextRevisionDate,
    super.revisionIntervalDays,
    super.needsRevision,
    super.platform,
    super.problemUrl,
    super.notes,
    super.practiceCount,
  });

  factory DsaTopicModel.fromJson(Map<String, dynamic> json) {
    return DsaTopicModel(
      id:                   json['id']?.toString() ?? '',
      topicName:            json['topicName'] as String,
      category:             _parseCategory(json['category'] as String?),
      difficulty:           _parseDifficulty(json['difficulty'] as String?),
      isSolved:             json['solved'] as bool? ?? false,
      solvedDate:           json['solvedDate'] as String?,
      nextRevisionDate:     json['nextRevisionDate'] as String?,
      revisionIntervalDays: json['revisionIntervalDays'] as int? ?? 7,
      needsRevision:        json['needsRevision'] as bool? ?? false,
      platform:             json['platform'] as String? ?? 'MANUAL',
      problemUrl:           json['problemUrl'] as String?,
      notes:                json['notes'] as String?,
      practiceCount:        json['practiceCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'topicName':            topicName,
    'category':             category.name.toUpperCase(),
    'difficulty':           difficulty.name.toUpperCase(),
    'solved':               isSolved,
    'solvedDate':           solvedDate,
    'nextRevisionDate':     nextRevisionDate,
    'revisionIntervalDays': revisionIntervalDays,
    'platform':             platform,
    if (problemUrl != null) 'problemUrl': problemUrl,
    'notes':                notes,
    'practiceCount':        practiceCount,
  };

  /// Convert a domain entity to a model for serialization.
  factory DsaTopicModel.fromEntity(DsaTopic t) => DsaTopicModel(
        id:                   t.id,
        topicName:            t.topicName,
        category:             t.category,
        difficulty:           t.difficulty,
        isSolved:             t.isSolved,
        solvedDate:           t.solvedDate,
        nextRevisionDate:     t.nextRevisionDate,
        revisionIntervalDays: t.revisionIntervalDays,
        needsRevision:        t.needsRevision,
        platform:             t.platform,
        problemUrl:           t.problemUrl,
        notes:                t.notes,
        practiceCount:        t.practiceCount,
      );

  // ── Parsers ─────────────────────────────────────────────────────────────

  static DsaCategory _parseCategory(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'ARRAYS':       return DsaCategory.arrays;
      case 'STRINGS':      return DsaCategory.strings;
      case 'LINKED_LIST':  return DsaCategory.linkedList;
      case 'TREES':        return DsaCategory.trees;
      case 'GRAPHS':       return DsaCategory.graphs;
      case 'DP':           return DsaCategory.dp;
      case 'SORTING':      return DsaCategory.sorting;
      case 'GREEDY':       return DsaCategory.greedy;
      case 'BACKTRACKING': return DsaCategory.backtracking;
      default:             return DsaCategory.other;
    }
  }

  static DsaDifficulty _parseDifficulty(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'EASY':   return DsaDifficulty.easy;
      case 'MEDIUM': return DsaDifficulty.medium;
      case 'HARD':   return DsaDifficulty.hard;
      default:       return DsaDifficulty.easy;
    }
  }
}
