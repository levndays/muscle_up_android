// lib/features/notifications/presentation/cubit/notifications_state.dart
part of 'notifications_cubit.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {
  // Додаємо поля для зберігання попередніх даних, якщо вони є
  final List<AppNotification> previousNotifications;
  final int previousUnreadCount;

  const NotificationsLoading({
    this.previousNotifications = const [],
    this.previousUnreadCount = 0,
  });

  @override
  List<Object?> get props => [previousNotifications, previousUnreadCount];
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}