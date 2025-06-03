// lib/features/social/presentation/cubit/follow_list_state.dart
part of 'follow_list_cubit.dart';

enum FollowListType { followers, following }

abstract class FollowListState extends Equatable {
  const FollowListState();

  @override
  List<Object?> get props => [];
}

class FollowListInitial extends FollowListState {}

class FollowListLoading extends FollowListState {
  final List<UserProfile> currentProfiles; // For pagination, show existing while loading more
  final bool isInitialLoad;
  const FollowListLoading({this.currentProfiles = const [], this.isInitialLoad = true});

  @override
  List<Object?> get props => [currentProfiles, isInitialLoad];
}

class FollowListLoaded extends FollowListState {
  final List<UserProfile> profiles;
  final bool hasMore; // For pagination
  const FollowListLoaded(this.profiles, {this.hasMore = false});

  @override
  List<Object?> get props => [profiles, hasMore];
}

class FollowListError extends FollowListState {
  final String message;
  const FollowListError(this.message);

  @override
  List<Object?> get props => [message];
}