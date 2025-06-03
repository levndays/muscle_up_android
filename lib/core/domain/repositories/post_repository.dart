// lib/core/domain/repositories/post_repository.dart
import '../entities/post.dart';
import '../entities/comment.dart';

abstract class PostRepository {
  Future<void> createPost(Post post);
  Stream<List<Post>> getAllPostsStream({int limit = 20});
  Future<Post?> getPostById(String postId);
  Stream<Post?> getPostStreamById(String postId);
  Future<void> updatePostSettings(String postId, {required bool isCommentsEnabled}); // <-- Новий/оновлений метод
  // Future<void> deletePost(String postId);

  // Лайки
  Future<void> addLike(String postId, String userId);
  Future<void> removeLike(String postId, String userId);

  // Коментарі
  Future<void> addComment(Comment comment);
  Stream<List<Comment>> getCommentsStream(String postId, {int limit = 20});
  Future<void> updateComment(Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}