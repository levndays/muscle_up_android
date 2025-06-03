// lib/features/social/presentation/cubit/user_interaction_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer;

part 'user_interaction_state.dart';

class UserInteractionCubit extends Cubit<UserInteractionState> {
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  final String targetUserId; // ID користувача, чий профіль переглядається

  StreamSubscription<UserProfile?>? _targetUserProfileSubscription;
  StreamSubscription<UserProfile?>? _currentUserProfileSubscription; // Для відстеження `following` списку поточного користувача

  UserProfile? _currentTargetUserProfile;
  UserProfile? _currentAuthUserProfile;


  UserInteractionCubit(
    this._userProfileRepository,
    this._firebaseAuth,
    this.targetUserId,
  ) : super(UserInteractionInitial()) {
    _initialize();
  }

  String? get _currentAuthUserId => _firebaseAuth.currentUser?.uid;

  Future<void> _initialize() async {
    final authUserId = _currentAuthUserId;
    if (authUserId == null) {
      emit(const UserInteractionError("User not authenticated."));
      return;
    }

    emit(const UserInteractionLoading(loadingMessage: "Loading profile..."));

    try {
      // Підписка на профіль цільового користувача
      _targetUserProfileSubscription?.cancel();
      _targetUserProfileSubscription = _userProfileRepository.getUserProfileStream(targetUserId).listen(
        (profile) {
          _currentTargetUserProfile = profile;
          _emitLoadedStateIfNeeded();
        },
        onError: (error, stackTrace) {
          developer.log('Error in target user profile stream for $targetUserId: $error', name: 'UserInteractionCubit', error: error, stackTrace: stackTrace);
          emit(UserInteractionError('Failed to load profile: ${error.toString()}', targetUserProfile: _currentTargetUserProfile, wasFollowing: _getIsFollowingState()));
        },
      );

      // Підписка на профіль поточного автентифікованого користувача
      _currentUserProfileSubscription?.cancel();
      _currentUserProfileSubscription = _userProfileRepository.getUserProfileStream(authUserId).listen(
        (profile) {
          _currentAuthUserProfile = profile;
          _emitLoadedStateIfNeeded();
        },
        onError: (error, stackTrace) {
          developer.log('Error in current auth user profile stream for $authUserId: $error', name: 'UserInteractionCubit', error: error, stackTrace: stackTrace);
          // Don't necessarily emit top-level error, as target profile might still be fine
        },
      );

    } catch (e, s) {
      developer.log('Error during UserInteractionCubit initialization: $e', error: e, stackTrace: s, name: 'UserInteractionCubit');
      emit(UserInteractionError('Failed to initialize: ${e.toString()}'));
    }
  }
  
  bool _getIsFollowingState() {
    if (_currentAuthUserProfile == null || _currentTargetUserProfile == null) {
      return false;
    }
    return _currentAuthUserProfile!.following.contains(_currentTargetUserProfile!.uid);
  }

  void _emitLoadedStateIfNeeded() {
    if (_currentTargetUserProfile != null && _currentAuthUserProfile != null) {
      final bool isCurrentlyFollowing = _getIsFollowingState();
      // Якщо попередній стан був помилкою, але ми успішно завантажили дані,
      // або якщо це перший успішний завантаження, або якщо змінилися дані.
      if (state is UserInteractionError || state is UserInteractionInitial || state is UserInteractionLoading ||
          (state is UserInteractionProfileLoaded && 
           ((state as UserInteractionProfileLoaded).targetUserProfile != _currentTargetUserProfile || 
            (state as UserInteractionProfileLoaded).isFollowing != isCurrentlyFollowing))
          ) {
        emit(UserInteractionProfileLoaded(
          targetUserProfile: _currentTargetUserProfile!,
          isFollowing: isCurrentlyFollowing,
        ));
      }
    } else if (_currentTargetUserProfile == null && (state is UserInteractionInitial || state is UserInteractionLoading)) {
      // Якщо targetUserProfile ще завантажується, але authUser вже є.
      // Можна залишити Loading або перейти в стан з помилкою, якщо target не завантажиться.
    }
  }


  Future<void> toggleFollow() async {
    final authUserId = _currentAuthUserId;
    if (authUserId == null || targetUserId == authUserId) {
      emit(UserInteractionError("Cannot follow/unfollow: Invalid operation.", targetUserProfile: _currentTargetUserProfile, wasFollowing: _getIsFollowingState()));
      return;
    }

    final currentState = state;
    if (currentState is UserInteractionProfileLoaded) {
      emit(currentState.copyWith(isProcessingFollow: true)); // Show loading on button

      final bool wasFollowing = currentState.isFollowing;
      try {
        if (wasFollowing) {
          await _userProfileRepository.unfollowUser(authUserId, targetUserId);
          emit(UserInteractionUnfollowSuccess(targetUserProfile: currentState.targetUserProfile, isFollowing: false));
          developer.log('User $authUserId unfollowed $targetUserId', name: 'UserInteractionCubit');
        } else {
          await _userProfileRepository.followUser(authUserId, targetUserId);
           emit(UserInteractionFollowSuccess(targetUserProfile: currentState.targetUserProfile, isFollowing: true));
          developer.log('User $authUserId followed $targetUserId', name: 'UserInteractionCubit');
        }
        // Хмарні функції оновлять лічильники, стрім профілю їх підхопить.
      } catch (e, s) {
        developer.log('Error toggling follow: $e', name: 'UserInteractionCubit', error: e, stackTrace: s);
        // Revert to previous state on error
        emit(UserInteractionError("Failed to ${wasFollowing ? 'unfollow' : 'follow'}: ${e.toString()}", targetUserProfile: currentState.targetUserProfile, wasFollowing: wasFollowing));
      }
    } else {
       emit(UserInteractionError("Cannot process follow/unfollow in current state: $currentState", targetUserProfile: _currentTargetUserProfile, wasFollowing: _getIsFollowingState()));
    }
  }

  @override
  Future<void> close() {
    _targetUserProfileSubscription?.cancel();
    _currentUserProfileSubscription?.cancel();
    developer.log('UserInteractionCubit for target $targetUserId closed.', name: 'UserInteractionCubit');
    return super.close();
  }
}