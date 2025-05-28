import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:async'; // Для StreamSubscription

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  StreamSubscription<fb_auth.User?>? _authStateSubscription;
  StreamSubscription<UserProfile?>? _userProfileSubscription; // Для оновлень в реальному часі

  UserProfileCubit(this._userProfileRepository, this._firebaseAuth) : super(UserProfileInitial()) {
    // Слухаємо зміни стану автентифікації
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((fb_auth.User? user) {
      if (user != null) {
        fetchUserProfile(user.uid); // Завантажуємо профіль, коли користувач увійшов
        _listenToUserProfileChanges(user.uid); // Починаємо слухати зміни профілю
      } else {
        emit(UserProfileInitial()); // Скидаємо стан, якщо користувач вийшов
        _userProfileSubscription?.cancel(); // Зупиняємо прослуховування
      }
    });
    // Початкове завантаження, якщо користувач вже увійшов при ініціалізації кубіта
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      fetchUserProfile(currentUser.uid);
      _listenToUserProfileChanges(currentUser.uid);
    }
  }

  Future<void> fetchUserProfile(String userId, {bool forceRemote = false}) async {
    // Не завантажувати, якщо вже завантажено і не форсуємо
    if (state is UserProfileLoaded && !forceRemote) return;

    emit(UserProfileLoading());
    try {
      final userProfile = await _userProfileRepository.getUserProfile(userId);
      if (userProfile != null) {
        emit(UserProfileLoaded(userProfile));
      } else {
        // Це може статися, якщо профіль ще не створений або є затримка
        // Можна спробувати створити або показати помилку "профіль не знайдено"
        // Поки що повернемо помилку, але AuthGate має це обробляти
        emit(const UserProfileError("User profile not found. It might be still creating."));
      }
    } catch (e) {
      emit(UserProfileError("Failed to fetch profile: ${e.toString()}"));
    }
  }

  // Метод для оновлення профілю ззовні (наприклад, після ProfileSetup)
  void updateUserProfileState(UserProfile updatedProfile) {
    emit(UserProfileLoaded(updatedProfile));
  }

  // Слухаємо зміни в Firestore для UserProfile (опціонально, для оновлень в реальному часі)
  void _listenToUserProfileChanges(String userId) {
    _userProfileSubscription?.cancel(); // Скасовуємо попередню підписку, якщо є
    _userProfileSubscription = _userProfileRepository.getUserProfileStream(userId).listen( // Припускаємо, що такий метод є
      (userProfile) {
        if (userProfile != null) {
          emit(UserProfileLoaded(userProfile));
        } else {
          // Можливо, користувача видалили або сталася помилка
          emit(const UserProfileError("User profile stream returned null."));
        }
      },
      onError: (error) {
        emit(UserProfileError("Error in profile stream: ${error.toString()}"));
      }
    );
  }


  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    return super.close();
  }
}