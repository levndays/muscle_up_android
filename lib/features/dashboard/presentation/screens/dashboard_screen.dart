// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/app_notification.dart'; // Потрібно для NotificationType
import '../../../profile/presentation/cubit/user_profile_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/widgets/notification_list_item.dart';

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

  // Функція для створення тестових сповіщень
  // ================== ТИМЧАСОВА ТЕСТОВА ФУНКЦІЯ (початок) ==================
  void _createTestNotifications(BuildContext ctx) {
    final cubit = ctx.read<NotificationsCubit>();
    // ВИПРАВЛЕНО: прибрано iconName, оскільки він визначається на основі type в репозиторії
    cubit.createTestNotification(title: "Welcome Bonus!", message: "You've received 100 XP for joining!", type: NotificationType.achievementUnlocked);
    cubit.createTestNotification(title: "Workout Scheduled", message: "Your 'Full Body Blast' is set for tomorrow.", type: NotificationType.workoutReminder);
    cubit.createTestNotification(title: "App Maintenance", message: "Scheduled maintenance on Sunday, 2 AM.", type: NotificationType.systemMessage);
    developer.log("Test notifications creation requested from Dashboard", name: "DashboardScreen");
  }
  // ================== ТИМЧАСОВА ТЕСТОВА ФУНКЦІЯ (кінець) ==================


  @override
  Widget build(BuildContext context) {
    developer.log("DashboardScreen: Building UI", name: "DashboardScreen");

    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, userState) {
        // ... (код для UserProfileCubit без змін) ...
        developer.log("DashboardScreen: UserProfileCubit state: $userState", name: "DashboardScreen");

        String greetingName = 'User';
        String weightStat = '-- KG';
        String streakStat = '0 DAY';
        String currentStreakForIcon = "0";

        if (userState is UserProfileLoaded) {
          final userProfile = userState.userProfile;
          greetingName = userProfile.displayName?.isNotEmpty == true
              ? userProfile.displayName!.split(' ').first
              : userProfile.username?.isNotEmpty == true
                  ? userProfile.username!
                  : userProfile.email?.split('@').first ?? 'User';
          weightStat = userProfile.weightKg != null
              ? '${userProfile.weightKg!.toStringAsFixed(1)} KG'
              : '-- KG';
          streakStat = '${userProfile.currentStreak} DAY';
          currentStreakForIcon = userProfile.currentStreak.toString();
        } else if (userState is UserProfileLoading) {
          greetingName = 'Loading...';
          weightStat = '... KG';
          streakStat = '... DAY';
          currentStreakForIcon = "...";
        } else if (userState is UserProfileError) {
          greetingName = 'Error';
          weightStat = 'N/A';
          streakStat = 'N/A';
          currentStreakForIcon = "!";
        }


        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row( // Вітання та іконка вогника
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
                            'Welcome,',
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
              Text( // STATS
                'STATS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textBlack,
                      fontFamily: ibmPlexMonoFont,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container( // Графік (плейсхолдер)
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha((0.3 * 255).round()))
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'TOTAL VOLUME OVER LAST 7 DAYS GRAPH PLACEHOLDER',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textBlack, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row( // Статистика: вага, стрік, прихильність
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatsItem(context, weightStat, 'WEIGHT'),
                  _buildStatsItem(context, streakStat, 'STREAK'),
                  _buildStatsItem(context, '100%', 'ADHERENCE'),
                ],
              ),
              const SizedBox(height: 32),

              // --- СЕКЦІЯ СПОВІЩЕНЬ ---
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
                        'NOTIFICATIONS',
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
                              const SnackBar(content: Text('All notifications marked as read!'), duration: Duration(seconds: 2),)
                            );
                          },
                          child: const Text(
                            'READ ALL',
                            style: TextStyle(
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
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            'No new notifications.',
                            style: TextStyle(color: Colors.grey),
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
                          'Error loading notifications: ${notificationsState.message}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text('Loading notifications...')),
                  );
                },
              ),
              
              // ================== ТИМЧАСОВА ТЕСТОВА КНОПКА (початок) ==================
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_to_mobile_outlined),
                  label: const Text("Send Test Notifications"),
                  onPressed: () => _createTestNotifications(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              // ================== ТИМЧАСОВА ТЕСТОВА КНОПКА (кінець) ==================

              const SizedBox(height: 70),
            ],
          ),
        );
      },
    );
  }
}