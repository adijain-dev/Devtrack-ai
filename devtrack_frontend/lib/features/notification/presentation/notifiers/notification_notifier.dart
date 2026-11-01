import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/app_notification.dart';

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    _fetchInitial();
    return const NotificationState();
  }

  Future<void> _fetchInitial() async {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final list = await repo.fetchNotifications();
      state = state.copyWith(notifications: list, isLoading: false);

      // Trigger local OS notifications for new unread notifications
      for (final n in list.where((x) => !x.isRead).take(2)) {
        LocalNotificationService().showNotification(
          id: n.id,
          title: n.title,
          body: n.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(notificationId);
      final updatedList = state.notifications.map((n) {
        if (n.id == notificationId) {
          return AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updatedList);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
      final updatedList = state.notifications.map((n) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      state = state.copyWith(notifications: updatedList);
    } catch (_) {}
  }
}

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        NotificationNotifier.new);
