// lib/core/domain/repositories/notification_repository.dart
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getUserNotificationsStream(String userId);
  Stream<int> getUnreadNotificationsCountStream(String userId);
  Future<void> markNotificationAsRead(String userId, String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);
  Future<void> deleteNotification(String userId, String notificationId); // <--- НОВИЙ МЕТОД
}