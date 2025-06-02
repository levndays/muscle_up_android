// lib/core/domain/entities/app_notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType {
  achievementUnlocked, // Досягнення
  workoutReminder,     // Нагадування про тренування
  newFollower,         // Новий підписник (на майбутнє)
  routineShared,       // Хтось поділився рутиною (на майбутнє)
  systemMessage,       // Системне повідомлення
  advice,              // Новий тип для порад
  custom,              // Інший тип
}

class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final String? relatedEntityId;   // Наприклад, ID досягнення, рутини
  final String? relatedEntityType; // Наприклад, 'achievement', 'routine'
  final String? iconName;          // Назва іконки з Material Icons або кастомної

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedEntityId,
    this.relatedEntityType,
    this.iconName,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Notification data is null!");

    return AppNotification(
      id: snapshot.id,
      type: _parseNotificationType(data['type'] as String?),
      title: data['title'] ?? 'Notification',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
      relatedEntityId: data['relatedEntityId'] as String?,
      relatedEntityType: data['relatedEntityType'] as String?,
      iconName: data['iconName'] as String?,
    );
  }

  Map<String, dynamic> toMap() { // Для створення/оновлення
    return {
      // 'id' не потрібен тут, бо це ID документа
      'type': type.name, // Зберігаємо як рядок
      'title': title,
      'message': message,
      'timestamp': timestamp, // Або FieldValue.serverTimestamp() при створенні
      'isRead': isRead,
      if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      if (relatedEntityType != null) 'relatedEntityType': relatedEntityType,
      if (iconName != null) 'iconName': iconName,
    };
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    Timestamp? timestamp,
    bool? isRead,
    String? relatedEntityId,
    String? relatedEntityType,
    String? iconName,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        timestamp,
        isRead,
        relatedEntityId,
        relatedEntityType,
        iconName,
      ];

  static NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.custom;
    try {
      return NotificationType.values.byName(typeString);
    } catch (e) {
      return NotificationType.custom; // Тип за замовчуванням, якщо розпарсити не вдалося
    }
  }
}