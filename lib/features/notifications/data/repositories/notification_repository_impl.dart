// lib/features/notifications/data/repositories/notification_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/app_notification.dart';
import '../../../../core/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userNotificationsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  @override
  Stream<List<AppNotification>> getUserNotificationsStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    developer.log('Subscribing to notifications for user: $userId', name: 'NotificationRepoImpl');
    return _userNotificationsCollection(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Received ${snapshot.docs.length} notifications for user: $userId', name: 'NotificationRepoImpl');
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    }).handleError((error, stackTrace) {
       developer.log('Error in notifications stream for user $userId: $error', error: error, stackTrace: stackTrace, name: 'NotificationRepoImpl');
       return <AppNotification>[];
    });
  }

  @override
  Stream<int> getUnreadNotificationsCountStream(String userId) {
    if (userId.isEmpty) return Stream.value(0);
    developer.log('Subscribing to unread notifications count for user: $userId', name: 'NotificationRepoImpl');
    return _userNotificationsCollection(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          developer.log('Unread count for $userId: ${snapshot.docs.length}', name: 'NotificationRepoImpl');
          return snapshot.docs.length;
        })
        .handleError((error, stackTrace) {
          developer.log('Error in unread count stream for $userId: $error', error: error, stackTrace: stackTrace, name: 'NotificationRepoImpl');
          return 0;
        });
  }

  @override
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;
    developer.log('Marking notification $notificationId as read for user $userId', name: 'NotificationRepoImpl');
    try {
      await _userNotificationsCollection(userId).doc(notificationId).update({'isRead': true});
    } catch (e, s) {
      developer.log('Error marking notification $notificationId as read for $userId: $e', error: e, stackTrace: s, name: 'NotificationRepoImpl');
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    if (userId.isEmpty) return;
    developer.log('Marking all notifications as read for user $userId', name: 'NotificationRepoImpl');
    try {
      final unreadNotifications = await _userNotificationsCollection(userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadNotifications.docs.isEmpty) {
        developer.log('No unread notifications to mark for user $userId', name: 'NotificationRepoImpl');
        return;
      }

      WriteBatch batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      developer.log('Marked ${unreadNotifications.docs.length} notifications as read for $userId', name: 'NotificationRepoImpl');
    } catch (e, s) {
      developer.log('Error marking all notifications as read for $userId: $e', error: e, stackTrace: s, name: 'NotificationRepoImpl');
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;
    developer.log('Deleting notification $notificationId for user $userId', name: 'NotificationRepoImpl');
    try {
      await _userNotificationsCollection(userId).doc(notificationId).delete();
    } catch (e, s) {
      developer.log('Error deleting notification $notificationId for $userId: $e', error: e, stackTrace: s, name: 'NotificationRepoImpl');
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

   Future<void> createTestNotification(String userId, {required String title, required String message, required NotificationType type}) async {
    if (userId.isEmpty) return;
    
    String iconName;
    switch (type) {
      case NotificationType.achievementUnlocked:
        iconName = 'emoji_events';
        break;
      case NotificationType.workoutReminder:
        iconName = 'fitness_center';
        break;
      case NotificationType.advice: // <--- Додано обробку для нового типу
        iconName = 'lightbulb_outline'; // Або інша іконка для порад
        break;
      case NotificationType.systemMessage:
         iconName = 'info_outline';
         break;
      default:
        iconName = 'notifications';
    }

    final newNotif = AppNotification(
      id: '', 
      type: type,
      title: title, // We keep sending the full string for test notifications
      message: message, // for simplicity, instead of using keys.
      timestamp: Timestamp.now(),
      isRead: false,
      iconName: iconName,
    );
    try {
      await _userNotificationsCollection(userId).add(newNotif.toMap()..['timestamp'] = FieldValue.serverTimestamp());
      developer.log('Test notification (type: ${type.name}) created for $userId', name: 'NotificationRepoImpl');
    } catch (e,s) {
      developer.log('Error creating test notification (type: ${type.name}) for $userId: $e', error: e, stackTrace: s, name: 'NotificationRepoImpl');
    }
  }
}