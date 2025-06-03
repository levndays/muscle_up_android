// lib/core/domain/entities/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PostType {
  standard,
  recordClaim,
  routineShare,
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
  final List<String> likedBy; // Зберігаємо ID користувачів, які лайкнули
  final int commentsCount; // Лічильник коментарів (буде оновлюватися функцією або на клієнті)
  final bool isCommentsEnabled;
  final String? relatedRoutineId;
  final Map<String, dynamic>? routineSnapshot;
  final Map<String, dynamic>? recordDetails;
  final bool? isRecordVerified;

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
  });

  // Getter для кількості лайків
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authorUsername': authorUsername,
      'authorProfilePicUrl': authorProfilePicUrl,
      'timestamp': timestamp,
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
      ];
}