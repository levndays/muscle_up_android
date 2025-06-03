// lib/features/social/presentation/cubit/user_interaction_state.dart
part of 'user_interaction_cubit.dart';

abstract class UserInteractionState extends Equatable {
  const UserInteractionState();

  @override
  List<Object?> get props => [];
}

class UserInteractionInitial extends UserInteractionState {}

class UserInteractionLoading extends UserInteractionState {
  final String? loadingMessage;
  const UserInteractionLoading({this.loadingMessage});
  @override
  List<Object?> get props => [loadingMessage];
}

class UserInteractionProfileLoaded extends UserInteractionState {
  final UserProfile targetUserProfile;
  final bool isFollowing; // Is the current authenticated user following the targetUserProfile?
  final bool isProcessingFollow; // True if follow/unfollow action is in progress

  const UserInteractionProfileLoaded({
    required this.targetUserProfile,
    required this.isFollowing,
    this.isProcessingFollow = false,
  });

  UserInteractionProfileLoaded copyWith({
    UserProfile? targetUserProfile,
    bool? isFollowing,
    bool? isProcessingFollow,
  }) {
    return UserInteractionProfileLoaded(
      targetUserProfile: targetUserProfile ?? this.targetUserProfile,
      isFollowing: isFollowing ?? this.isFollowing,
      isProcessingFollow: isProcessingFollow ?? this.isProcessingFollow,
    );
  }

  @override
  List<Object?> get props => [targetUserProfile, isFollowing, isProcessingFollow];
}

class UserInteractionFollowSuccess extends UserInteractionProfileLoaded {
  const UserInteractionFollowSuccess({
    required super.targetUserProfile,
    required super.isFollowing,
  }) : super(isProcessingFollow: false);
}

class UserInteractionUnfollowSuccess extends UserInteractionProfileLoaded {
  const UserInteractionUnfollowSuccess({
    required super.targetUserProfile,
    required super.isFollowing,
  }) : super(isProcessingFollow: false);
}


class UserInteractionError extends UserInteractionState {
  final String message;
  final UserProfile? targetUserProfile; // To retain profile data on error if possible
  final bool? wasFollowing;          // To retain follow state on error if possible

  const UserInteractionError(this.message, {this.targetUserProfile, this.wasFollowing});

  @override
  List<Object?> get props => [message, targetUserProfile, wasFollowing];
}