// lib/core/domain/entities/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'vote_type.dart';

enum PostType {
  standard,
  recordClaim,
  routineShare,
}

enum RecordVerificationStatus {
  pending,
  verified,
  rejected,
  expired,
  contested,
}

class Post extends Equatable {
  final String id;
  final String userId;
  final String authorUsername;
  final String? authorProfilePicUrl;
  final Timestamp timestamp;
  final Timestamp? updatedAt; // Додамо, якщо його немає, або переконаємось, що є
  final PostType type;
  final String textContent;
  final String? mediaUrl;
  final List<String> likedBy;
  final int commentsCount;
  final bool isCommentsEnabled;
  final String? relatedRoutineId;
  final Map<String, dynamic>? routineSnapshot;
  final Map<String, dynamic>? recordDetails;

  final RecordVerificationStatus? recordVerificationStatus;
  final Timestamp? recordVerificationDeadline;
  final bool? isRecordVerified;
  final Map<String, String> verificationVotes;
  final List<String> votedAndRewardedUserIds;

  const Post({
    required this.id,
    required this.userId,
    required this.authorUsername,
    this.authorProfilePicUrl,
    required this.timestamp,
    this.updatedAt, // Додамо
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
    this.recordVerificationStatus,
    this.recordVerificationDeadline,
    this.votedAndRewardedUserIds = const [],
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
            recordStatus = RecordVerificationStatus.pending;
        }
    }

    return Post(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      authorUsername: data['authorUsername'] ?? 'Unknown User',
      authorProfilePicUrl: data['authorProfilePicUrl'] as String?,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp?, // Додамо
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
      recordVerificationStatus: recordStatus,
      recordVerificationDeadline: data['recordVerificationDeadline'] as Timestamp?,
      votedAndRewardedUserIds: List<String>.from(data['votedAndRewardedUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authorUsername': authorUsername,
      'authorProfilePicUrl': authorProfilePicUrl,
      'timestamp': timestamp, 
      'updatedAt': updatedAt, // Додамо
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
      if (recordVerificationStatus != null) 'recordVerificationStatus': recordVerificationStatus!.name,
      if (recordVerificationDeadline != null) 'recordVerificationDeadline': recordVerificationDeadline,
      'votedAndRewardedUserIds': votedAndRewardedUserIds,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? authorUsername,
    String? authorProfilePicUrl,
    bool allowNullAuthorProfilePicUrl = false,
    Timestamp? timestamp,
    Timestamp? updatedAt, // Додамо
    bool allowNullUpdatedAt = false, // Додамо
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
    RecordVerificationStatus? recordVerificationStatus,
    bool allowNullRecordVerificationStatus = false,
    Timestamp? recordVerificationDeadline,
    bool allowNullRecordVerificationDeadline = false,
    List<String>? votedAndRewardedUserIds,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorProfilePicUrl: allowNullAuthorProfilePicUrl ? authorProfilePicUrl : (authorProfilePicUrl ?? this.authorProfilePicUrl),
      timestamp: timestamp ?? this.timestamp,
      updatedAt: allowNullUpdatedAt ? updatedAt : (updatedAt ?? this.updatedAt), // Додамо
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
      recordVerificationStatus: allowNullRecordVerificationStatus ? recordVerificationStatus : (recordVerificationStatus ?? this.recordVerificationStatus),
      recordVerificationDeadline: allowNullRecordVerificationDeadline ? recordVerificationDeadline : (recordVerificationDeadline ?? this.recordVerificationDeadline),
      votedAndRewardedUserIds: votedAndRewardedUserIds ?? this.votedAndRewardedUserIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        authorUsername,
        authorProfilePicUrl,
        timestamp,
        updatedAt, // Додамо
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
        recordVerificationStatus,
        recordVerificationDeadline,
        votedAndRewardedUserIds,
      ];
}