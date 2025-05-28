part of 'profile_setup_cubit.dart';

abstract class ProfileSetupState extends Equatable {
  const ProfileSetupState();

  @override
  List<Object?> get props => [];
}

class ProfileSetupInitial extends ProfileSetupState {
  final UserProfile userProfile; // Початкові дані
  const ProfileSetupInitial(this.userProfile);
  @override
  List<Object?> get props => [userProfile];
}

// Можна додати стан для відображення завантажених даних, якщо потрібно
class ProfileSetupDataLoaded extends ProfileSetupState {
  final UserProfile userProfile;
  const ProfileSetupDataLoaded(this.userProfile);
  @override
  List<Object?> get props => [userProfile];
}

class ProfileSetupLoading extends ProfileSetupState {}

class ProfileSetupSuccess extends ProfileSetupState {
  final UserProfile updatedProfile;
  const ProfileSetupSuccess(this.updatedProfile);
   @override
  List<Object?> get props => [updatedProfile];
}

class ProfileSetupFailure extends ProfileSetupState {
  final String error;
  const ProfileSetupFailure(this.error);
  @override
  List<Object?> get props => [error];
}