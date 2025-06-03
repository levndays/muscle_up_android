// FILE: lib/core/domain/entities/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueGetter;
import 'achievement.dart'; 

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
  final Timestamp? lastWorkoutTimestamp; 
  final Timestamp? lastScheduledWorkoutCompletionTimestamp; 
  final String? lastScheduledWorkoutDayKey; 

  final int followersCount;
  final int followingCount;
  final List<String> achievedRewardIds;
  final List<String> following; // NEW: List of user IDs this user is following
  // final List<String> followers; // This will be managed by functions, not directly in client model for modification
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
    this.lastWorkoutTimestamp,
    this.lastScheduledWorkoutCompletionTimestamp, 
    this.lastScheduledWorkoutDayKey,         
    this.followersCount = 0,
    this.followingCount = 0,
    this.achievedRewardIds = const [],
    this.following = const [], // NEW: Initialize
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
      lastWorkoutTimestamp: data['lastWorkoutTimestamp'] as Timestamp?,
      lastScheduledWorkoutCompletionTimestamp: data['lastScheduledWorkoutCompletionTimestamp'] as Timestamp?,
      lastScheduledWorkoutDayKey: data['lastScheduledWorkoutDayKey'] as String?,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      achievedRewardIds: List<String>.from(data['achievedRewardIds'] ?? []),
      following: List<String>.from(data['following'] ?? []), // NEW: Parse
      profileSetupComplete: data['profileSetupComplete'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'profileSetupComplete': profileSetupComplete,
      'following': following, // NEW: Include in map for updates by current user
      // These fields are generally managed by server/functions or set on creation
      // 'uid': uid,
      // 'email': email,
      // 'xp': xp,
      // 'level': level,
      // 'currentStreak': currentStreak,
      // 'longestStreak': longestStreak,
      // 'lastWorkoutTimestamp': lastWorkoutTimestamp,
      // 'lastScheduledWorkoutCompletionTimestamp': lastScheduledWorkoutCompletionTimestamp,
      // 'lastScheduledWorkoutDayKey': lastScheduledWorkoutDayKey,
      // 'followersCount': followersCount,
      // 'followingCount': followingCount,
      // 'achievedRewardIds': achievedRewardIds,
      // 'createdAt': createdAt,
      // 'updatedAt': updatedAt, // This will be set by FieldValue.serverTimestamp() in repository
    };
    // Add optional fields only if they are not null to avoid overwriting with null
    if (displayName != null) data['displayName'] = displayName;
    if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
    if (username != null) data['username'] = username;
    if (gender != null) data['gender'] = gender;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
    if (heightCm != null) data['heightCm'] = heightCm;
    if (weightKg != null) data['weightKg'] = weightKg;
    if (fitnessGoal != null) data['fitnessGoal'] = fitnessGoal;
    if (activityLevel != null) data['activityLevel'] = activityLevel;
    
    return data;
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    ValueGetter<String?>? displayName,
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
    ValueGetter<Timestamp?>? lastWorkoutTimestamp,
    ValueGetter<Timestamp?>? lastScheduledWorkoutCompletionTimestamp, 
    ValueGetter<String?>? lastScheduledWorkoutDayKey,             
    int? followersCount,
    int? followingCount,
    List<String>? achievedRewardIds,
    List<String>? following, // NEW
    bool? profileSetupComplete,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
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
      lastWorkoutTimestamp: lastWorkoutTimestamp != null ? lastWorkoutTimestamp() : this.lastWorkoutTimestamp,
      lastScheduledWorkoutCompletionTimestamp: lastScheduledWorkoutCompletionTimestamp != null ? lastScheduledWorkoutCompletionTimestamp() : this.lastScheduledWorkoutCompletionTimestamp,
      lastScheduledWorkoutDayKey: lastScheduledWorkoutDayKey != null ? lastScheduledWorkoutDayKey() : this.lastScheduledWorkoutDayKey,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      achievedRewardIds: achievedRewardIds ?? this.achievedRewardIds,
      following: following ?? this.following, // NEW
      profileSetupComplete: profileSetupComplete ?? this.profileSetupComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid, email, displayName, profilePictureUrl, username, gender, dateOfBirth,
        heightCm, weightKg, fitnessGoal, activityLevel, xp, level,
        currentStreak, longestStreak, lastWorkoutTimestamp,
        lastScheduledWorkoutCompletionTimestamp, lastScheduledWorkoutDayKey, 
        followersCount, followingCount,
        achievedRewardIds, 
        following, // NEW
        profileSetupComplete, createdAt, updatedAt
      ];
}