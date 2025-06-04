// lib/features/social/presentation/cubit/create_post_cubit.dart
import 'dart:io'; // NEW: For File type
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart' as fb_storage; // NEW
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

  // NEW: Method to upload image to Firebase Storage
  Future<String?> _uploadPostMedia(String userId, String postId, File imageFile) async {
    try {
      final storageRef = fb_storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(userId) // Store user-specific post media
          .child('$postId.jpg'); // Use post ID for image name
      
      final uploadTask = storageRef.putFile(
          imageFile, 
          fb_storage.SettableMetadata(contentType: 'image/jpeg')
      );
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      developer.log("CreatePostCubit: Post media uploaded successfully: $downloadUrl", name: "CreatePostCubit");
      return downloadUrl;
    } catch (e, s) {
      developer.log("CreatePostCubit: Error uploading post media: $e", name: "CreatePostCubit", error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> submitPost({
    required String textContent,
    File? mediaImageFile, // NEW: Changed from mediaUrl to File
    PostType type = PostType.standard,
    bool isCommentsEnabled = true,
    Map<String, dynamic>? routineSnapshot, 
    String? relatedRoutineId,             
    Map<String, dynamic>? recordDetails, 
  }) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const CreatePostFailure("User not logged in."));
      return;
    }

    if (textContent.trim().isEmpty && mediaImageFile == null && routineSnapshot == null && recordDetails == null) {
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

      // Generate a temporary ID for the post (Firebase will assign the final one)
      // This is mainly if we need it for, e.g., naming the media file.
      // If PostRepository.createPost handles ID generation and returns it, this can be simpler.
      // For now, let's assume PostRepository might not return the ID or we need it for media path.
      String tempPostIdForMedia = FirebaseFirestore.instance.collection('posts').doc().id;

      String? finalMediaUrl;
      if (mediaImageFile != null && type == PostType.standard) { // Only upload for standard posts for now
        finalMediaUrl = await _uploadPostMedia(userId, tempPostIdForMedia, mediaImageFile);
        if (finalMediaUrl == null) {
          emit(const CreatePostFailure("Failed to upload media. Post not created."));
          return;
        }
      }

      final newPost = Post(
        id: '', // ID will be set by the repository or by `tempPostIdForMedia` if repository needs it
        userId: userId,
        authorUsername: userProfile.username ?? userProfile.displayName ?? 'Anonymous',
        authorProfilePicUrl: userProfile.profilePictureUrl,
        timestamp: Timestamp.now(), // This will be overridden by server timestamp in repo
        type: type,
        textContent: textContent.trim(),
        mediaUrl: finalMediaUrl, // NEW: Use the uploaded URL
        likedBy: [],
        commentsCount: 0,
        isCommentsEnabled: isCommentsEnabled,
        routineSnapshot: routineSnapshot,
        relatedRoutineId: relatedRoutineId,
        recordDetails: recordDetails, 
      );

      // Pass the post with the (potentially) temporary ID if needed by repo for consistency,
      // or let the repo handle ID creation entirely.
      // For this example, let's assume `createPost` can take a Post object where ID might be empty
      // and the repository/Firestore assigns the final ID.
      await _postRepository.createPost(newPost); // The repo sets the final ID and server timestamps
      
      // For the success state, we might not have the *final* server-generated ID
      // unless the repository returns the created Post object.
      // If it doesn't, a "temp_id" is fine for client-side indication of success.
      emit(CreatePostSuccess(newPost.copyWith(id: tempPostIdForMedia, mediaUrl: finalMediaUrl))); 
      developer.log('Post submitted successfully by user: $userId, type: ${type.name}, comments enabled: $isCommentsEnabled, media: $finalMediaUrl', name: 'CreatePostCubit');
    } catch (e, s) {
      developer.log('Error submitting post: $e', name: 'CreatePostCubit', error: e, stackTrace: s);
      emit(CreatePostFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}