// lib/features/social/presentation/cubit/post_interaction_cubit.dart
import 'dart:async';
import 'dart:io'; // NEW: For File type in updatePost
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart' as fb_storage; // NEW
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/entities/comment.dart';
import '../../../../core/domain/entities/vote_type.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer;

part 'post_interaction_state.dart';

class PostInteractionCubit extends Cubit<PostInteractionState> {
  final PostRepository _postRepository;
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  final String postId;

  StreamSubscription<Post?>? _postSubscription;
  StreamSubscription<List<Comment>>? _commentsSubscription;

  PostInteractionCubit(
    this._postRepository,
    this._userProfileRepository,
    this._firebaseAuth,
    this.postId,
    Post initialPost,
  ) : super(PostInteractionInitial(initialPost)) {
    _subscribeToPostUpdates();
  }

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  VoteType? _getCurrentUserVote(Post post) {
    final userId = _currentUserId;
    if (userId == null || !post.verificationVotes.containsKey(userId)) {
      return null;
    }
    return stringToVoteType(post.verificationVotes[userId]);
  }

  void _subscribeToPostUpdates() {
    Post? postForLoadingState = _getCurrentPostFromState();
    if (postForLoadingState == null && state is PostInteractionInitial) {
      postForLoadingState = (state as PostInteractionInitial).post;
    }
    if (postForLoadingState == null) {
       developer.log('PostInteractionCubit: ERROR - postForLoadingState is null in _subscribeToPostUpdates for $postId', name: 'PostInteractionCubit');
       emit(const PostInteractionFailure("Internal error: Post data unavailable for subscription."));
       return;
    }

    if (state is PostInteractionInitial || (state is PostInteractionLoading && (state as PostInteractionLoading).post.id != postId)) {
        emit(PostInteractionLoading(postForLoadingState));
    }
    
    _postSubscription?.cancel();
    _postSubscription = _postRepository.getPostStreamById(postId).listen(
      (updatedPost) {
        if (updatedPost != null) {
          final currentUserVote = _getCurrentUserVote(updatedPost);
          List<Comment> currentComments = [];
          if (state is PostCommentsLoaded) {
            currentComments = (state as PostCommentsLoaded).comments;
            emit(PostCommentsLoaded(updatedPost, currentComments, currentUserVote: currentUserVote));
          } else {
             emit(PostUpdated(updatedPost, currentUserVote: currentUserVote));
          }
          developer.log('PostInteractionCubit: Post $postId updated by stream. User vote: $currentUserVote', name: 'PostInteractionCubit');
        } else {
          developer.log('PostInteractionCubit: Post $postId not found or deleted by stream.', name: 'PostInteractionCubit');
          emit(const PostInteractionFailure("Post not found. It might have been deleted."));
        }
      },
      onError: (error, stackTrace) {
        developer.log('PostInteractionCubit: Error in post stream for $postId: $error', name: 'PostInteractionCubit', error: error, stackTrace: stackTrace);
        emit(PostInteractionFailure("Error loading post: ${error.toString()}", post: _getCurrentPostFromState()));
      },
    );
  }

  Future<void> toggleLike() async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(PostInteractionFailure("User not logged in.", post: _getCurrentPostFromState()));
      return;
    }

    Post? currentPost = _getCurrentPostFromState();
    if (currentPost == null) {
      emit(const PostInteractionFailure("Post data not available for like action."));
      return;
    }

    final bool isLiked = currentPost.likedBy.contains(userId);
    List<String> newLikedBy = List.from(currentPost.likedBy);
    if (isLiked) {
      newLikedBy.remove(userId);
    } else {
      newLikedBy.add(userId);
    }
    final optimisticPost = currentPost.copyWith(likedBy: newLikedBy);
    _emitUpdatedStateWithPost(optimisticPost); 

    try {
      if (isLiked) {
        await _postRepository.removeLike(postId, userId);
      } else {
        await _postRepository.addLike(postId, userId);
      }
      developer.log('PostInteractionCubit: Like toggled for post $postId by user $userId', name: 'PostInteractionCubit');
    } catch (e, s) {
      developer.log('PostInteractionCubit: Error toggling like: $e', name: 'PostInteractionCubit', error: e, stackTrace: s);
      _emitUpdatedStateWithPost(currentPost);
      emit(PostInteractionFailure("Failed to update like: ${e.toString()}", post: currentPost));
    }
  }

  Future<void> castVote(VoteType voteType) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(PostInteractionFailure("User not logged in to vote.", post: _getCurrentPostFromState()));
      return;
    }
    Post? currentPost = _getCurrentPostFromState();
    if (currentPost == null) {
      emit(const PostInteractionFailure("Post data not available for vote action."));
      return;
    }
    if (currentPost.type != PostType.recordClaim) {
      emit(PostInteractionFailure("Can only vote on record claims.", post: currentPost));
      return;
    }
    if (currentPost.userId == userId) {
      emit(PostInteractionFailure("You cannot vote on your own record claim.", post: currentPost));
      return;
    }

    final Map<String, String> newVotes = Map.from(currentPost.verificationVotes);
    final String voteString = voteTypeToString(voteType);
    
    bool shouldRetract = newVotes[userId] == voteString;

    if (shouldRetract) {
      newVotes.remove(userId);
    } else {
      newVotes[userId] = voteString;
    }
    
    final optimisticPost = currentPost.copyWith(verificationVotes: newVotes);
    _emitUpdatedStateWithPost(optimisticPost);

    try {
      if (shouldRetract) {
        await _postRepository.retractVote(postId, userId);
        developer.log('User $userId retracted vote ${voteType.name} for post $postId', name: 'PostInteractionCubit');
      } else {
        await _postRepository.castVote(postId, userId, voteType);
        developer.log('User $userId cast vote ${voteType.name} for post $postId', name: 'PostInteractionCubit');
      }
    } catch (e) {
      developer.log('Error casting/retracting vote: $e', name: 'PostInteractionCubit');
      _emitUpdatedStateWithPost(currentPost);
      emit(PostInteractionFailure("Failed to ${shouldRetract ? 'retract' : 'cast'} vote: ${e.toString()}", post: currentPost));
    }
  }

  Future<String?> _uploadPostMedia(String userId, String postId, File imageFile) async {
    try {
      final storageRef = fb_storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(userId)
          .child('$postId.jpg'); 
      
      final uploadTask = storageRef.putFile(imageFile, fb_storage.SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log("PostInteractionCubit: Error uploading post media during update: $e", name: "PostInteractionCubit");
      return null;
    }
  }

  Future<void> updatePostText(String newTextContent, {File? newMediaImageFile, bool removeExistingMedia = false}) async { // NEW METHOD
    final userId = _currentUserId;
    Post? currentPost = _getCurrentPostFromState();

    if (userId == null || currentPost == null || currentPost.userId != userId) {
      emit(PostInteractionFailure("Cannot update post: Not authorized or post not found.", post: currentPost));
      return;
    }
    if (newTextContent.trim().isEmpty && newMediaImageFile == null && (currentPost.mediaUrl == null || removeExistingMedia) ) {
      emit(PostInteractionFailure("Post content cannot be empty.", post: currentPost));
      return;
    }

    emit(PostUpdating(currentPost));
    developer.log('PostInteractionCubit: Attempting to update post $postId', name: 'PostInteractionCubit');

    String? finalMediaUrl = currentPost.mediaUrl;

    try {
      if (newMediaImageFile != null) {
        finalMediaUrl = await _uploadPostMedia(userId, postId, newMediaImageFile);
        if (finalMediaUrl == null) {
          emit(PostInteractionFailure("Failed to upload new media. Post not updated.", post: currentPost));
          return;
        }
      } else if (removeExistingMedia) {
        if (currentPost.mediaUrl != null) {
          try {
            final storageRef = fb_storage.FirebaseStorage.instance.refFromURL(currentPost.mediaUrl!);
            await storageRef.delete();
            developer.log('PostInteractionCubit: Deleted existing media for post $postId during update.', name: 'PostInteractionCubit');
          } catch (e) {
            developer.log('PostInteractionCubit: Failed to delete existing media for post $postId during update: $e', name: 'PostInteractionCubit');
            // Можна продовжити, якщо видалення медіа не критичне, або повернути помилку
          }
        }
        finalMediaUrl = null; // Явно встановлюємо null
      }

      final updatedPostData = currentPost.copyWith(
        textContent: newTextContent.trim(),
        mediaUrl: finalMediaUrl,
        allowNullMediaUrl: true, // Дозволяємо встановлення null, якщо removeExistingMedia=true
        updatedAt: Timestamp.now(), // Локально, сервер перезапише
        allowNullUpdatedAt: false,
      );

      await _postRepository.updatePost(updatedPostData);
      // Стрім автоматично оновить стан на PostUpdated/PostCommentsLoaded
      developer.log('PostInteractionCubit: Post $postId updated successfully.', name: 'PostInteractionCubit');
    } catch (e, s) {
      developer.log('PostInteractionCubit: Error updating post $postId: $e', name: 'PostInteractionCubit', error: e, stackTrace: s);
      emit(PostInteractionFailure("Failed to update post: ${e.toString()}", post: currentPost));
    }
  }

  Future<void> deletePost() async { // NEW METHOD
    final userId = _currentUserId;
    Post? currentPost = _getCurrentPostFromState();

    if (userId == null || currentPost == null || currentPost.userId != userId) {
      emit(PostInteractionFailure("Cannot delete post: Not authorized or post not found.", post: currentPost));
      return;
    }

    emit(PostDeleting(currentPost));
    developer.log('PostInteractionCubit: Attempting to delete post $postId', name: 'PostInteractionCubit');

    try {
      await _postRepository.deletePost(postId);
      // Firestore listener на колекції постів (в ExploreFeedCubit / UserPostsFeedCubit)
      // має автоматично видалити цей пост зі списку.
      // Тут ми просто повідомляємо, що видалення було успішним.
      emit(PostDeletedSuccessfully(postId));
      developer.log('PostInteractionCubit: Post $postId deleted successfully.', name: 'PostInteractionCubit');
    } catch (e, s) {
      developer.log('PostInteractionCubit: Error deleting post $postId: $e', name: 'PostInteractionCubit', error: e, stackTrace: s);
      emit(PostInteractionFailure("Failed to delete post: ${e.toString()}", post: currentPost));
    }
  }


  void _emitUpdatedStateWithPost(Post post) {
    final currentUserVote = _getCurrentUserVote(post);
    if (state is PostCommentsLoaded) {
      emit(PostCommentsLoaded(post, (state as PostCommentsLoaded).comments, currentUserVote: currentUserVote));
    } else {
      emit(PostUpdated(post, currentUserVote: currentUserVote));
    }
  }

  Future<void> addComment(String text) async {
      final userId = _currentUserId;
      if (userId == null) {
        emit(PostInteractionFailure("User not logged in.", post: _getCurrentPostFromState()));
        return;
      }
      Post? currentPost = _getCurrentPostFromState();
       if (currentPost == null) {
        emit(const PostInteractionFailure("Post data not available for comment action."));
        return;
      }

      final UserProfile? userProfile = await _userProfileRepository.getUserProfile(userId);
      if (userProfile == null) {
        emit(PostInteractionFailure("Could not fetch user profile to add comment.", post: currentPost));
        return;
      }

      final comment = Comment(
        id: '',
        postId: postId,
        userId: userId,
        authorUsername: userProfile.username ?? userProfile.displayName ?? 'User',
        authorProfilePicUrl: userProfile.profilePictureUrl,
        text: text,
        timestamp: Timestamp.now(),
      );

      try {
        await _postRepository.addComment(comment);
        developer.log('PostInteractionCubit: Comment added to post $postId. Firestore listener should update comments list and count.', name: 'PostInteractionCubit');
      } catch (e, s) {
         developer.log('PostInteractionCubit: Error adding comment: $e', name: 'PostInteractionCubit', error: e, stackTrace: s);
         emit(PostInteractionFailure("Failed to add comment: ${e.toString()}", post: currentPost));
      }
  }

  void fetchComments() {
    Post? currentPost = _getCurrentPostFromState();
    if (currentPost == null) {
      developer.log('PostInteractionCubit: Cannot fetch comments, currentPost is null for $postId', name: 'PostInteractionCubit');
      emit(const PostInteractionFailure("Post data not available to fetch comments."));
      return;
    }
    
    if (state is! PostCommentsLoaded && state is! PostUpdated) {
        emit(PostInteractionLoading(currentPost));
    }

    _commentsSubscription?.cancel();
    _commentsSubscription = _postRepository.getCommentsStream(postId).listen(
      (comments) {
        Post? latestPost = _getCurrentPostFromState() ?? currentPost; 
        final currentUserVote = _getCurrentUserVote(latestPost!);
        emit(PostCommentsLoaded(latestPost, comments, currentUserVote: currentUserVote));
        developer.log('PostInteractionCubit: Loaded ${comments.length} comments for post $postId', name: 'PostInteractionCubit');
      },
      onError: (error, stackTrace) {
        developer.log('PostInteractionCubit: Error fetching comments for $postId: $error', name: 'PostInteractionCubit', error: error, stackTrace: stackTrace);
        emit(PostInteractionFailure("Error loading comments: ${error.toString()}", post: currentPost));
      },
    );
  }

  Future<void> updateComment(String commentId, String newText) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(PostInteractionFailure("User not logged in.", post: _getCurrentPostFromState()));
      return;
    }
    Post? post = _getCurrentPostFromState();
    if (post == null) return;

    Comment? originalComment;
    List<Comment> currentComments = [];
    if (state is PostCommentsLoaded) {
        currentComments = (state as PostCommentsLoaded).comments;
        try {
            originalComment = currentComments.firstWhere((c) => c.id == commentId);
        } catch (e) { /* Comment not found */ }
    }
    if (originalComment == null || originalComment.userId != userId) {
        emit(PostInteractionFailure("Cannot edit this comment.", post: post));
        return;
    }

    final updatedComment = Comment(
        id: commentId,
        postId: postId,
        userId: userId,
        authorUsername: originalComment.authorUsername,
        authorProfilePicUrl: originalComment.authorProfilePicUrl,
        text: newText,
        timestamp: Timestamp.now(),
    );

    final optimisticComments = currentComments.map((c) => c.id == commentId ? updatedComment : c).toList();
    final currentUserVote = _getCurrentUserVote(post);
    emit(PostCommentsLoaded(post, optimisticComments, currentUserVote: currentUserVote));

    try {
        await _postRepository.updateComment(updatedComment);
        developer.log('PostInteractionCubit: Comment $commentId updated.', name: 'PostInteractionCubit');
    } catch (e) {
        developer.log('PostInteractionCubit: Error updating comment $commentId: $e', name: 'PostInteractionCubit');
        emit(PostInteractionFailure("Failed to update comment: ${e.toString()}", post: post));
        if (state is PostCommentsLoaded) emit(PostCommentsLoaded(post, currentComments, currentUserVote: currentUserVote));
    }
  }

  Future<void> deleteComment(String commentId) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(PostInteractionFailure("User not logged in.", post: _getCurrentPostFromState()));
      return;
    }
    Post? post = _getCurrentPostFromState();
    if (post == null) return;

    if (state is PostCommentsLoaded) {
        final comments = (state as PostCommentsLoaded).comments;
        final commentToDelete = comments.firstWhere(
            (c) => c.id == commentId, 
            orElse: () => Comment(id: '', postId: '', userId: '', authorUsername: '', text: '', timestamp: Timestamp.now()) 
        );
        if (commentToDelete.id.isNotEmpty && commentToDelete.userId != userId) {
             emit(PostInteractionFailure("You can only delete your own comments.", post: post));
             return;
        }
    }

    try {
        await _postRepository.deleteComment(postId, commentId);
        developer.log('PostInteractionCubit: Comment $commentId deleted.', name: 'PostInteractionCubit');
    } catch (e) {
        developer.log('PostInteractionCubit: Error deleting comment $commentId: $e', name: 'PostInteractionCubit');
        emit(PostInteractionFailure("Failed to delete comment: ${e.toString()}", post: post));
    }
  }

  Future<void> toggleCommentsEnabled() async {
    final userId = _currentUserId;
    Post? currentPost = _getCurrentPostFromState();

    if (userId == null || currentPost == null || currentPost.userId != userId) {
      emit(PostInteractionFailure("Cannot toggle comments: Not authorized or post not found.", post: currentPost));
      return;
    }

    final newIsEnabled = !currentPost.isCommentsEnabled;
    final optimisticPost = currentPost.copyWith(isCommentsEnabled: newIsEnabled);
    _emitUpdatedStateWithPost(optimisticPost);

    try {
      await _postRepository.updatePostSettings(postId, isCommentsEnabled: newIsEnabled);
      developer.log('PostInteractionCubit: Comments for post $postId set to $newIsEnabled.', name: 'PostInteractionCubit');
    } catch (e) {
      developer.log('PostInteractionCubit: Error toggling comments enabled: $e', name: 'PostInteractionCubit');
      _emitUpdatedStateWithPost(currentPost); 
      emit(PostInteractionFailure("Failed to update comment settings: ${e.toString()}", post: currentPost));
    }
  }

  Post? _getCurrentPostFromState() {
    if (state is PostInteractionInitial) return (state as PostInteractionInitial).post;
    if (state is PostUpdated) return (state as PostUpdated).post;
    if (state is PostCommentsLoaded) return (state as PostCommentsLoaded).post;
    if (state is PostInteractionLoading) return (state as PostInteractionLoading).post;
    if (state is PostDeleting) return (state as PostDeleting).postToDelete;
    if (state is PostUpdating) return (state as PostUpdating).postToUpdate;
    if (state is PostInteractionFailure) {
        final failureState = state as PostInteractionFailure;
        if (failureState.post != null) return failureState.post;
    }
    final currentState = this.state;
    if (currentState is PostInteractionInitial) {
      return currentState.post;
    }
    return null;
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    _commentsSubscription?.cancel();
    developer.log('PostInteractionCubit for post $postId closed.', name: 'PostInteractionCubit');
    return super.close();
  }
}