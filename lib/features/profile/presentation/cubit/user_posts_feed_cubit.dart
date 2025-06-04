// lib/features/profile/presentation/cubit/user_posts_feed_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Not directly used, but good practice for auth-related cubits
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import 'dart:developer' as developer;

part 'user_posts_feed_state.dart';

class UserPostsFeedCubit extends Cubit<UserPostsFeedState> {
  final PostRepository _postRepository;
  final fb_auth.FirebaseAuth _firebaseAuth; // Kept for consistency, though not directly used in fetch logic
  StreamSubscription<List<Post>>? _postsSubscription;
  String? _currentObservingUserId;

  UserPostsFeedCubit(this._postRepository, this._firebaseAuth) : super(UserPostsFeedInitial());

  void fetchUserPosts(String userId) {
    if (userId.isEmpty) {
      developer.log('UserPostsFeedCubit: Attempted to fetch posts with empty userId.', name: 'UserPostsFeedCubit');
      emit(const UserPostsFeedError("User ID is empty. Cannot fetch posts."));
      return;
    }

    // If we are already loading or have loaded posts for this specific user,
    // and there's no force refresh mechanism, we might not need to do anything.
    // However, for simplicity and to ensure freshness if this method is called again,
    // we will proceed with re-fetching.
    if (_currentObservingUserId == userId && state is UserPostsFeedLoading) {
      developer.log('UserPostsFeedCubit: Already loading posts for user $userId.', name: 'UserPostsFeedCubit');
      return; // Already loading for this user
    }
    
    developer.log('UserPostsFeedCubit: Fetching posts for user $userId. Current state: $state', name: 'UserPostsFeedCubit');
    _currentObservingUserId = userId;
    emit(UserPostsFeedLoading()); // Indicate loading start

    _postsSubscription?.cancel();
    _postsSubscription = _postRepository.getUserPostsStream(userId).listen(
      (posts) {
        if (_currentObservingUserId == userId) { // Ensure we are still observing the same user
          emit(UserPostsFeedLoaded(posts));
          developer.log('UserPostsFeedCubit: Loaded ${posts.length} posts for user $userId.', name: 'UserPostsFeedCubit');
        } else {
          developer.log('UserPostsFeedCubit: Received posts for $userId, but now observing $_currentObservingUserId. Discarding.', name: 'UserPostsFeedCubit');
        }
      },
      onError: (error, stackTrace) {
        if (_currentObservingUserId == userId) {
          developer.log('UserPostsFeedCubit: Error fetching posts for user $userId: $error', name: 'UserPostsFeedCubit', error: error, stackTrace: stackTrace);
          emit(UserPostsFeedError(error.toString().replaceFirst("Exception: ", "")));
        } else {
           developer.log('UserPostsFeedCubit: Error for $userId, but now observing $_currentObservingUserId. Discarding error.', name: 'UserPostsFeedCubit', error: error, stackTrace: stackTrace);
        }
      },
      onDone: () {
        // This might be called if the stream closes unexpectedly.
        // If it's not an error, and no data was emitted, it implies an empty list if we were loading.
        if (_currentObservingUserId == userId && state is UserPostsFeedLoading) {
          developer.log('UserPostsFeedCubit: Stream for user $userId completed while loading, emitting empty list.', name: 'UserPostsFeedCubit');
          emit(const UserPostsFeedLoaded([]));
        }
      }
    );
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    _currentObservingUserId = null;
    developer.log('UserPostsFeedCubit closed.', name: 'UserPostsFeedCubit');
    return super.close();
  }
}