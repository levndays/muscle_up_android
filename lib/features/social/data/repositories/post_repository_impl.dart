// lib/features/social/data/repositories/post_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/entities/comment.dart';
import '../../../../core/domain/entities/vote_type.dart'; // <-- NEW IMPORT
import '../../../../core/domain/repositories/post_repository.dart';
import 'dart:developer' as developer;

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore;

  PostRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection('posts');

  CollectionReference<Map<String, dynamic>> _commentsCollection(String postId) =>
      _postsCollection.doc(postId).collection('comments');

  @override
  Future<void> createPost(Post post) async {
    try {
      final docRef = _postsCollection.doc();
      final postWithId = post.copyWith(
        id: docRef.id,
      );
      Map<String, dynamic> postData = postWithId.toMap();
      postData['timestamp'] = FieldValue.serverTimestamp();
      postData['updatedAt'] = FieldValue.serverTimestamp(); // Also set updatedAt on creation

      await docRef.set(postData);
      developer.log('Post created with ID: ${docRef.id}', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error creating post: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Stream<List<Post>> getAllPostsStream({int limit = 20}) {
    developer.log('Subscribing to all posts stream (limit: $limit)', name: 'PostRepositoryImpl');
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      developer.log('Received ${snapshot.docs.length} posts from stream', name: 'PostRepositoryImpl');
      return snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .toList();
    }).handleError((error, stackTrace) {
      developer.log('Error in all posts stream: $error', name: 'PostRepositoryImpl', error: error, stackTrace: stackTrace);
      return <Post>[];
    });
  }

  @override
  Future<Post?> getPostById(String postId) async {
    try {
      final docSnapshot = await _postsCollection.doc(postId).get();
      if (docSnapshot.exists) {
        return Post.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e, s) {
      developer.log('Error fetching post by ID $postId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to fetch post: ${e.toString()}');
    }
  }

  @override
  Stream<Post?> getPostStreamById(String postId) {
    return _postsCollection.doc(postId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Post.fromFirestore(snapshot);
      }
      return null;
    }).handleError((error, stackTrace) {
       developer.log('Error in post stream for ID $postId: $error', name: 'PostRepositoryImpl', error: error, stackTrace: stackTrace);
       return null;
    });
  }

  @override
  Future<void> updatePostSettings(String postId, {required bool isCommentsEnabled}) async {
    try {
      await _postsCollection.doc(postId).update({
        'isCommentsEnabled': isCommentsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('Post $postId settings updated: isCommentsEnabled -> $isCommentsEnabled', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error updating post settings for $postId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to update post settings: ${e.toString()}');
    }
  }

  @override
  Future<void> addLike(String postId, String userId) async {
    try {
      await _postsCollection.doc(postId).update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('User $userId liked post $postId', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error adding like to post $postId by user $userId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to like post: ${e.toString()}');
    }
  }

  @override
  Future<void> removeLike(String postId, String userId) async {
    try {
      await _postsCollection.doc(postId).update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('User $userId unliked post $postId', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error removing like from post $postId by user $userId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to unlike post: ${e.toString()}');
    }
  }

  @override
  Future<void> addComment(Comment comment) async {
    try {
      final commentDocRef = _commentsCollection(comment.postId).doc();
      final commentWithIdMap = comment.toMap()
        ..['id'] = commentDocRef.id
        ..['timestamp'] = FieldValue.serverTimestamp();

      await commentDocRef.set(commentWithIdMap);
      await _postsCollection.doc(comment.postId).update({'updatedAt': FieldValue.serverTimestamp()});
      developer.log('Comment added to post ${comment.postId} by user ${comment.userId}. commentsCount will be updated by Cloud Function.', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error adding comment to post ${comment.postId}: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Stream<List<Comment>> getCommentsStream(String postId, {int limit = 20}) {
    return _commentsCollection(postId)
        .orderBy('timestamp', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    }).handleError((error, stackTrace) {
      developer.log('Error in comments stream for post $postId: $error', name: 'PostRepositoryImpl', error: error, stackTrace: stackTrace);
      return <Comment>[];
    });
  }

  @override
  Future<void> updateComment(Comment comment) async {
    if (comment.id.isEmpty || comment.postId.isEmpty) {
      throw ArgumentError("Comment ID and Post ID cannot be empty for update.");
    }
    try {
      final Map<String, dynamic> updateData = {
        'text': comment.text,
        'timestamp': FieldValue.serverTimestamp(), // Update timestamp on edit
      };
      await _commentsCollection(comment.postId).doc(comment.id).update(updateData);
      await _postsCollection.doc(comment.postId).update({'updatedAt': FieldValue.serverTimestamp()});
      developer.log('Comment ${comment.id} on post ${comment.postId} updated.', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error updating comment ${comment.id} on post ${comment.postId}: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to update comment: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    if (postId.isEmpty || commentId.isEmpty) {
      throw ArgumentError("Post ID and Comment ID cannot be empty for deletion.");
    }
    try {
      await _commentsCollection(postId).doc(commentId).delete();
      await _postsCollection.doc(postId).update({'updatedAt': FieldValue.serverTimestamp()});
      developer.log('Comment $commentId on post $postId deleted.', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error deleting comment $commentId on post $postId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to delete comment: ${e.toString()}');
    }
  }

  // NEW IMPLEMENTATION for Record Claim Votes
  @override
  Future<void> castVote(String postId, String userId, VoteType voteType) async {
    try {
      await _postsCollection.doc(postId).update({
        'verificationVotes.$userId': voteTypeToString(voteType), // "verificationVotes.userId"
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('User $userId cast vote "${voteTypeToString(voteType)}" for post $postId', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error casting vote for post $postId by user $userId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to cast vote: ${e.toString()}');
    }
  }

  @override
  Future<void> retractVote(String postId, String userId) async {
    try {
      await _postsCollection.doc(postId).update({
        'verificationVotes.$userId': FieldValue.delete(), // Remove the user's vote field
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('User $userId retracted vote for post $postId', name: 'PostRepositoryImpl');
    } catch (e, s) {
      developer.log('Error retracting vote for post $postId by user $userId: $e', name: 'PostRepositoryImpl', error: e, stackTrace: s);
      throw Exception('Failed to retract vote: ${e.toString()}');
    }
  }
}