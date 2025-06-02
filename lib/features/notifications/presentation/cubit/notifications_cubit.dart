// lib/features/notifications/presentation/cubit/notifications_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import '../../../../core/domain/entities/app_notification.dart';
import '../../../../core/domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _notificationRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;

  StreamSubscription<List<AppNotification>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  StreamSubscription<fb_auth.User?>? _authStateSubscription;

  String? _currentUserId;

  final StreamController<AppNotification> _achievementAlertController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get achievementAlertStream => _achievementAlertController.stream;
  final Set<String> _alertedAchievementNotificationIds = {};

  final StreamController<AppNotification> _adviceAlertController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get adviceAlertStream => _adviceAlertController.stream;
  final Set<String> _alertedAdviceNotificationIds = {};


  NotificationsCubit(this._notificationRepository, this._firebaseAuth)
      : super(NotificationsInitial()) {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        _currentUserId = user.uid;
        _alertedAchievementNotificationIds.clear();
        _alertedAdviceNotificationIds.clear();
        _subscribeToNotifications(user.uid);
      } else {
        _currentUserId = null;
        _unsubscribeFromNotifications();
        _alertedAchievementNotificationIds.clear();
        _alertedAdviceNotificationIds.clear();
        emit(NotificationsInitial());
      }
    });

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      _alertedAchievementNotificationIds.clear();
      _alertedAdviceNotificationIds.clear();
      _subscribeToNotifications(currentUser.uid);
    }
  }

  void refreshNotifications() {
    final userId = _currentUserId;
    if (userId != null) {
      developer.log('NotificationsCubit: Refreshing notifications for user $userId', name: 'NotificationsCubit');
      _subscribeToNotifications(userId);
    } else {
      developer.log('NotificationsCubit: Cannot refresh notifications, no user.', name: 'NotificationsCubit');
    }
  }

  void _subscribeToNotifications(String userId) {
    developer.log('NotificationsCubit: Subscribing to notifications and unread count for user $userId', name: 'NotificationsCubit');
    _unsubscribeFromNotifications();

    // Зберігаємо поточні дані, якщо вони є, щоб не показувати пустий екран під час оновлення
    List<AppNotification> previousNotifications = [];
    int previousUnreadCount = 0;
    if (state is NotificationsLoaded) {
      final loadedState = state as NotificationsLoaded;
      previousNotifications = loadedState.notifications;
      previousUnreadCount = loadedState.unreadCount;
    }

    emit(NotificationsLoading(previousNotifications: previousNotifications, previousUnreadCount: previousUnreadCount));


    List<AppNotification> currentNotificationsList = previousNotifications;
    int currentUnreadCount = previousUnreadCount;

    _notificationsSubscription = _notificationRepository
        .getUserNotificationsStream(userId)
        .listen((notifications) {
      developer.log('NotificationsCubit: Received ${notifications.length} notifications for user $userId', name: 'NotificationsCubit');
      currentNotificationsList = notifications;

      for (final n in notifications) {
        if (n.type == NotificationType.achievementUnlocked &&
            !n.isRead &&
            !_alertedAchievementNotificationIds.contains(n.id)) {
          developer.log('NotificationsCubit: New achievement alert: ${n.title} (ID: ${n.id})', name: 'NotificationsCubit');
          _achievementAlertController.add(n);
          _alertedAchievementNotificationIds.add(n.id);
        } else if (n.type == NotificationType.advice && 
                   !n.isRead &&
                   !_alertedAdviceNotificationIds.contains(n.id)) {
          developer.log('NotificationsCubit: New advice alert: ${n.title} (ID: ${n.id})', name: 'NotificationsCubit');
          _adviceAlertController.add(n);
          _alertedAdviceNotificationIds.add(n.id);
        }
      }
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
      // Перевіряємо, чи ми все ще в стані завантаження або вже завантажені
      if (state is NotificationsLoading || state is NotificationsLoaded) {
        emit(NotificationsLoaded(notifications: currentNotificationsList, unreadCount: currentUnreadCount));
      }
    }, onError: (error, stackTrace) {
      developer.log('NotificationsCubit: Error in unread count stream for $userId: $error', name: 'NotificationsCubit', error: error, stackTrace: stackTrace);
      if (state is NotificationsLoaded) {
        emit((state as NotificationsLoaded).copyWith(unreadCount: 0));
      } else if (state is NotificationsLoading) {
         emit(NotificationsLoaded(notifications: (state as NotificationsLoading).previousNotifications, unreadCount: 0));
      } else {
        emit(NotificationsError('Failed to load unread count: ${error.toString()}'));
      }
    });
  }

  void _unsubscribeFromNotifications() {
    developer.log('NotificationsCubit: Unsubscribing from notification streams.', name: 'NotificationsCubit');
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = null;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || notificationId.isEmpty) return;
    developer.log('NotificationsCubit: Request to mark notification $notificationId as read for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.markNotificationAsRead(userId, notificationId);
    } catch (e) {
      developer.log('NotificationsCubit: Error marking notification $notificationId as read: $e', name: 'NotificationsCubit');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;
    developer.log('NotificationsCubit: Request to mark all notifications as read for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.markAllNotificationsAsRead(userId);
    } catch (e) {
      developer.log('NotificationsCubit: Error marking all notifications as read: $e', name: 'NotificationsCubit');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || notificationId.isEmpty) return;
    developer.log('NotificationsCubit: Request to delete notification $notificationId for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.deleteNotification(userId, notificationId);
      _alertedAchievementNotificationIds.remove(notificationId);
      _alertedAdviceNotificationIds.remove(notificationId);
    } catch (e) {
      developer.log('NotificationsCubit: Error deleting notification $notificationId: $e', name: 'NotificationsCubit');
    }
  }
  
  Future<void> createTestNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log('NotificationsCubit: Cannot create test notification, no user logged in.', name: 'NotificationsCubit');
      return;
    }
    if (_notificationRepository is NotificationRepositoryImpl) {
      await (_notificationRepository as NotificationRepositoryImpl)
          .createTestNotification(userId, title: title, message: message, type: type);
      developer.log('NotificationsCubit: Test notification (type: ${type.name}) creation requested for user $userId.', name: 'NotificationsCubit');
    } else {
      developer.log('NotificationsCubit: Cannot create test notification, repository is not NotificationRepositoryImpl.', name: 'NotificationsCubit');
    }
  }

  @override
  Future<void> close() {
    developer.log('NotificationsCubit: Closing and cleaning up resources.', name: 'NotificationsCubit');
    _authStateSubscription?.cancel();
    _unsubscribeFromNotifications();
    _achievementAlertController.close();
    _adviceAlertController.close();
    return super.close();
  }
}