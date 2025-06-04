// lib/core/domain/repositories/league_repository.dart
import '../entities/league_info.dart';
import '../entities/user_profile.dart'; // NEW: For leaderboard users

abstract class LeagueRepository {
  Future<List<LeagueInfo>> getAllLeagues();
  // Можливо, в майбутньому:
  // Future<LeagueInfo?> getLeagueById(String leagueId);

  // NEW: Method to get leaderboard for a specific league
  Future<List<UserProfile>> getLeaderboardForLeague(
    LeagueInfo league, {
    int limit = 20, // How many users to fetch
    // String? lastFetchedUserId, // For pagination if needed in future
  });
}