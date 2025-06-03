// lib/features/social/presentation/cubit/create_post_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer;

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  final PostRepository _postRepository;
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;

  CreatePostCubit(
    this._postRepository,
    this._userProfileRepository,
    this._firebaseAuth,
  ) : super(CreatePostInitial());

  Future<void> submitPost({
    required String textContent,
    String? mediaUrl,
    PostType type = PostType.standard,
    bool isCommentsEnabled = true,
    Map<String, dynamic>? routineSnapshot, // NEW PARAMETER
    String? relatedRoutineId,             // NEW PARAMETER
    Map<String, dynamic>? recordDetails, // NEW PARAMETER
  }) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const CreatePostFailure("User not logged in."));
      return;
    }

    if (textContent.trim().isEmpty && mediaUrl == null && routineSnapshot == null && recordDetails == null) {
      emit(const CreatePostFailure("Post content cannot be empty."));
      return;
    }

    emit(CreatePostLoading());

    try {
      final UserProfile? userProfile = await _userProfileRepository.getUserProfile(userId);
      if (userProfile == null) {
        emit(const CreatePostFailure("Could not fetch user profile to create post."));
        return;
      }

      final newPost = Post(
        id: '',
        userId: userId,
        authorUsername: userProfile.username ?? userProfile.displayName ?? 'Anonymous',
        authorProfilePicUrl: userProfile.profilePictureUrl,
        timestamp: Timestamp.now(),
        type: type,
        textContent: textContent.trim(),
        mediaUrl: mediaUrl,
        likedBy: [],
        commentsCount: 0,
        isCommentsEnabled: isCommentsEnabled,
        routineSnapshot: routineSnapshot, // NEW
        relatedRoutineId: relatedRoutineId, // NEW
        recordDetails: recordDetails, // NEW
      );

      await _postRepository.createPost(newPost);
      emit(CreatePostSuccess(newPost.copyWith(id: "temp_id_client_generated"))); // Use copyWith to set a temporary ID
      developer.log('Post submitted successfully by user: $userId, type: ${type.name}, comments enabled: $isCommentsEnabled', name: 'CreatePostCubit');
    } catch (e, s) {
      developer.log('Error submitting post: $e', name: 'CreatePostCubit', error: e, stackTrace: s);
      emit(CreatePostFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}