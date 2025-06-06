// FILE: lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:muscle_up/l10n/app_localizations.dart';

import '../../../../core/domain/entities/app_notification.dart';
import '../../../profile/presentation/cubit/user_profile_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/widgets/notification_list_item.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/routine_repository.dart';

import '../cubit/dashboard_stats_cubit.dart';
import '../widgets/volume_trend_chart_widget.dart';
import '../cubit/upcoming_schedule_cubit.dart';
import '../widgets/upcoming_schedule_widget.dart';


class DashboardScreen extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onProgressTap;

  const DashboardScreen({
    super.key,
    required this.onProfileTap,
    required this.onProgressTap,
  });

  static const Color primaryOrange = Color(0xFFED5D1A);
  static const Color textBlack = Colors.black87;
  static const String ibmPlexMonoFont = 'IBMPlexMono';

  Widget _buildStatsItem(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textBlack,
                fontFamily: ibmPlexMonoFont,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
        ),
      ],
    );
  }

  void _createTestNotifications(BuildContext ctx) {
    final cubit = ctx.read<NotificationsCubit>();
    cubit.createTestNotification(title: "Welcome Bonus!", message: "You've received 100 XP for joining!", type: NotificationType.achievementUnlocked);
    cubit.createTestNotification(title: "Workout Scheduled", message: "Your 'Full Body Blast' is set for tomorrow.", type: NotificationType.workoutReminder);
    cubit.createTestNotification(title: "App Maintenance", message: "Scheduled maintenance on Sunday, 2 AM.", type: NotificationType.systemMessage);
    developer.log("Test notifications creation requested from Dashboard", name: "DashboardScreen");
  }


  @override
  Widget build(BuildContext context) {
    developer.log("DashboardScreen: Building UI", name: "DashboardScreen");
    final loc = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (cubitContext) => DashboardStatsCubit(
            RepositoryProvider.of<WorkoutLogRepository>(cubitContext),
            RepositoryProvider.of<RoutineRepository>(cubitContext),
            RepositoryProvider.of<fb_auth.FirebaseAuth>(cubitContext),
          ),
        ),
        BlocProvider(
          create: (cubitContext) => UpcomingScheduleCubit(
            RepositoryProvider.of<RoutineRepository>(cubitContext),
            RepositoryProvider.of<fb_auth.FirebaseAuth>(cubitContext),
          ),
        ),
      ],
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, userState) {
          developer.log("DashboardScreen: UserProfileCubit state: $userState", name: "DashboardScreen");

          String greetingName = 'User'; // Fallback
          String weightStat = '-- KG';
          String streakStat = '0'; // CHANGED: Removed "DAY"
          String currentStreakForIcon = "0";

          if (userState is UserProfileLoaded) {
            final userProfile = userState.userProfile;
            greetingName = userProfile.displayName?.isNotEmpty == true
                ? userProfile.displayName!.split(' ').first
                : userProfile.username?.isNotEmpty == true
                    ? userProfile.username!
                    : userProfile.email?.split('@').first ?? loc.profileScreenNameFallbackUser; // LOCALIZED FALLBACK
            weightStat = userProfile.weightKg != null
                ? '${userProfile.weightKg!.toStringAsFixed(1)} ${loc.profileScreenUnitKg}' // LOCALIZED UNIT
                : '-- ${loc.profileScreenUnitKg}'; // LOCALIZED UNIT
            streakStat = userProfile.currentStreak.toString(); // CHANGED
            currentStreakForIcon = userProfile.currentStreak.toString();
          } else if (userState is UserProfileLoading) {
            greetingName = loc.dashboardNotificationsLoading.split(' ').first; // "Loading..."
            weightStat = '... ${loc.profileScreenUnitKg}'; // LOCALIZED UNIT
            streakStat = '...'; // CHANGED
            currentStreakForIcon = "...";
          } else if (userState is UserProfileError) {
            greetingName = 'Error'; // This can be localized as loc.errorGeneric or similar
            weightStat = 'N/A';
            streakStat = 'N/A';
            currentStreakForIcon = "!";
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;
              if (userId != null) {
                context.read<UserProfileCubit>().fetchUserProfile(userId, forceRemote: true);
                context.read<NotificationsCubit>().refreshNotifications();
              }
              context.read<DashboardStatsCubit>().fetchAllDashboardStats();
              context.read<UpcomingScheduleCubit>().fetchUpcomingSchedule();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onProfileTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.dashboardGreetingWelcome,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: textBlack,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              Text(
                                greetingName,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: primaryOrange,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onProgressTap,
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: primaryOrange, size: 32),
                            const SizedBox(width: 6),
                            Text(
                              currentStreakForIcon,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: primaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.dashboardSectionStats,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textBlack,
                          fontFamily: ibmPlexMonoFont,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
                    builder: (context, statsState) {
                      if (statsState is DashboardStatsLoading) {
                        return Container(
                          height: 150,
                          decoration: BoxDecoration(
                             color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[850]?.withAlpha((0.3 * 255).round())
                                : Colors.grey[200]?.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: CircularProgressIndicator(color: primaryOrange)),
                        );
                      } else if (statsState is DashboardStatsLoaded) {
                        return VolumeTrendChartWidget(volumes: statsState.volumes);
                      } else if (statsState is DashboardStatsError) {
                         return Container(
                          height: 150,
                           decoration: BoxDecoration(
                             color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.red[900]?.withAlpha((0.3 * 255).round())
                                : Colors.red[100]?.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                loc.volumeTrendChartError(statsState.message), // LOCALIZED
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                           color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[850]?.withAlpha((0.3 * 255).round())
                              : Colors.grey[200]?.withAlpha((0.3 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(loc.volumeTrendChartLoading, style: const TextStyle(color: Colors.grey))), // LOCALIZED
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  BlocBuilder<DashboardStatsCubit, DashboardStatsState>(
                    builder: (context, statsState) {
                      String adherenceDisplay = '-- %';
                      if (statsState is DashboardStatsLoaded) {
                        if (statsState.adherencePercentage != null) {
                          adherenceDisplay = '${statsState.adherencePercentage!.toStringAsFixed(0)}%';
                        } else {
                          adherenceDisplay = 'N/A';
                        }
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatsItem(context, weightStat, loc.dashboardStatsWeightLabel),
                          _buildStatsItem(context, streakStat, loc.dashboardStatsStreakLabel), // <-- This will now show only the number
                          _buildStatsItem(context, adherenceDisplay, loc.dashboardStatsAdherenceLabel),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 32),

                  const UpcomingScheduleWidget(),
                  const SizedBox(height: 32),

                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, notificationsState) {
                      int unreadNotificationsCount = 0;
                      if (notificationsState is NotificationsLoaded) {
                        unreadNotificationsCount = notificationsState.unreadCount;
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            loc.dashboardSectionNotifications,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: textBlack,
                                  fontFamily: ibmPlexMonoFont,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          if (unreadNotificationsCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: const BoxDecoration(
                                color: primaryOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadNotificationsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Spacer(),
                           if (notificationsState is NotificationsLoaded && notificationsState.unreadCount > 0)
                            TextButton(
                              onPressed: () {
                                context.read<NotificationsCubit>().markAllNotificationsAsRead();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(loc.dashboardSnackbarAllNotificationsRead), duration: const Duration(seconds: 2),)
                                );
                              },
                              child: Text(
                                loc.dashboardNotificationsReadAll,
                                style: const TextStyle(
                                  fontFamily: ibmPlexMonoFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, notificationsState) {
                      if (notificationsState is NotificationsLoading && notificationsState is! NotificationsLoaded) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: CircularProgressIndicator(),
                        ));
                      } else if (notificationsState is NotificationsLoaded) {
                        final notificationsToShow = notificationsState.notifications.take(5).toList();
                        if (notificationsToShow.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                loc.dashboardNotificationsEmpty,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notificationsToShow.length,
                          itemBuilder: (context, index) {
                            return NotificationListItem(notification: notificationsToShow[index]);
                          },
                        );
                      } else if (notificationsState is NotificationsError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              loc.dashboardNotificationsError(notificationsState.message),
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text(loc.dashboardNotificationsLoading)),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_to_mobile_outlined),
                      label: Text(loc.dashboardButtonSendTestNotifications), // LOCALIZED
                      onPressed: () => _createTestNotifications(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}