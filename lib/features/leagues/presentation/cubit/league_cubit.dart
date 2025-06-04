// lib/features/leagues/presentation/cubit/league_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Якщо потрібен userId
import '../../../../core/domain/entities/league_info.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/league_repository.dart';
// import '../../../../core/domain/repositories/user_profile_repository.dart'; // Може не знадобитись тут
import 'dart:developer' as developer;

part 'league_state.dart';

class LeagueCubit extends Cubit<LeagueState> {
  final LeagueRepository _leagueRepository;
  final fb_auth.FirebaseAuth _firebaseAuth; // Опціонально, якщо потрібен userId
  // final UserProfileRepository _userProfileRepository; // Якщо потрібна інфо про поточного юзера

  LeagueCubit(
    this._leagueRepository,
    this._firebaseAuth,
    // this._userProfileRepository, 
    {required LeagueInfo initialLeague}
  ) : super(LeagueState(currentLeague: initialLeague));

  Future<void> fetchLeaderboard() async {
    // Не обов'язково тут перевіряти _firebaseAuth.currentUser,
    // якщо для запиту лідерборда не потрібен ID поточного користувача.
    // Але якщо потрібен (наприклад, щоб підсвітити його в списку), то розкоментуйте.
    // final userId = _firebaseAuth.currentUser?.uid;
    // if (userId == null && _someConditionThatRequiresUserId) {
    //   emit(state.copyWith(status: LeagueStatus.error, errorMessage: "User not authenticated."));
    //   return;
    // }

    developer.log("LeagueCubit: Fetching leaderboard for league: ${state.currentLeague.name}", name: "LeagueCubit");
    emit(state.copyWith(status: LeagueStatus.loading));

    try {
      final leaderboard = await _leagueRepository.getLeaderboardForLeague(state.currentLeague);
      emit(state.copyWith(
        status: LeagueStatus.loaded,
        leaderboard: leaderboard,
        errorMessage: null, // Очищаємо помилку при успіху
      ));
      developer.log("LeagueCubit: Leaderboard loaded with ${leaderboard.length} users for ${state.currentLeague.name}.", name: "LeagueCubit");
    } catch (e, s) {
      developer.log('Error fetching leaderboard for league ${state.currentLeague.name}: $e', name: 'LeagueCubit', error: e, stackTrace: s);
      emit(state.copyWith(
        status: LeagueStatus.error,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
        // Можна залишити старий список лідерів при помилці, якщо хочемо
        // leaderboard: state.leaderboard, 
      ));
    }
  }

  // Можна додати метод для оновлення поточної ліги, якщо у вас буде екран зі списком ліг
  // void changeCurrentLeague(LeagueInfo newLeague) {
  //   emit(state.copyWith(currentLeague: newLeague, leaderboard: [], status: LeagueStatus.initial));
  //   fetchLeaderboard(); // Автоматично завантажити лідерборд для нової ліги
  // }
}