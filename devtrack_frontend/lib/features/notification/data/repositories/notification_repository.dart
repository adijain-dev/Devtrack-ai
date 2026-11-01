import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/app_notification.dart';

import '../../../../core/storage/offline_cache_service.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await _dio.get('/api/notifications');
      final list = response.data as List;
      final parsed = list.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();
      await OfflineCacheService().cacheNotifications(parsed);
      return parsed;
    } on DioException catch (e) {
      final cached = await OfflineCacheService().getCachedNotifications();
      if (cached.isNotEmpty) return cached;
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch notifications');
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _dio.get('/api/notifications/unread-count');
      return response.data['unreadCount'] as int;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch unread count');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.put('/api/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/api/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to mark all as read');
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});
