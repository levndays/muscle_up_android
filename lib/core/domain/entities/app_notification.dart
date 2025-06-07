// lib/core/domain/entities/app_notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:muscle_up/l10n/app_localizations.dart';

enum NotificationType {
  achievementUnlocked,
  workoutReminder,
  newFollower,
  routineShared,
  systemMessage,
  advice,
  custom,
}

class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String? title; // Can be null if using loc keys
  final String? message; // Can be null if using loc keys
  final String? titleLocKey;
  final String? messageLocKey;
  final Map<String, String>? messageLocArgs;
  final Timestamp timestamp;
  final bool isRead;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? iconName;
  final String? senderProfilePicUrl;
  final String? senderUsername;


  const AppNotification({
    required this.id,
    required this.type,
    this.title,
    this.message,
    this.titleLocKey,
    this.messageLocKey,
    this.messageLocArgs,
    required this.timestamp,
    this.isRead = false,
    this.relatedEntityId,
    this.relatedEntityType,
    this.iconName,
    this.senderProfilePicUrl,
    this.senderUsername,
  });

  String getLocalizedTitle(BuildContext context) {
    if (titleLocKey == null) return title ?? 'Notification';
    final loc = AppLocalizations.of(context);
    final args = messageLocArgs ?? {};
    switch (titleLocKey) {
      case 'achievement_firstWorkout_title': return loc.achievementFirstWorkoutName;
      case 'achievement_profileSetup_title': return loc.achievementEarlyBirdName;
      case 'notification_newFollower_title': return loc.notificationNewFollowerTitle;
      case 'notification_xpForVoting_title': return loc.notificationXpForVotingTitle;
      case 'notification_recordVerified_title': return loc.notificationRecordVerifiedTitle;
      case 'notification_recordRejected_title': return loc.notificationRecordRejectedTitle;
      case 'notification_recordExpired_title': return loc.notificationRecordExpiredTitle;
      case 'notification_xpForRecord_title': return loc.notificationXpForRecordTitle(args['exerciseName'] ?? '...');
      default: return title ?? titleLocKey!;
    }
  }
  
  String getLocalizedMessage(BuildContext context) {
    if (messageLocKey == null) return message ?? '';
    final loc = AppLocalizations.of(context);
    final args = messageLocArgs ?? {};
    switch (messageLocKey) {
        case 'achievement_firstWorkout_message': return loc.achievementFirstWorkoutDescription;
        case 'achievement_profileSetup_message': return loc.achievementEarlyBirdDescription;
        case 'notification_newFollower_message': return loc.notificationNewFollowerMessage(args['username'] ?? 'Someone');
        case 'notification_xpForVoting_message': return loc.notificationXpForVotingMessage(args['xp'] ?? '0');
        case 'notification_recordVerified_message': return loc.notificationRecordVerifiedMessage(args['exerciseName'] ?? 'exercise', args['weight'] ?? 'N/A', args['reps'] ?? 'N/A');
        case 'notification_recordRejected_message': return loc.notificationRecordRejectedMessage(args['exerciseName'] ?? 'exercise');
        case 'notification_recordExpired_message': return loc.notificationRecordExpiredMessage(args['exerciseName'] ?? 'exercise');
        case 'notification_xpForRecord_message': return loc.notificationXpForRecordMessage(args['xp'] ?? '0', args['exerciseName'] ?? 'Exercise', args['weight'] ?? 'N/A', args['reps'] ?? 'N/A');
        default: return message ?? messageLocKey!;
    }
  }

  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Notification data is null!");

    return AppNotification(
      id: snapshot.id,
      type: _parseNotificationType(data['type'] as String?),
      title: data['title'] as String?,
      message: data['message'] as String?,
      titleLocKey: data['titleLocKey'] as String?,
      messageLocKey: data['messageLocKey'] as String?,
      messageLocArgs: data['messageLocArgs'] != null ? Map<String, String>.from(data['messageLocArgs']) : null,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
      relatedEntityId: data['relatedEntityId'] as String?,
      relatedEntityType: data['relatedEntityType'] as String?,
      iconName: data['iconName'] as String?,
      senderProfilePicUrl: data['senderProfilePicUrl'] as String?,
      senderUsername: data['senderUsername'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'message': message,
      'titleLocKey': titleLocKey,
      'messageLocKey': messageLocKey,
      'messageLocArgs': messageLocArgs,
      'timestamp': timestamp,
      'isRead': isRead,
      if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      if (relatedEntityType != null) 'relatedEntityType': relatedEntityType,
      if (iconName != null) 'iconName': iconName,
      if (senderProfilePicUrl != null) 'senderProfilePicUrl': senderProfilePicUrl,
      if (senderUsername != null) 'senderUsername': senderUsername,
    };
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? titleLocKey,
    String? messageLocKey,
    Map<String, String>? messageLocArgs,
    Timestamp? timestamp,
    bool? isRead,
    String? relatedEntityId,
    String? relatedEntityType,
    String? iconName,
    String? senderProfilePicUrl,
    bool allowNullSenderProfilePicUrl = false,
    String? senderUsername,
    bool allowNullSenderUsername = false,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      titleLocKey: titleLocKey ?? this.titleLocKey,
      messageLocKey: messageLocKey ?? this.messageLocKey,
      messageLocArgs: messageLocArgs ?? this.messageLocArgs,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      iconName: iconName ?? this.iconName,
      senderProfilePicUrl: allowNullSenderProfilePicUrl ? senderProfilePicUrl : (senderProfilePicUrl ?? this.senderProfilePicUrl),
      senderUsername: allowNullSenderUsername ? senderUsername : (senderUsername ?? this.senderUsername),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        titleLocKey,
        messageLocKey,
        messageLocArgs,
        timestamp,
        isRead,
        relatedEntityId,
        relatedEntityType,
        iconName,
        senderProfilePicUrl,
        senderUsername,
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