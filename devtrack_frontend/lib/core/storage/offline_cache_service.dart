import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/internship/domain/entities/internship.dart';
import '../../features/internship/data/models/internship_model.dart';
import '../../features/dsa/domain/entities/dsa_topic.dart';
import '../../features/dsa/data/models/dsa_topic_model.dart';
import '../../features/notification/domain/entities/app_notification.dart';

class OfflineCacheService {
  static const String _keyInternships = 'offline_cache_internships';
  static const String _keyDsaTopics = 'offline_cache_dsa_topics';
  static const String _keyNotifications = 'offline_cache_notifications';
  static const String _keyLastSync = 'offline_cache_last_sync';

  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  // ── Internships Cache ──────────────────────────────────────────────────────

  Future<void> cacheInternships(List<Internship> internships) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = internships
        .map((item) => InternshipModel.fromEntity(item).toJson())
        .toList();
    await prefs.setString(_keyInternships, jsonEncode(jsonList));
    await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  Future<List<Internship>> getCachedInternships() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyInternships);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => InternshipModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── DSA Topics Cache ───────────────────────────────────────────────────────

  Future<void> cacheDsaTopics(List<DsaTopic> topics) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        topics.map((item) => DsaTopicModel.fromEntity(item).toJson()).toList();
    await prefs.setString(_keyDsaTopics, jsonEncode(jsonList));
  }

  Future<List<DsaTopic>> getCachedDsaTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDsaTopics);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => DsaTopicModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Notifications Cache ────────────────────────────────────────────────────

  Future<void> cacheNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications
        .map((item) => {
              'id': item.id,
              'title': item.title,
              'message': item.message,
              'isRead': item.isRead,
              'createdAt': item.createdAt,
            })
        .toList();
    await prefs.setString(_keyNotifications, jsonEncode(jsonList));
  }

  Future<List<AppNotification>> getCachedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotifications);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSync);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyInternships);
    await prefs.remove(_keyDsaTopics);
    await prefs.remove(_keyNotifications);
  }
}
