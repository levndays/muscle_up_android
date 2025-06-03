// lib/core/domain/entities/app_notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType {
  achievementUnlocked,
  workoutReminder,
  newFollower,         // NEW: Added new follower notification type
  routineShared,
  systemMessage,
  advice,
  custom,
}

class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? iconName;
  final String? senderProfilePicUrl; // NEW: Optional, for follower notifications
  final String? senderUsername;      // NEW: Optional, for follower notifications


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
    this.senderProfilePicUrl, // NEW
    this.senderUsername,      // NEW
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
      senderProfilePicUrl: data['senderProfilePicUrl'] as String?, // NEW
      senderUsername: data['senderUsername'] as String?,           // NEW
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      if (relatedEntityType != null) 'relatedEntityType': relatedEntityType,
      if (iconName != null) 'iconName': iconName,
      if (senderProfilePicUrl != null) 'senderProfilePicUrl': senderProfilePicUrl, // NEW
      if (senderUsername != null) 'senderUsername': senderUsername,               // NEW
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
    String? senderProfilePicUrl, // NEW
    bool allowNullSenderProfilePicUrl = false, // NEW
    String? senderUsername,      // NEW
    bool allowNullSenderUsername = false, // NEW
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
      senderProfilePicUrl: allowNullSenderProfilePicUrl ? senderProfilePicUrl : (senderProfilePicUrl ?? this.senderProfilePicUrl), // NEW
      senderUsername: allowNullSenderUsername ? senderUsername : (senderUsername ?? this.senderUsername),                         // NEW
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
        senderProfilePicUrl, // NEW
        senderUsername,      // NEW
      ];

  static NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.custom;
    try {
      return NotificationType.values.byName(typeString);
    } catch (e) {
      return NotificationType.custom;
    }
  }
}