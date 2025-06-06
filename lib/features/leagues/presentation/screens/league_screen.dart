// lib/features/leagues/presentation/screens/league_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;
import 'package:muscle_up/l10n/app_localizations.dart';

import '../../../../core/domain/entities/league_info.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/league_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/league_cubit.dart';
import '../widgets/animated_spotlight_background.dart';
import '../widgets/leaderboard_list_item_widget.dart';
import '../../../progress/presentation/widgets/league_title_widget.dart';
import '../../../profile/presentation/cubit/user_profile_cubit.dart';

class LeagueScreen extends StatelessWidget {
  final LeagueInfo currentLeague;

  const LeagueScreen({super.key, required this.currentLeague});

  static Route route({required LeagueInfo currentLeague}) {
    return MaterialPageRoute<void>(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<UserProfileCubit>(
            create: (ctx) => UserProfileCubit(
              RepositoryProvider.of<UserProfileRepository>(ctx),
              RepositoryProvider.of<fb_auth.FirebaseAuth>(ctx),
            ),
          ),
          BlocProvider<LeagueCubit>(
            create: (ctx) => LeagueCubit(
              RepositoryProvider.of<LeagueRepository>(ctx),
              RepositoryProvider.of<fb_auth.FirebaseAuth>(ctx),
              initialLeague: currentLeague,
            )..fetchLeaderboard(),
          ),
        ],
        child: LeagueScreen(currentLeague: currentLeague),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _LeagueScreenView();
  }
}

class _LeagueScreenView extends StatelessWidget {
  const _LeagueScreenView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final leagueInfo = context.watch<LeagueCubit>().state.currentLeague;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedSpotlightBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 4.0, right: 16.0, bottom: 5.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: loc.leagueScreenButtonBackTooltip,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: LeagueTitleWidget(
                    leagueName: leagueInfo.name,
                    level: leagueInfo.minLevel,
                    gradientColors: leagueInfo.gradientColors,
                    showLevel: false,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.leagueScreenLeaderboardTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                     shadows: [
                      const Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 3),
                    ]
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: BlocBuilder<LeagueCubit, LeagueState>(
                    builder: (context, state) {
                      if (state.status == LeagueStatus.loading && state.leaderboard.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (state.status == LeagueStatus.error && state.leaderboard.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                                const SizedBox(height: 16),
                                Text(loc.leagueScreenErrorLoad(state.errorMessage ?? loc.recordStatusUnknown), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<LeagueCubit>().fetchLeaderboard(),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                                  child: Text(loc.leagueScreenButtonTryAgain, style: const TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                          )
                        );
                      }
                      if (state.leaderboard.isEmpty) {
                        return Center(
                          child: Text(
                            loc.leagueScreenNoPlayers,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                          ),
                        );
                      }

                      final leaderboard = state.leaderboard;
                      return RefreshIndicator(
                        onRefresh: () async {
                           context.read<LeagueCubit>().fetchLeaderboard();
                        },
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: leaderboard.length,
                          itemBuilder: (ctx, index) {
                            final user = leaderboard[index];
                            return LeaderboardListItemWidget(
                              userProfile: user,
                              rank: index + 1,
                              currentUserId: RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}