// lib/core/domain/repositories/post_repository.dart
import '../entities/post.dart';
import '../entities/comment.dart';
import '../entities/vote_type.dart'; // <-- NEW IMPORT

abstract class PostRepository {
  Future<void> createPost(Post post);
  Stream<List<Post>> getAllPostsStream({int limit = 20});
  Future<Post?> getPostById(String postId);
  Stream<Post?> getPostStreamById(String postId);
  Future<void> updatePostSettings(String postId, {required bool isCommentsEnabled});
  // Future<void> deletePost(String postId); // Keep commented if not implemented

  // Likes
  Future<void> addLike(String postId, String userId);
  Future<void> removeLike(String postId, String userId);

  // Comments
  Future<void> addComment(Comment comment);
  Stream<List<Comment>> getCommentsStream(String postId, {int limit = 20});
  Future<void> updateComment(Comment comment);
  Future<void> deleteComment(String postId, String commentId);

  // NEW: Record Claim Votes
  Future<void> castVote(String postId, String userId, VoteType voteType);
  Future<void> retractVote(String postId, String userId); // Optional: if users can remove their vote
}