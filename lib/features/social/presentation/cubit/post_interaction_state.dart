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
  final Post post;
  const PostInteractionLoading(this.post);
  @override
  List<Object?> get props => [post];
}


class PostUpdated extends PostInteractionState {
  final Post post;
  final VoteType? currentUserVote; // NEW

  const PostUpdated(this.post, {this.currentUserVote});

  @override
  List<Object?> get props => [post, currentUserVote];
}

class PostCommentsLoaded extends PostInteractionState {
  final Post post;
  final List<Comment> comments;
  final VoteType? currentUserVote; // NEW

  const PostCommentsLoaded(this.post, this.comments, {this.currentUserVote});

  @override
  List<Object?> get props => [post, comments, currentUserVote];
}

class PostInteractionFailure extends PostInteractionState {
  final Post? post;
  final String error;
  const PostInteractionFailure(this.error, {this.post});

  @override
  List<Object?> get props => [error, post];
}