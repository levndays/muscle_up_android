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

// Стан, коли завантажуються коментарі або оновлюється пост
class PostInteractionLoading extends PostInteractionState {
  final Post post; // Поточний стан поста
  const PostInteractionLoading(this.post);
  @override
  List<Object?> get props => [post];
}


class PostUpdated extends PostInteractionState {
  final Post post;
  const PostUpdated(this.post);

  @override
  List<Object?> get props => [post];
}

class PostCommentsLoaded extends PostInteractionState {
  final Post post; // Додаємо пост сюди, щоб мати доступ до isCommentsEnabled
  final List<Comment> comments;
  const PostCommentsLoaded(this.post, this.comments);

  @override
  List<Object?> get props => [post, comments];
}

class PostInteractionFailure extends PostInteractionState {
  final Post? post; // Повертаємо пост, щоб UI міг відновити попередній стан
  final String error;
  const PostInteractionFailure(this.error, {this.post});

  @override
  List<Object?> get props => [error, post];
}