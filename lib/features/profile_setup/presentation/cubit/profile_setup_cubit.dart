import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Аліас
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';

part 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  UserProfile _currentUserProfile; // Для зберігання поточних змін

  ProfileSetupCubit(this._userProfileRepository, this._firebaseAuth)
      : _currentUserProfile = UserProfile( // Початковий порожній профіль
          uid: _firebaseAuth.currentUser?.uid ?? '',
          email: _firebaseAuth.currentUser?.email,
          displayName: _firebaseAuth.currentUser?.displayName,
          profilePictureUrl: _firebaseAuth.currentUser?.photoURL,
          xp: 0,
          level: 1,
          profileSetupComplete: false,
          createdAt: Timestamp.now(), // Буде перезаписано, якщо документ існує
          updatedAt: Timestamp.now(),
          // інші поля null
        ),
        super(ProfileSetupInitial(UserProfile(
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
    _loadInitialData(); // Завантажуємо дані, якщо вони є
  }

  UserProfile get currentProfileSnapshot => _currentUserProfile;

  Future<void> _loadInitialData() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const ProfileSetupFailure("User not logged in."));
      return;
    }
    try {
      final profile = await _userProfileRepository.getUserProfile(userId);
      if (profile != null) {
        _currentUserProfile = profile;
        emit(ProfileSetupDataLoaded(_currentUserProfile));
      } else {
        // Якщо профіль не знайдено (не мало б бути, якщо _createInitialUserProfile спрацював)
        // використовуємо дані з FirebaseAuth
         emit(ProfileSetupDataLoaded(_currentUserProfile));
      }
    } catch (e) {
      emit(ProfileSetupFailure("Failed to load profile data: ${e.toString()}"));
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
    String? displayName, // Можливість оновити displayName, якщо потрібно
  }) {
    _currentUserProfile = _currentUserProfile.copyWith(
      username: username != null ? () => username : null,
      gender: gender != null ? () => gender : null,
      dateOfBirth: dateOfBirth != null ? () => dateOfBirth : null,
      heightCm: heightCm != null ? () => heightCm : null,
      weightKg: weightKg != null ? () => weightKg : null,
      fitnessGoal: fitnessGoal != null ? () => fitnessGoal : null,
      activityLevel: activityLevel != null ? () => activityLevel : null,
      displayName: displayName != null ? () => displayName : null,
    );
    // Можна не емітити кожен раз, а тільки при збереженні, або створити ProfileSetupFormUpdated
     emit(ProfileSetupDataLoaded(_currentUserProfile)); // Оновлюємо UI з поточними даними
  }


  Future<void> saveProfile() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const ProfileSetupFailure("User not logged in."));
      return;
    }
    // Валідація (приклад, можна розширити)
    if (_currentUserProfile.username == null || _currentUserProfile.username!.trim().isEmpty) {
      emit(const ProfileSetupFailure("Username cannot be empty."));
      // Важливо повернути попередній стан, щоб форма не скидалася
      emit(ProfileSetupDataLoaded(_currentUserProfile));
      return;
    }
    // Тут можна додати інші перевірки

    emit(ProfileSetupLoading());
    try {
      // Переконуємося, що UID правильний і profileSetupComplete буде true
      final profileToSave = _currentUserProfile.copyWith(
        uid: userId,
        profileSetupComplete: true,
      );
      await _userProfileRepository.updateUserProfile(profileToSave);
      emit(ProfileSetupSuccess(profileToSave));
    } catch (e) {
      emit(ProfileSetupFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}