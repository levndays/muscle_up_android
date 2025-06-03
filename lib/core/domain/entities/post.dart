// lib/core/domain/entities/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'vote_type.dart';

enum PostType {
  standard,
  recordClaim,
  routineShare,
}

// NEW: Enum for record claim verification status
enum RecordVerificationStatus {
  pending,    // Default state, awaiting votes/deadline
  verified,   // Successfully verified
  rejected,   // Rejected by votes or timeout without consensus
  expired,    // Voting window closed without enough votes for consensus (can be merged with rejected)
  contested,  // (Optional) If there's a strong dispute
}

class Post extends Equatable {
  final String id;
  final String userId;
  final String authorUsername;
  final String? authorProfilePicUrl;
  final Timestamp timestamp;
  final PostType type;
  final String textContent;
  final String? mediaUrl;
  final List<String> likedBy;
  final int commentsCount;
  final bool isCommentsEnabled;
  final String? relatedRoutineId;
  final Map<String, dynamic>? routineSnapshot;
  final Map<String, dynamic>? recordDetails; // e.g., { exerciseId, exerciseName, weightKg, reps, videoUrl }

  // Fields for Record Claim Verification
  final RecordVerificationStatus? recordVerificationStatus; // NEW
  final Timestamp? recordVerificationDeadline; // NEW
  final bool? isRecordVerified; // This will reflect the final outcome of recordVerificationStatus
  final Map<String, String> verificationVotes;
  final List<String> votedAndRewardedUserIds; // NEW: Users who got XP for voting on this post

  const Post({
    required this.id,
    required this.userId,
    required this.authorUsername,
    this.authorProfilePicUrl,
    required this.timestamp,
    required this.type,
    required this.textContent,
    this.mediaUrl,
    this.likedBy = const [],
    this.commentsCount = 0,
    this.isCommentsEnabled = true,
    this.relatedRoutineId,
    this.routineSnapshot,
    this.recordDetails,
    this.isRecordVerified,
    this.verificationVotes = const {},
    this.recordVerificationStatus, // NEW
    this.recordVerificationDeadline, // NEW
    this.votedAndRewardedUserIds = const [], // NEW
  });

  int get likesCount => likedBy.length;

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Post data is null!");

    PostType postType;
    try {
      postType = PostType.values.byName(data['type'] ?? 'standard');
    } catch (_) {
      postType = PostType.standard;
    }

    RecordVerificationStatus? recordStatus;
    if (data['recordVerificationStatus'] != null) {
        try {
            recordStatus = RecordVerificationStatus.values.byName(data['recordVerificationStatus']);
        } catch (_) {
            recordStatus = RecordVerificationStatus.pending; // Default or handle error
        }
    }

    return Post(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      authorUsername: data['authorUsername'] ?? 'Unknown User',
      authorProfilePicUrl: data['authorProfilePicUrl'] as String?,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      type: postType,
      textContent: data['textContent'] ?? '',
      mediaUrl: data['mediaUrl'] as String?,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      isCommentsEnabled: data['isCommentsEnabled'] ?? true,
      relatedRoutineId: data['relatedRoutineId'] as String?,
      routineSnapshot: data['routineSnapshot'] as Map<String, dynamic>?,
      recordDetails: data['recordDetails'] as Map<String, dynamic>?,
      isRecordVerified: data['isRecordVerified'] as bool?,
      verificationVotes: Map<String, String>.from(data['verificationVotes'] ?? {}),
      recordVerificationStatus: recordStatus, // NEW
      recordVerificationDeadline: data['recordVerificationDeadline'] as Timestamp?, // NEW
      votedAndRewardedUserIds: List<String>.from(data['votedAndRewardedUserIds'] ?? []), // NEW
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authorUsername': authorUsername,
      'authorProfilePicUrl': authorProfilePicUrl,
      'timestamp': timestamp, // Will be FieldValue.serverTimestamp() on create/update
      'type': type.name,
      'textContent': textContent,
      'mediaUrl': mediaUrl,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'isCommentsEnabled': isCommentsEnabled,
      'relatedRoutineId': relatedRoutineId,
      'routineSnapshot': routineSnapshot,
      'recordDetails': recordDetails,
      'isRecordVerified': isRecordVerified,
      'verificationVotes': verificationVotes,
      if (recordVerificationStatus != null) 'recordVerificationStatus': recordVerificationStatus!.name, // NEW
      if (recordVerificationDeadline != null) 'recordVerificationDeadline': recordVerificationDeadline, // NEW
      'votedAndRewardedUserIds': votedAndRewardedUserIds, // NEW
      // 'updatedAt' should be handled by FieldValue.serverTimestamp() in repository
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? authorUsername,
    String? authorProfilePicUrl,
    bool allowNullAuthorProfilePicUrl = false,
    Timestamp? timestamp,
    PostType? type,
    String? textContent,
    String? mediaUrl,
    bool allowNullMediaUrl = false,
    List<String>? likedBy,
    int? commentsCount,
    bool? isCommentsEnabled,
    String? relatedRoutineId,
    bool allowNullRelatedRoutineId = false,
    Map<String, dynamic>? routineSnapshot,
    bool allowNullRoutineSnapshot = false,
    Map<String, dynamic>? recordDetails,
    bool allowNullRecordDetails = false,
    bool? isRecordVerified,
    bool allowNullIsRecordVerified = false,
    Map<String, String>? verificationVotes,
    RecordVerificationStatus? recordVerificationStatus, // NEW
    bool allowNullRecordVerificationStatus = false, // NEW
    Timestamp? recordVerificationDeadline, // NEW
    bool allowNullRecordVerificationDeadline = false, // NEW
    List<String>? votedAndRewardedUserIds, // NEW
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorProfilePicUrl: allowNullAuthorProfilePicUrl ? authorProfilePicUrl : (authorProfilePicUrl ?? this.authorProfilePicUrl),
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      mediaUrl: allowNullMediaUrl ? mediaUrl : (mediaUrl ?? this.mediaUrl),
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      isCommentsEnabled: isCommentsEnabled ?? this.isCommentsEnabled,
      relatedRoutineId: allowNullRelatedRoutineId ? relatedRoutineId : (relatedRoutineId ?? this.relatedRoutineId),
      routineSnapshot: allowNullRoutineSnapshot ? routineSnapshot : (routineSnapshot ?? this.routineSnapshot),
      recordDetails: allowNullRecordDetails ? recordDetails : (recordDetails ?? this.recordDetails),
      isRecordVerified: allowNullIsRecordVerified ? isRecordVerified : (isRecordVerified ?? this.isRecordVerified),
      verificationVotes: verificationVotes ?? this.verificationVotes,
      recordVerificationStatus: allowNullRecordVerificationStatus ? recordVerificationStatus : (recordVerificationStatus ?? this.recordVerificationStatus), // NEW
      recordVerificationDeadline: allowNullRecordVerificationDeadline ? recordVerificationDeadline : (recordVerificationDeadline ?? this.recordVerificationDeadline), // NEW
      votedAndRewardedUserIds: votedAndRewardedUserIds ?? this.votedAndRewardedUserIds, // NEW
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        authorUsername,
        authorProfilePicUrl,
        timestamp,
        type,
        textContent,
        mediaUrl,
        likedBy,
        commentsCount,
        isCommentsEnabled,
        relatedRoutineId,
        routineSnapshot,
        recordDetails,
        isRecordVerified,
        verificationVotes,
        recordVerificationStatus, // NEW
        recordVerificationDeadline, // NEW
        votedAndRewardedUserIds, // NEW
      ];
}