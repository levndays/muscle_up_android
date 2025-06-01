// lib/core/domain/repositories/league_repository.dart
import '../entities/league_info.dart';

abstract class LeagueRepository {
  Future<List<LeagueInfo>> getAllLeagues();
  // Можливо, в майбутньому:
  // Future<LeagueInfo?> getLeagueById(String leagueId);
}