// lib/features/profile_setup/presentation/cubit/profile_setup_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer; // Для логування

part 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  UserProfile _currentUserProfile; 
  final bool _isEditing; // Не використовується, але залишено для контексту

  ProfileSetupCubit(this._userProfileRepository, this._firebaseAuth)
      : _currentUserProfile = UserProfile(
          uid: _firebaseAuth.currentUser?.uid ?? '',
          email: _firebaseAuth.currentUser?.email,
          displayName: _firebaseAuth.currentUser?.displayName,
          profilePictureUrl: _firebaseAuth.currentUser?.photoURL,
          xp: 0,
          level: 1,
          profileSetupComplete: false,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ),
        _isEditing = false, // Для нового профілю завжди false
        super(ProfileSetupInitial(UserProfile( // Початковий стан для UI
          uid: _firebaseAuth.currentUser?.uid ?? '',
          email: _firebaseAuth.currentUser?.email,
          displayName: _firebaseAuth.currentUser?.displayName,
          profilePictureUrl: _firebaseAuth.currentUser?.photoURL,
          xp: 0,
          level: 1,
          profileSetupComplete: false,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ))) {
    developer.log("ProfileSetupCubit: Initializing...", name: "ProfileSetupCubit");
    _loadInitialData();
  }

  UserProfile get currentProfileSnapshot => _currentUserProfile;

  Future<void> _loadInitialData() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      developer.log("ProfileSetupCubit: No user ID, cannot load initial data.", name: "ProfileSetupCubit");
      if (!isClosed) emit(const ProfileSetupFailure("User not logged in."));
      return;
    }
    developer.log("ProfileSetupCubit: Loading initial data for user $userId", name: "ProfileSetupCubit");
    // Не емітуємо ProfileSetupLoading тут, щоб уникнути мерехтіння,
    // оскільки ProfileSetupInitial вже відображає початковий стан.
    try {
      final profileFromRepo = await _userProfileRepository.getUserProfile(userId);
      if (profileFromRepo != null) {
        developer.log("ProfileSetupCubit: Profile found in repo, using it.", name: "ProfileSetupCubit");
        _currentUserProfile = profileFromRepo;
      } else {
        // Якщо профіль не знайдено в репозиторії (наприклад, після чистої реєстрації,
        // де createUserProfile ще не встиг спрацювати або мав помилку),
        // _currentUserProfile вже ініціалізований даними з FirebaseAuth.
        // Це очікувана поведінка для екрану ProfileSetup.
        developer.log("ProfileSetupCubit: Profile NOT found in repo, using FirebaseAuth data as base.", name: "ProfileSetupCubit");
      }
      // Оновлюємо стан UI з поточними даними (або з репо, або з FirebaseAuth)
      if (!isClosed) emit(ProfileSetupDataLoaded(_currentUserProfile));
    } catch (e) {
      developer.log("ProfileSetupCubit: Error loading initial profile data: $e", name: "ProfileSetupCubit", error: e);
      if (!isClosed) emit(ProfileSetupFailure("Failed to load profile data: ${e.toString().replaceFirst("Exception: ", "")}"));
    }
  }

  void updateField({
    String? username,
    String? gender,
    Timestamp? dateOfBirth,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
    String? activityLevel,
    String? displayName,
  }) {
    _currentUserProfile = _currentUserProfile.copyWith(
      // Використовуємо ValueGetter для nullable полів, щоб передати null, якщо значення не змінилося
      username: username != null ? () => username.trim() : null, // Обрізаємо пробіли
      gender: gender != null ? () => gender : null,
      dateOfBirth: dateOfBirth != null ? () => dateOfBirth : null,
      heightCm: heightCm != null ? () => heightCm : null,
      weightKg: weightKg != null ? () => weightKg : null,
      fitnessGoal: fitnessGoal != null ? () => fitnessGoal : null,
      activityLevel: activityLevel != null ? () => activityLevel : null,
      displayName: displayName != null ? () => displayName.trim() : null, // Обрізаємо пробіли
    );
    
    // Оновлюємо UI з поточними даними форми, щоб віджет міг перебудуватися
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

    // Валідація: Username є обов'язковим
    final currentUsername = _currentUserProfile.username?.trim();
    if (currentUsername == null || currentUsername.isEmpty) {
      developer.log("ProfileSetupCubit: Save failed - Username is empty.", name: "ProfileSetupCubit");
      if (!isClosed) {
        emit(const ProfileSetupFailure("Username cannot be empty."));
        // Важливо повернути стан з поточними даними форми, щоб користувач міг виправити
        emit(ProfileSetupDataLoaded(_currentUserProfile));
      }
      return;
    }

    if (!isClosed) emit(ProfileSetupLoading());
    developer.log("ProfileSetupCubit: Attempting to save profile for user $userId", name: "ProfileSetupCubit");

    try {
      // Переконуємося, що UID правильний і profileSetupComplete буде true
      final profileToSave = _currentUserProfile.copyWith(
        uid: userId, // Завжди встановлюємо актуальний UID
        profileSetupComplete: true,
        // updatedAt тут не потрібно, бо репозиторій має використовувати FieldValue.serverTimestamp()
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