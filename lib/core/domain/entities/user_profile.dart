// lib/core/domain/entities/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueGetter; // Потрібно для ValueGetter

class UserProfile extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? profilePictureUrl;
  final String? username;
  final String? gender;
  final Timestamp? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessGoal;
  final String? activityLevel;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final Timestamp? lastWorkoutTimestamp; // <--- ДОДАНО ЦЕ ПОЛЕ
  final bool profileSetupComplete;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.profilePictureUrl,
    this.username,
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.activityLevel,
    required this.xp,
    required this.level,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutTimestamp, // <--- ДОДАНО
    required this.profileSetupComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("User profile data is null!");
    return UserProfile(
      uid: snapshot.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      username: data['username'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth: data['dateOfBirth'] as Timestamp?,
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      fitnessGoal: data['fitnessGoal'] as String?,
      activityLevel: data['activityLevel'] as String?,
      xp: data['xp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastWorkoutTimestamp: data['lastWorkoutTimestamp'] as Timestamp?, // <--- ЗЧИТУВАННЯ
      profileSetupComplete: data['profileSetupComplete'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Зазвичай uid не зберігається в полях документа, а є його ID
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (username != null) 'username': username,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (heightCm != null) 'heightCm': heightCm,
      if (weightKg != null) 'weightKg': weightKg,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      if (activityLevel != null) 'activityLevel': activityLevel,
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      if (lastWorkoutTimestamp != null) 'lastWorkoutTimestamp': lastWorkoutTimestamp, // <--- ЗАПИС
      'profileSetupComplete': profileSetupComplete,
      // createdAt і updatedAt зазвичай оновлюються через FieldValue.serverTimestamp()
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    ValueGetter<String?>? displayName, // Використання ValueGetter для nullable полів
    ValueGetter<String?>? profilePictureUrl,
    ValueGetter<String?>? username,
    ValueGetter<String?>? gender,
    ValueGetter<Timestamp?>? dateOfBirth,
    ValueGetter<double?>? heightCm,
    ValueGetter<double?>? weightKg,
    ValueGetter<String?>? fitnessGoal,
    ValueGetter<String?>? activityLevel,
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    ValueGetter<Timestamp?>? lastWorkoutTimestamp, // <--- ДОДАНО ValueGetter
    bool? profileSetupComplete,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email, // email зазвичай не змінюється через copyWith, а береться з auth
      displayName: displayName != null ? displayName() : this.displayName,
      profilePictureUrl: profilePictureUrl != null ? profilePictureUrl() : this.profilePictureUrl,
      username: username != null ? username() : this.username,
      gender: gender != null ? gender() : this.gender,
      dateOfBirth: dateOfBirth != null ? dateOfBirth() : this.dateOfBirth,
      heightCm: heightCm != null ? heightCm() : this.heightCm,
      weightKg: weightKg != null ? weightKg() : this.weightKg,
      fitnessGoal: fitnessGoal != null ? fitnessGoal() : this.fitnessGoal,
      activityLevel: activityLevel != null ? activityLevel() : this.activityLevel,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutTimestamp: lastWorkoutTimestamp != null ? lastWorkoutTimestamp() : this.lastWorkoutTimestamp, // <--- ОНОВЛЕНО
      profileSetupComplete: profileSetupComplete ?? this.profileSetupComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid, email, displayName, profilePictureUrl, username, gender, dateOfBirth,
        heightCm, weightKg, fitnessGoal, activityLevel, xp, level,
        currentStreak, longestStreak, lastWorkoutTimestamp, // <--- ДОДАНО
        profileSetupComplete, createdAt, updatedAt
      ];
}