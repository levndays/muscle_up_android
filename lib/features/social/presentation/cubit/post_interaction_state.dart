// lib/features/social/presentation/cubit/post_interaction_state.dart
part of 'post_interaction_cubit.dart';

abstract class PostInteractionState extends Equatable {
  const PostInteractionState();

  @override
  List<Object?> get props => [];
}

class PostInteractionInitial extends PostInteractionState {
    final Post post;
    const PostInteractionInitial(this.post);
    @override
    List<Object?> get props => [post];
}

class PostInteractionLoading extends PostInteractionState {
  final Post post; // Можемо передавати поточний пост, поки завантажується оновлення
  const PostInteractionLoading(this.post);
  @override
  List<Object?> get props => [post];
}


class PostUpdated extends PostInteractionState {
  final Post post;
  final VoteType? currentUserVote;

  const PostUpdated(this.post, {this.currentUserVote});

  @override
  List<Object?> get props => [post, currentUserVote];
}

class PostCommentsLoaded extends PostInteractionState {
  final Post post;
  final List<Comment> comments;
  final VoteType? currentUserVote;

  const PostCommentsLoaded(this.post, this.comments, {this.currentUserVote});

  @override
  List<Object?> get props => [post, comments, currentUserVote];
}

class PostInteractionFailure extends PostInteractionState {
  final Post? post; // Додаємо пост, щоб UI міг відновитися до попереднього стану
  final String error;
  const PostInteractionFailure(this.error, {this.post});

  @override
  List<Object?> get props => [error, post];
}

// NEW STATES for Edit/Delete
class PostDeleting extends PostInteractionState {
  final Post postToDelete;
  const PostDeleting(this.postToDelete);
  @override
  List<Object?> get props => [postToDelete];
}

class PostDeletedSuccessfully extends PostInteractionState {
  final String postId; // ID видаленого поста
  const PostDeletedSuccessfully(this.postId);
   @override
  List<Object?> get props => [postId];
}

class PostUpdating extends PostInteractionState {
  final Post postToUpdate;
  const PostUpdating(this.postToUpdate);
   @override
  List<Object?> get props => [postToUpdate];
}

// PostUpdated вже існує і може використовуватися після успішного редагування.