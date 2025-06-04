// lib/features/social/presentation/cubit/create_post_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
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
  final Post? _initialPostToEdit; // Зберігаємо початковий пост для редагування

  CreatePostCubit(
    this._postRepository,
    this._userProfileRepository,
    this._firebaseAuth, {
    Post? postToEdit, // Передаємо пост для редагування
  })  : _initialPostToEdit = postToEdit,
        super(CreatePostInitial(postToEdit: postToEdit));

  Future<String?> _uploadPostMedia(String userId, String postId, File imageFile) async {
    try {
      final storageRef = fb_storage.FirebaseStorage.instance
          .ref()
          .child('post_media')
          .child(userId)
          .child('$postId.jpg');
      
      final uploadTask = storageRef.putFile(imageFile, fb_storage.SettableMetadata(contentType: 'image/jpeg'));
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
    File? mediaImageFile,
    bool removeExistingMedia = false, // NEW: для видалення існуючого медіа при редагуванні
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

    if (textContent.trim().isEmpty &&
        mediaImageFile == null &&
        (_initialPostToEdit?.mediaUrl == null || removeExistingMedia) && // Перевірка для редагування
        type == PostType.standard && // Для стандартних постів
        routineSnapshot == null &&
        recordDetails == null) {
      emit(const CreatePostFailure("Post content cannot be empty for a standard post without media."));
      return;
    }
    
    final bool isEditing = _initialPostToEdit != null;
    emit(CreatePostLoading(loadingMessage: isEditing ? "Updating post..." : "Publishing post..."));

    try {
      UserProfile? userProfile = await _userProfileRepository.getUserProfile(userId);
      if (userProfile == null) {
        emit(const CreatePostFailure("Could not fetch user profile."));
        return;
      }

      String? finalMediaUrl = isEditing ? _initialPostToEdit!.mediaUrl : null;

      if (mediaImageFile != null) {
        // Завантажуємо нове медіа. postId потрібен для шляху.
        // Якщо це новий пост, генеруємо ID. Якщо редагування, використовуємо існуючий.
        final postIdForMedia = isEditing ? _initialPostToEdit!.id : _postRepository.toString(); // Тимчасовий ID або використовуйте Firestore-генератор
        
        final tempPostId = isEditing ? _initialPostToEdit!.id : FirebaseFirestore.instance.collection('posts').doc().id;

        finalMediaUrl = await _uploadPostMedia(userId, tempPostId, mediaImageFile);
        if (finalMediaUrl == null) {
          emit(const CreatePostFailure("Failed to upload media."));
          return;
        }
      } else if (removeExistingMedia && isEditing) {
        // Видаляємо старе медіа зі Storage, якщо потрібно
        if (_initialPostToEdit!.mediaUrl != null) {
          try {
            final storageRef = fb_storage.FirebaseStorage.instance.refFromURL(_initialPostToEdit!.mediaUrl!);
            await storageRef.delete();
            developer.log('CreatePostCubit: Deleted existing media for post ${_initialPostToEdit!.id} during update.', name: 'CreatePostCubit');
          } catch (e) {
             developer.log('CreatePostCubit: Failed to delete existing media for post ${_initialPostToEdit!.id}: $e', name: 'CreatePostCubit');
          }
        }
        finalMediaUrl = null;
      }


      if (isEditing) {
        final postToUpdate = _initialPostToEdit!.copyWith(
          textContent: textContent.trim(),
          mediaUrl: finalMediaUrl,
          allowNullMediaUrl: true, // Дозволяємо встановлення null
          isCommentsEnabled: isCommentsEnabled,
          // Тип, routineSnapshot, recordDetails зазвичай не редагуються, але можна додати, якщо потрібно
          // type: type, 
          // routineSnapshot: routineSnapshot,
          // relatedRoutineId: relatedRoutineId,
          // recordDetails: recordDetails,
          updatedAt: Timestamp.now(), // Firestore оновить це на серверний час
        );
        await _postRepository.updatePost(postToUpdate);
        emit(CreatePostSuccess(postToUpdate, isUpdate: true));
        developer.log('Post updated successfully: ${postToUpdate.id}', name: 'CreatePostCubit');
      } else {
        // Створення нового поста
        // ID генерується в _postRepository.createPost
        final newPost = Post(
          id: '', // Буде встановлено репозиторієм
          userId: userId,
          authorUsername: userProfile.username ?? userProfile.displayName ?? 'Anonymous',
          authorProfilePicUrl: userProfile.profilePictureUrl,
          timestamp: Timestamp.now(), // Буде перезаписано серверним
          updatedAt: Timestamp.now(), // Буде перезаписано серверним
          type: type,
          textContent: textContent.trim(),
          mediaUrl: finalMediaUrl,
          isCommentsEnabled: isCommentsEnabled,
          routineSnapshot: routineSnapshot,
          relatedRoutineId: relatedRoutineId,
          recordDetails: recordDetails,
        );
        await _postRepository.createPost(newPost);
        // Після успішного створення, ми не маємо фінального ID з Firestore тут,
        // тому передаємо `newPost`, можливо з порожнім ID або тимчасовим.
        // Стрічка оновиться через listener.
        emit(CreatePostSuccess(newPost, isUpdate: false));
        developer.log('New post submitted by user: $userId, type: ${type.name}', name: 'CreatePostCubit');
      }
    } catch (e, s) {
      developer.log('Error submitting/updating post: $e', name: 'CreatePostCubit', error: e, stackTrace: s);
      emit(CreatePostFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}