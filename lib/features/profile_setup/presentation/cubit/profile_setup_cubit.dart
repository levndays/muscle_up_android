// lib/features/profile_setup/presentation/cubit/profile_setup_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
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
    UserProfile? initialProfile, // Приймаємо initialProfile
  })  : _currentUserProfile = initialProfile ?? // Використовуємо initialProfile або створюємо новий
            UserProfile(
              uid: _firebaseAuth.currentUser?.uid ?? '',
              email: _firebaseAuth.currentUser?.email,
              // Не заповнюємо displayName з FirebaseAuth тут, це робиться в _loadInitialData або UI
              displayName: null, 
              profilePictureUrl: _firebaseAuth.currentUser?.photoURL,
              xp: 0,
              level: 1,
              profileSetupComplete: false, // За замовчуванням false для нового
              createdAt: Timestamp.now(), // Попереднє значення
              updatedAt: Timestamp.now(), // Попереднє значення
            ),
        _isEditingMode = initialProfile != null, // Режим редагування, якщо initialProfile наданий
        super(initialProfile != null 
              ? ProfileSetupDataLoaded(initialProfile) // Якщо редагування, починаємо з завантажених даних
              : ProfileSetupInitial( // Інакше, початковий стан з базовим профілем
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
  bool get isEditing => _isEditingMode; // Геттер для UI

  Future<void> _loadInitialData() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      developer.log("ProfileSetupCubit: No user ID, cannot load initial data.", name: "ProfileSetupCubit");
      if (!isClosed) emit(const ProfileSetupFailure("User not logged in."));
      return;
    }
    developer.log("ProfileSetupCubit: Loading initial data for user $userId. IsEditing: $_isEditingMode", name: "ProfileSetupCubit");
    
    // Не емітуємо Loading, якщо вже є initialProfile (для редагування), щоб уникнути мерехтіння
    if (!_isEditingMode && state is! ProfileSetupLoading) {
        if(!isClosed) emit(ProfileSetupLoading());
    }

    try {
      final profileFromRepo = await _userProfileRepository.getUserProfile(userId);
      if (profileFromRepo != null) {
        developer.log("ProfileSetupCubit: Profile found in repo, using it as base.", name: "ProfileSetupCubit");
        _currentUserProfile = profileFromRepo;
        // Якщо це режим редагування, profileSetupComplete вже має бути true
        if (_isEditingMode) {
           _currentUserProfile = _currentUserProfile.copyWith(profileSetupComplete: true);
        }
      } else if (!_isEditingMode) {
        // Новий профіль, ще не в Firestore (або якась помилка функції).
        // Заповнюємо displayName з FirebaseAuth, якщо він порожній.
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
          // uid, email, photoURL вже встановлені в конструкторі для _currentUserProfile
          profileSetupComplete: false, // Явно для нового
        );
        developer.log("ProfileSetupCubit: Profile NOT in repo (new user). Base from FirebaseAuth: displayName='${_currentUserProfile.displayName}'", name: "ProfileSetupCubit");
      } else {
         // Режим редагування, але профіль не знайдено в репо - це помилка
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
  }) {
    _currentUserProfile = _currentUserProfile.copyWith(
      username: username != null ? () => username.trim() : null,
      displayName: displayName != null ? () => displayName.trim().isNotEmpty ? displayName.trim() : null : null, // Дозволяємо очистити displayName
      gender: gender != null ? () => gender : null,
      dateOfBirth: dateOfBirth != null ? () => dateOfBirth : null,
      heightCm: heightCm != null ? () => heightCm : null,
      weightKg: weightKg != null ? () => weightKg : null,
      fitnessGoal: fitnessGoal != null ? () => fitnessGoal : null,
      activityLevel: activityLevel != null ? () => activityLevel : null,
    );
    
    if (!isClosed) emit(ProfileSetupDataLoaded(_currentUserProfile));
    developer.log("ProfileSetupCubit: Field updated. Current profile: $_currentUserProfile", name: "ProfileSetupCubit");
  }

  Future<void> saveProfile() async {
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
    // Додаткова перевірка для displayName: якщо він порожній, можна встановити username
    String finalDisplayName = _currentUserProfile.displayName?.trim() ?? '';
    if (finalDisplayName.isEmpty) {
      finalDisplayName = currentUsername; // Використовуємо username, якщо displayName порожній
    }


    if (!isClosed) emit(ProfileSetupLoading());
    developer.log("ProfileSetupCubit: Attempting to save profile for user $userId. IsEditing: $_isEditingMode", name: "ProfileSetupCubit");

    try {
      final profileToSave = _currentUserProfile.copyWith(
        uid: userId, 
        displayName: () => finalDisplayName, // Оновлений displayName
        profileSetupComplete: true, // Завжди true при успішному збереженні з цього екрану
        // createdAt НЕ оновлюємо, якщо _isEditingMode. Репозиторій має впоратися з цим.
        // updatedAt буде встановлено в репозиторії.
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