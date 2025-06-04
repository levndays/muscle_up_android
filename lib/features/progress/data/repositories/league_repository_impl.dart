// lib/features/progress/data/repositories/league_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
import '../../../../core/domain/entities/league_info.dart';
import '../../../../core/domain/entities/user_profile.dart'; // NEW
import '../../../../core/domain/repositories/league_repository.dart';
import 'dart:developer' as developer;

class LeagueRepositoryImpl implements LeagueRepository {
  final FirebaseFirestore _firestore;

  LeagueRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LeagueInfo>> getAllLeagues() async {
    try {
      final snapshot = await _firestore
          .collection('leagues')
          .orderBy('minLevel') 
          .get();
      if (snapshot.docs.isEmpty) {
        developer.log("No leagues found in Firestore. Returning default set.", name: "LeagueRepoImpl");
        return _getDefaultLeagues(); 
      }
      return snapshot.docs
          .map((doc) => LeagueInfo.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e, s) {
      developer.log("Error fetching leagues: $e", name: "LeagueRepoImpl", error: e, stackTrace: s);
      developer.log("Returning default leagues due to error.", name: "LeagueRepoImpl");
      return _getDefaultLeagues(); 
    }
  }
  
  @override
  Future<List<UserProfile>> getLeaderboardForLeague(LeagueInfo league, {int limit = 20}) async {
    developer.log("Fetching leaderboard for league: ${league.name} (Levels: ${league.minLevel}-${league.maxLevel ?? '∞'})", name: "LeagueRepoImpl");
    try {
      Query query = _firestore.collection('users')
          .where('profileSetupComplete', isEqualTo: true) // Only show completed profiles
          .where('level', isGreaterThanOrEqualTo: league.minLevel);

      if (league.maxLevel != null) {
        query = query.where('level', isLessThanOrEqualTo: league.maxLevel!);
      }
      // We order by XP descending primarily, and then by username to break ties and for consistent pagination if added.
      query = query.orderBy('xp', descending: true).orderBy('username').limit(limit);
      
      final snapshot = await query.get();
      developer.log("Leaderboard query for ${league.name} returned ${snapshot.docs.length} users.", name: "LeagueRepoImpl");
      
      return snapshot.docs.map((doc) {
        try {
          return UserProfile.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          developer.log("Error parsing user profile for leaderboard: ${doc.id}, error: $e", name: "LeagueRepoImpl");
          // Return a dummy or skip if parsing fails for a user
          return UserProfile(uid: doc.id, email: "Error", xp: 0, level: 0, profileSetupComplete: false, createdAt: Timestamp.now(), updatedAt: Timestamp.now()); 
        }
      }).where((profile) => profile.email != "Error").toList(); // Filter out parsing errors
    } catch (e, s) {
      developer.log("Error fetching leaderboard for league ${league.name}: $e", name: "LeagueRepoImpl", error: e, stackTrace: s);
      throw Exception('Failed to fetch leaderboard for league ${league.name}: ${e.toString()}');
    }
  }


  List<LeagueInfo> _getDefaultLeagues() {
    const Color primaryOrange = Color(0xFFED5D1A);
    return [
      LeagueInfo(leagueId: 'beginner', name: 'BEGINNER LEAGUE', minLevel: 1, maxLevel: 14, minXp: 0, gradientColors: [primaryOrange, Colors.black], description: 'Start your journey!'),
      LeagueInfo(leagueId: 'intermediate', name: 'INTERMEDIATE LEAGUE', minLevel: 15, maxLevel: 49, minXp: 0, gradientColors: [Colors.blue, Colors.lightBlueAccent], description: 'Keep pushing!'),
      LeagueInfo(leagueId: 'advanced', name: 'ADVANCED LEAGUE', minLevel: 50, maxLevel: 79, minXp: 0, gradientColors: [Colors.purple, Colors.deepPurpleAccent], description: 'You are strong!'),
      const LeagueInfo(leagueId: 'bronze', name: 'BRONZE LEAGUE', minLevel: 80, maxLevel: 99, minXp: 0, gradientColors: [Color(0xFFCD7F32), Color(0xFF8C531B)], description: 'Elite warrior!'),
      const LeagueInfo(leagueId: 'silver', name: 'SILVER LEAGUE', minLevel: 100, maxLevel: 149, minXp: 0, gradientColors: [Color(0xFFC0C0C0), Color(0xFFAEAFAF)], description: 'Shining bright!'),
      const LeagueInfo(leagueId: 'golden', name: 'GOLDEN LEAGUE', minLevel: 150, maxLevel: null, minXp: 0, gradientColors: [Color(0xFFFFD700), Color(0xFFE5C100)], description: 'Legendary status!'),
    ];
  }
}