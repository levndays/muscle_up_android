// lib/features/notifications/presentation/cubit/notifications_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import '../../../../core/domain/entities/app_notification.dart';
import '../../../../core/domain/repositories/notification_repository.dart';
// Import for type casting the repository if needed for specific methods like createTestNotification
import '../../data/repositories/notification_repository_impl.dart';

part 'notifications_state.dart';

/// Manages the state of user notifications, including fetching,
/// tracking unread counts, and providing alerts for new achievements.
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _notificationRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;

  StreamSubscription<List<AppNotification>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  StreamSubscription<fb_auth.User?>? _authStateSubscription;

  String? _currentUserId;

  /// Controller to broadcast new achievement notifications for immediate UI alerts (e.g., SnackBars).
  final StreamController<AppNotification> _achievementAlertController = StreamController<AppNotification>.broadcast();
  /// Public stream for UI to listen to new achievement alerts.
  Stream<AppNotification> get achievementAlertStream => _achievementAlertController.stream;
  /// Stores IDs of achievement notifications already alerted in the current session to prevent duplicates.
  final Set<String> _alertedAchievementNotificationIds = {};

  NotificationsCubit(this._notificationRepository, this._firebaseAuth)
      : super(NotificationsInitial()) {
    // Listen to authentication state changes to manage subscriptions and user-specific data.
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        _currentUserId = user.uid;
        _alertedAchievementNotificationIds.clear(); // Clear alerted achievements for new user/session.
        _subscribeToNotifications(user.uid);
      } else {
        _currentUserId = null;
        _unsubscribeFromNotifications();
        _alertedAchievementNotificationIds.clear();
        emit(NotificationsInitial()); // Reset state on logout.
      }
    });

    // Initial setup if a user is already authenticated when the cubit is created.
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      _alertedAchievementNotificationIds.clear();
      _subscribeToNotifications(currentUser.uid);
    }
  }

  /// Subscribes to real-time updates for user notifications and unread counts from the repository.
  /// Emits [NotificationsLoaded] state with the latest data.
  /// Also checks for new, unread achievement notifications to push to [_achievementAlertController].
  void _subscribeToNotifications(String userId) {
    developer.log('NotificationsCubit: Subscribing to notifications and unread count for user $userId', name: 'NotificationsCubit');
    _unsubscribeFromNotifications(); // Ensure previous subscriptions are cancelled.

    emit(NotificationsLoading()); // Indicate loading state.

    List<AppNotification> currentNotificationsList = []; // Local cache of notifications for state emission.
    int currentUnreadCount = 0; // Local cache of unread count.

    _notificationsSubscription = _notificationRepository
        .getUserNotificationsStream(userId)
        .listen((notifications) {
      developer.log('NotificationsCubit: Received ${notifications.length} notifications for user $userId', name: 'NotificationsCubit');
      currentNotificationsList = notifications;

      // Check for new, unread achievement notifications to alert the UI.
      for (final n in notifications) {
        if (n.type == NotificationType.achievementUnlocked &&
            !n.isRead && // Only alert if the notification is marked as unread in Firestore
            !_alertedAchievementNotificationIds.contains(n.id)) {
          developer.log('NotificationsCubit: New achievement alert: ${n.title} (ID: ${n.id})', name: 'NotificationsCubit');
          _achievementAlertController.add(n);
          _alertedAchievementNotificationIds.add(n.id);
        }
      }
      // Emit loaded state with potentially updated notifications list and existing unread count.
      emit(NotificationsLoaded(notifications: currentNotificationsList, unreadCount: currentUnreadCount));
    }, onError: (error, stackTrace) {
      developer.log('NotificationsCubit: Error in notifications stream for $userId: $error', name: 'NotificationsCubit', error: error, stackTrace: stackTrace);
      emit(NotificationsError('Failed to load notifications: ${error.toString()}'));
    });

    _unreadCountSubscription = _notificationRepository
        .getUnreadNotificationsCountStream(userId)
        .listen((count) {
      developer.log('NotificationsCubit: Received unread count: $count for user $userId', name: 'NotificationsCubit');
      currentUnreadCount = count;
      // Emit loaded state with potentially updated unread count and existing notifications list.
      emit(NotificationsLoaded(notifications: currentNotificationsList, unreadCount: currentUnreadCount));
    }, onError: (error, stackTrace) {
      developer.log('NotificationsCubit: Error in unread count stream for $userId: $error', name: 'NotificationsCubit', error: error, stackTrace: stackTrace);
      // If an error occurs loading unread count, try to update existing state or emit error.
      if (state is NotificationsLoaded) {
        emit((state as NotificationsLoaded).copyWith(unreadCount: 0)); // Default to 0 on error if already loaded
      } else {
        emit(NotificationsError('Failed to load unread count: ${error.toString()}'));
      }
    });
  }

  /// Cancels all active stream subscriptions.
  void _unsubscribeFromNotifications() {
    developer.log('NotificationsCubit: Unsubscribing from notification streams.', name: 'NotificationsCubit');
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = null;
    // Note: _alertedAchievementNotificationIds is cleared on user change/logout, not here.
  }

  /// Marks a specific notification as read. UI will update via stream.
  Future<void> markNotificationAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || notificationId.isEmpty) return;
    developer.log('NotificationsCubit: Request to mark notification $notificationId as read for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.markNotificationAsRead(userId, notificationId);
      // The UI should react to the stream update from Firestore.
    } catch (e) {
      developer.log('NotificationsCubit: Error marking notification $notificationId as read: $e', name: 'NotificationsCubit');
      // Optionally, emit an error state or show a message to the user.
    }
  }

  /// Marks all unread notifications as read for the current user. UI will update via stream.
  Future<void> markAllNotificationsAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;
    developer.log('NotificationsCubit: Request to mark all notifications as read for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.markAllNotificationsAsRead(userId);
      // The UI should react to the stream update from Firestore.
    } catch (e) {
      developer.log('NotificationsCubit: Error marking all notifications as read: $e', name: 'NotificationsCubit');
    }
  }

  /// Deletes a specific notification. UI will update via stream.
  Future<void> deleteNotification(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || notificationId.isEmpty) return;
    developer.log('NotificationsCubit: Request to delete notification $notificationId for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.deleteNotification(userId, notificationId);
      _alertedAchievementNotificationIds.remove(notificationId); // Remove from alerted cache if it was there.
      // The UI should react to the stream update from Firestore.
    } catch (e) {
      developer.log('NotificationsCubit: Error deleting notification $notificationId: $e', name: 'NotificationsCubit');
    }
  }

  /// Creates a test notification for the current user.
  /// This method assumes `_notificationRepository` is an instance of `NotificationRepositoryImpl`.
  /// Used for debugging and testing purposes.
  Future<void> createTestNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.custom,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log('NotificationsCubit: Cannot create test notification, no user logged in.', name: 'NotificationsCubit');
      return;
    }
    // This relies on the concrete implementation having this method.
    // Consider a more abstract way if this needs to be generic or use dependency injection for test-specific features.
    if (_notificationRepository is NotificationRepositoryImpl) {
      await (_notificationRepository as NotificationRepositoryImpl)
          .createTestNotification(userId, title: title, message: message, type: type);
      developer.log('NotificationsCubit: Test notification creation requested for user $userId.', name: 'NotificationsCubit');
    } else {
      developer.log('NotificationsCubit: Cannot create test notification, repository is not NotificationRepositoryImpl.', name: 'NotificationsCubit');
    }
  }

  @override
  Future<void> close() {
    developer.log('NotificationsCubit: Closing and cleaning up resources.', name: 'NotificationsCubit');
    _authStateSubscription?.cancel();
    _unsubscribeFromNotifications();
    _achievementAlertController.close(); // Important: close the stream controller.
    return super.close();
  }
}