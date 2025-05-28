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

  NotificationsCubit(this._notificationRepository, this._firebaseAuth)
      : super(NotificationsInitial()) {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        _currentUserId = user.uid;
        _subscribeToNotifications(user.uid);
      } else {
        _currentUserId = null;
        _unsubscribeFromNotifications();
        emit(NotificationsInitial());
      }
    });
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      _subscribeToNotifications(currentUser.uid);
    }
  }

  void _subscribeToNotifications(String userId) {
    // ... (код без змін) ...
     developer.log('NotificationsCubit: Subscribing for user $userId', name: 'NotificationsCubit');
    _unsubscribeFromNotifications(); // Скасувати попередні підписки

    emit(NotificationsLoading());

    List<AppNotification> currentNotifications = [];
    int currentUnreadCount = 0;
    bool firstLoadNotifications = true;
    bool firstLoadUnreadCount = true;

    _notificationsSubscription = _notificationRepository
        .getUserNotificationsStream(userId)
        .listen((notifications) {
      developer.log('NotificationsCubit: Received ${notifications.length} notifications', name: 'NotificationsCubit');
      currentNotifications = notifications;
      firstLoadNotifications = false;
      if (!firstLoadUnreadCount) { 
         emit(NotificationsLoaded(notifications: currentNotifications, unreadCount: currentUnreadCount));
      } else if (state is NotificationsLoading && !firstLoadNotifications && !firstLoadUnreadCount) {
        emit(NotificationsLoaded(notifications: currentNotifications, unreadCount: currentUnreadCount));
      } else if (state is! NotificationsLoaded && !firstLoadNotifications && !firstLoadUnreadCount) {
         emit(NotificationsLoaded(notifications: currentNotifications, unreadCount: currentUnreadCount));
      }
    }, onError: (error) {
      developer.log('NotificationsCubit: Error in notifications stream: $error', name: 'NotificationsCubit');
      emit(NotificationsError('Failed to load notifications: ${error.toString()}'));
    });

    _unreadCountSubscription = _notificationRepository
        .getUnreadNotificationsCountStream(userId)
        .listen((count) {
      developer.log('NotificationsCubit: Received unread count: $count', name: 'NotificationsCubit');
      currentUnreadCount = count;
      firstLoadUnreadCount = false;
      if (!firstLoadNotifications) { 
        emit(NotificationsLoaded(notifications: currentNotifications, unreadCount: currentUnreadCount));
      } else if (state is NotificationsLoading && !firstLoadNotifications && !firstLoadUnreadCount) {
        emit(NotificationsLoaded(notifications: currentNotifications, unreadCount: currentUnreadCount));
      } else if (state is! NotificationsLoaded && !firstLoadNotifications && !firstLoadUnreadCount) {
         emit(NotificationsLoaded(notifications: currentNotifications, unreadCount: currentUnreadCount));
      }
    }, onError: (error) {
      developer.log('NotificationsCubit: Error in unread count stream: $error', name: 'NotificationsCubit');
      if (state is NotificationsLoaded) {
        emit((state as NotificationsLoaded).copyWith(unreadCount: 0)); 
      } else {
        emit(NotificationsError('Failed to load unread count: ${error.toString()}'));
      }
    });
  }

  void _unsubscribeFromNotifications() {
    // ... (код без змін) ...
    developer.log('NotificationsCubit: Unsubscribing', name: 'NotificationsCubit');
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = null;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    // ... (код без змін) ...
    final userId = _currentUserId;
    if (userId == null || notificationId.isEmpty) return;
    developer.log('NotificationsCubit: Marking notification $notificationId as read for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.markNotificationAsRead(userId, notificationId);
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((n) {
          return n.id == notificationId ? n.copyWith(isRead: true) : n;
        }).toList();
        final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(notifications: updatedNotifications, unreadCount: newUnreadCount));
      }
    } catch (e) {
      developer.log('NotificationsCubit: Error marking notification as read: $e', name: 'NotificationsCubit');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    // ... (код без змін) ...
     final userId = _currentUserId;
    if (userId == null) return;
     developer.log('NotificationsCubit: Marking all notifications as read for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.markAllNotificationsAsRead(userId);
       if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(NotificationsLoaded(notifications: updatedNotifications, unreadCount: 0));
      }
    } catch (e) {
      developer.log('NotificationsCubit: Error marking all notifications as read: $e', name: 'NotificationsCubit');
    }
  }

  // <--- НОВИЙ МЕТОД --->
  Future<void> deleteNotification(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null || notificationId.isEmpty) return;
    developer.log('NotificationsCubit: Deleting notification $notificationId for user $userId', name: 'NotificationsCubit');
    try {
      await _notificationRepository.deleteNotification(userId, notificationId);
      // Оптимістичне оновлення UI або очікування на оновлення від Stream
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.where((n) => n.id != notificationId).toList();
        final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(notifications: updatedNotifications, unreadCount: newUnreadCount));
         developer.log('NotificationsCubit: UI updated after deleting notification $notificationId', name: 'NotificationsCubit');
      }
    } catch (e) {
      developer.log('NotificationsCubit: Error deleting notification: $e', name: 'NotificationsCubit');
      // Можна показати помилку користувачу через стан або SnackBar
      // emit(NotificationsError('Failed to delete notification: ${e.toString()}'));
    }
  }
  // <--- КІНЕЦЬ НОВОГО МЕТОДУ --->

  Future<void> createTestNotification({required String title, required String message, NotificationType type = NotificationType.custom}) async {
    // ... (код без змін) ...
    final userId = _currentUserId;
    if (userId == null) return;
    if (_notificationRepository is NotificationRepositoryImpl) {
     await (_notificationRepository as NotificationRepositoryImpl).createTestNotification(userId, title: title, message: message, type: type);
    }
  }

  @override
  Future<void> close() {
    // ... (код без змін) ...
    developer.log('NotificationsCubit: Closing', name: 'NotificationsCubit');
    _authStateSubscription?.cancel();
    _unsubscribeFromNotifications();
    return super.close();
  }
}