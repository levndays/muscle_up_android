// lib/core/domain/entities/comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String authorUsername;
  final String? authorProfilePicUrl;
  final String text;
  final Timestamp timestamp;
  // Можна додати поле `likedBy` для лайків коментарів у майбутньому

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorUsername,
    this.authorProfilePicUrl,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Comment data is null!");

    return Comment(
      id: snapshot.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      authorUsername: data['authorUsername'] ?? 'Unknown User',
      authorProfilePicUrl: data['authorProfilePicUrl'] as String?,
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'authorUsername': authorUsername,
      'authorProfilePicUrl': authorProfilePicUrl,
      'text': text,
      'timestamp': timestamp, // Або FieldValue.serverTimestamp() при створенні
    };
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        authorUsername,
        authorProfilePicUrl,
        text,
        timestamp,
      ];
}