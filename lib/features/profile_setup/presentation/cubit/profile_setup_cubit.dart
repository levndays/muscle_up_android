// lib/features/profile_setup/presentation/cubit/profile_setup_cubit.dart
import 'dart:io'; // NEW: For File type
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart' as fb_storage; // NEW
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer; 

part 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  UserProfile _currentUserProfile; 
  final bool _isEditingMode; 

  ProfileSetupCubit(
    this._userProfileRepository,
    this._firebaseAuth, {
    UserProfile? initialProfile, 
  })  : _currentUserProfile = initialProfile ?? 
            UserProfile(
              uid: _firebaseAuth.currentUser?.uid ?? '',
              email: _firebaseAuth.currentUser?.email,
              displayName: null, 
              profilePictureUrl: _firebaseAuth.currentUser?.photoURL,
              xp: 0,
              level: 1,
              profileSetupComplete: false, 
              createdAt: Timestamp.now(), 
              updatedAt: Timestamp.now(), 
            ),
        _isEditingMode = initialProfile != null, 
        super(initialProfile != null 
              ? ProfileSetupDataLoaded(initialProfile) 
              : ProfileSetupInitial( 
                  UserProfile(
                    uid: _firebaseAuth.currentUser?.uid ?? '',
                    email: _firebaseAuth.currentUser?.email,
                    displayName: null,
                    profilePictureUrl: _firebaseAuth.currentUser?.photoURL,
                    xp: 0,
                    level: 1,
                    profileSetupComplete: false,
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now(),
                  )
                )
              ) {
    developer.log("ProfileSetupCubit: Initializing. IsEditing: $_isEditingMode", name: "ProfileSetupCubit");
    _loadInitialData();
  }

  UserProfile get currentProfileSnapshot => _currentUserProfile;
  bool get isEditing => _isEditingMode; 

  Future<void> _loadInitialData() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      developer.log("ProfileSetupCubit: No user ID, cannot load initial data.", name: "ProfileSetupCubit");
      if (!isClosed) emit(const ProfileSetupFailure("User not logged in."));
      return;
    }
    developer.log("ProfileSetupCubit: Loading initial data for user $userId. IsEditing: $_isEditingMode", name: "ProfileSetupCubit");
    
    if (!_isEditingMode && state is! ProfileSetupLoading) {
        if(!isClosed) emit(ProfileSetupLoading());
    }

    try {
      final profileFromRepo = await _userProfileRepository.getUserProfile(userId);
      if (profileFromRepo != null) {
        developer.log("ProfileSetupCubit: Profile found in repo, using it as base.", name: "ProfileSetupCubit");
        _currentUserProfile = profileFromRepo;
        if (_isEditingMode) {
           _currentUserProfile = _currentUserProfile.copyWith(profileSetupComplete: true);
        }
      } else if (!_isEditingMode) {
        final currentUser = _firebaseAuth.currentUser;
         String? initialDisplayName = _currentUserProfile.displayName;
        if (initialDisplayName == null || initialDisplayName.trim().isEmpty) {
          if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
            initialDisplayName = currentUser.displayName!;
          } else if (currentUser?.email != null && currentUser!.email!.contains('@')) {
            initialDisplayName = currentUser.email!.split('@').first;
          }
        }
        _currentUserProfile = _currentUserProfile.copyWith(
          displayName: initialDisplayName != null ? () => initialDisplayName : null,
          profilePictureUrl: () => currentUser?.photoURL, // NEW: Use photoURL from FirebaseAuth for new users
          profileSetupComplete: false, 
        );
        developer.log("ProfileSetupCubit: Profile NOT in repo (new user). Base from FirebaseAuth: displayName='${_currentUserProfile.displayName}', avatar='${_currentUserProfile.profilePictureUrl}'", name: "ProfileSetupCubit");
      } else {
         developer.log("ProfileSetupCubit: ERROR - Editing mode, but profile not found in repo for user $userId.", name: "ProfileSetupCubit");
         if(!isClosed) emit(const ProfileSetupFailure("Profile to edit not found. Please try again."));
         return;
      }
      
      if (!isClosed) emit(ProfileSetupDataLoaded(_currentUserProfile));
    } catch (e, s) {
      developer.log("ProfileSetupCubit: Error loading initial profile data: $e", name: "ProfileSetupCubit", error: e, stackTrace: s);
      if (!isClosed) emit(ProfileSetupFailure("Failed to load profile data: ${e.toString().replaceFirst("Exception: ", "")}"));
    }
  }

  void updateField({
    String? username,
    String? displayName,
    String? gender,
    Timestamp? dateOfBirth,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
    String? activityLevel,
    String? profilePictureUrl, // NEW: For updating avatar URL after upload
  }) {
    _currentUserProfile = _currentUserProfile.copyWith(
      username: username != null ? () => username.trim() : null,
      displayName: displayName != null ? () => displayName.trim().isNotEmpty ? displayName.trim() : null : null,
      gender: gender != null ? () => gender : null,
      dateOfBirth: dateOfBirth != null ? () => dateOfBirth : null,
      heightCm: heightCm != null ? () => heightCm : null,
      weightKg: weightKg != null ? () => weightKg : null,
      fitnessGoal: fitnessGoal != null ? () => fitnessGoal : null,
      activityLevel: activityLevel != null ? () => activityLevel : null,
      profilePictureUrl: profilePictureUrl != null ? () => profilePictureUrl : null, // NEW
    );
    
    if (!isClosed) emit(ProfileSetupDataLoaded(_currentUserProfile));
    developer.log("ProfileSetupCubit: Field updated. Current profile: $_currentUserProfile", name: "ProfileSetupCubit");
  }

  // NEW: Method to upload image to Firebase Storage
  Future<String?> _uploadAvatarImage(String userId, File imageFile) async {
    try {
      final storageRef = fb_storage.FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('$userId.jpg'); // Or use a unique ID for each image
      
      final uploadTask = storageRef.putFile(
          imageFile, 
          fb_storage.SettableMetadata(contentType: 'image/jpeg') // Ensure correct content type
      );
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      developer.log("ProfileSetupCubit: Avatar uploaded successfully: $downloadUrl", name: "ProfileSetupCubit");
      return downloadUrl;
    } catch (e, s) {
      developer.log("ProfileSetupCubit: Error uploading avatar: $e", name: "ProfileSetupCubit", error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> saveProfile({File? avatarImageFile /* NEW: Pass avatar file */}) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      developer.log("ProfileSetupCubit: Save failed - User not logged in.", name: "ProfileSetupCubit");
      if (!isClosed) emit(const ProfileSetupFailure("User not logged in."));
      return;
    }

    final currentUsername = _currentUserProfile.username?.trim();
    if (currentUsername == null || currentUsername.isEmpty) {
      developer.log("ProfileSetupCubit: Save failed - Username is empty.", name: "ProfileSetupCubit");
      if (!isClosed) {
        emit(const ProfileSetupFailure("Username cannot be empty."));
        emit(ProfileSetupDataLoaded(_currentUserProfile));
      }
      return;
    }
    String finalDisplayName = _currentUserProfile.displayName?.trim() ?? '';
    if (finalDisplayName.isEmpty) {
      finalDisplayName = currentUsername;
    }

    if (!isClosed) emit(ProfileSetupLoading());
    developer.log("ProfileSetupCubit: Attempting to save profile for user $userId. IsEditing: $_isEditingMode", name: "ProfileSetupCubit");

    try {
      String? uploadedAvatarUrl = _currentUserProfile.profilePictureUrl;
      if (avatarImageFile != null) {
        // Upload new avatar if provided
        uploadedAvatarUrl = await _uploadAvatarImage(userId, avatarImageFile);
        if (uploadedAvatarUrl == null && !isClosed) {
          emit(const ProfileSetupFailure("Failed to upload avatar image. Profile not saved."));
          return; // Stop if avatar upload failed
        }
      }

      final profileToSave = _currentUserProfile.copyWith(
        uid: userId, 
        displayName: () => finalDisplayName, 
        profilePictureUrl: () => uploadedAvatarUrl, // NEW: Set the (potentially new) avatar URL
        profileSetupComplete: true, 
      );

      await _userProfileRepository.updateUserProfile(profileToSave);
      developer.log("ProfileSetupCubit: Profile saved successfully. Profile: $profileToSave", name: "ProfileSetupCubit");
      if (!isClosed) emit(ProfileSetupSuccess(profileToSave));
    } catch (e, s) {
      developer.log("ProfileSetupCubit: Error saving profile: $e", name: "ProfileSetupCubit", error: e, stackTrace: s);
      if (!isClosed) emit(ProfileSetupFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  @override
  Future<void> close() {
    developer.log("ProfileSetupCubit: Closing.", name: "ProfileSetupCubit");
    return super.close();
  }
}