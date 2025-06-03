// lib/features/social/presentation/cubit/explore_feed_state.dart
part of 'explore_feed_cubit.dart';

abstract class ExploreFeedState extends Equatable {
  const ExploreFeedState();

  @override
  List<Object> get props => [];
}

class ExploreFeedInitial extends ExploreFeedState {}

class ExploreFeedLoading extends ExploreFeedState {}

class ExploreFeedLoaded extends ExploreFeedState {
  final List<Post> posts;
  const ExploreFeedLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class ExploreFeedError extends ExploreFeedState {
  final String message;
  const ExploreFeedError(this.message);

  @override
  List<Object> get props => [message];
}