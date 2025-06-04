// lib/features/leagues/presentation/cubit/league_state.dart
part of 'league_cubit.dart';

enum LeagueStatus { initial, loading, loaded, error }

class LeagueState extends Equatable {
  final LeagueInfo currentLeague;
  final List<UserProfile> leaderboard;
  final LeagueStatus status;
  final String? errorMessage;

  const LeagueState({
    required this.currentLeague,
    this.leaderboard = const [],
    this.status = LeagueStatus.initial,
    this.errorMessage,
  });

  LeagueState copyWith({
    LeagueInfo? currentLeague,
    List<UserProfile>? leaderboard,
    LeagueStatus? status,
    String? errorMessage,
    bool allowNullErrorMessage = false, // Для можливості скинути errorMessage в null
  }) {
    return LeagueState(
      currentLeague: currentLeague ?? this.currentLeague,
      leaderboard: leaderboard ?? this.leaderboard,
      status: status ?? this.status,
      errorMessage: allowNullErrorMessage ? errorMessage : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [currentLeague, leaderboard, status, errorMessage];
}