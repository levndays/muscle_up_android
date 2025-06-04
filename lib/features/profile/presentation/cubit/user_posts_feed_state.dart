// lib/features/profile/presentation/cubit/user_posts_feed_state.dart
part of 'user_posts_feed_cubit.dart';

abstract class UserPostsFeedState extends Equatable {
  const UserPostsFeedState();

  @override
  List<Object> get props => [];
}

class UserPostsFeedInitial extends UserPostsFeedState {}

class UserPostsFeedLoading extends UserPostsFeedState {}

class UserPostsFeedLoaded extends UserPostsFeedState {
  final List<Post> posts;
  const UserPostsFeedLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class UserPostsFeedError extends UserPostsFeedState {
  final String message;
  const UserPostsFeedError(this.message);

  @override
  List<Object> get props => [message];
}