// lib/features/progress/presentation/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;
import 'dart:ui' as ui show lerpDouble, PathMetric, Path;
import 'package:muscle_up/l10n/app_localizations.dart'; // Import AppLocalizations

import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../../../../core/domain/repositories/league_repository.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart';
import '../cubit/progress_cubit.dart';
import '../widgets/league_title_widget.dart';
import '../widgets/xp_progress_bar_widget.dart';
import '../widgets/muscle_map_widget.dart';
import '../../../../core/domain/entities/app_notification.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/widgets/notification_list_item.dart';
import '../../../leagues/presentation/screens/league_screen.dart';


class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressCubit(
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<LeagueRepository>(context),
        RepositoryProvider.of<WorkoutLogRepository>(context),
        RepositoryProvider.of<PredefinedExerciseRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
      ),
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  static const Color primaryOrange = Color(0xFFED5D1A);
  static const Color trendUpColor = Colors.green;
  static const Color trendDownColor = Colors.redAccent;
  static const Color trendNeutralColor = Colors.grey;

  void _createTestAdviceNotifications(BuildContext ctx) {
    final loc = AppLocalizations.of(ctx)!;
    final cubit = ctx.read<NotificationsCubit>();
    cubit.createTestNotification(
      title: loc.testNotificationAdviceTitle1,
      message: loc.testNotificationAdviceMessage1,
      type: NotificationType.advice
    );
    cubit.createTestNotification(
      title: loc.testNotificationAdviceTitle2,
      message: loc.testNotificationAdviceMessage2,
      type: NotificationType.advice
    );
     cubit.createTestNotification(
      title: loc.testNotificationAdviceTitle3,
      message: loc.testNotificationAdviceMessage3,
      type: NotificationType.advice
    );
    developer.log("Test ADVICE notifications creation requested from ProgressScreen", name: "ProgressScreen");
     ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(loc.testNotificationAdviceSentSnackbar), duration: const Duration(seconds: 3),)
    );
  }


  Color _getRpeColor(double rpeValue) {
    final double t = (rpeValue.clamp(0, 10) / 10.0);
    if (t <= 0.35) {
      return Color.lerp(Colors.green.shade500, Colors.yellow.shade600, t / 0.35)!;
    } else if (t <= 0.7) {
      return Color.lerp(Colors.yellow.shade600, Colors.orange.shade700, (t - 0.35) / 0.35)!;
    } else {
      return Color.lerp(Colors.orange.shade700, Colors.red.shade700, (t - 0.7) / 0.3)!;
    }
  }

  Color _getTrendColor(List<double> dataPoints) {
    if (dataPoints.length < 2) return trendNeutralColor;
    final double first = dataPoints.first;
    final double last = dataPoints.last;
    if (last > first) return trendUpColor;
    if (last < first) return trendDownColor;
    return trendNeutralColor;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!; 

    return Scaffold(
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          Widget contentToShow;

          if (state is ProgressInitial) {
            contentToShow = const Center(child: CircularProgressIndicator());
          } else if (state is ProgressLoading) {
            contentToShow = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (state.message != null) ...[
                    const SizedBox(height: 16),
                    Text(state.message!, textAlign: TextAlign.center),
                  ]
                ],
              ),
            );
          } else if (state is ProgressError) {
            contentToShow = Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(loc.progressScreenErrorLoadingProfile(state.message), textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)), 
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProgressCubit>().refreshData(),
                      child: Text(loc.progressScreenButtonTryAgain), 
                    )
                  ],
                ),
              )
            );
          } else if (state is ProgressLoaded) {
            final userProfile = state.userProfile;
            final currentLeague = state.currentLeague;

            final int xpPerLevelBase = 200;
            int calculateTotalXpForLevelStart(int level) {
              if (level <= 1) return 0;
              int totalXp = 0;
              for (int i = 1; i < level; i++) {
                totalXp += (xpPerLevelBase + (i - 1) * 50);
              }
              return totalXp;
            }
            int currentLevelXpStart = calculateTotalXpForLevelStart(userProfile.level);
            int xpToNextLevelTotal = (xpPerLevelBase + (userProfile.level - 1) * 50);
            if (xpToNextLevelTotal <= 0) xpToNextLevelTotal = xpPerLevelBase;
            
            final int currentXpInLevel = (userProfile.xp - currentLevelXpStart).clamp(0, xpToNextLevelTotal);
            final int xpToNext = xpToNextLevelTotal - currentXpInLevel;

            final String gender = userProfile.gender?.toLowerCase() ?? 'male';
            final String frontSvgPath = gender == 'female'
                ? 'assets/images/female_front.svg'
                : 'assets/images/male_front.svg';
            final String backSvgPath = gender == 'female'
                ? 'assets/images/female_back.svg'
                : 'assets/images/male_back.svg';

            const Color baseMuscleColor = Color(0xFFF0F0F0);
            const Color midMuscleColor = primaryOrange;
            const Color maxMuscleColor = Color(0xFFD50000);
            const double midThresholdMuscle = 10.0;
            const double maxThresholdMuscle = 20.0;

            final exercisesWithRpeTrend = state.rpePerWorkoutTrend.entries
                .where((entry) => entry.value.isNotEmpty)
                .toList();

            final exercisesWithWeightTrend = state.workingWeightPerWorkoutTrend.entries
                .where((entry) => entry.value.isNotEmpty)
                .toList();


            contentToShow = SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LeagueTitleWidget(
                      leagueName: currentLeague.name, 
                      level: userProfile.level,
                      gradientColors: currentLeague.gradientColors,
                      onLeagueTap: () {
                        Navigator.of(context).push(LeagueScreen.route(currentLeague: currentLeague));
                        developer.log("Tapped on League: ${currentLeague.name}", name: "ProgressScreen.LeagueTap");
                      },
                    ),
                    const SizedBox(height: 12),
                    XPProgressBarWidget(
                      currentXp: currentXpInLevel,
                      xpForNextLevel: state.xpForNextLevelTotal,
                      startLevelXpText: loc.progressScreenXpProgressText(currentXpInLevel.toString(), state.xpForNextLevelTotal.toString()),
                      endLevelXpText: loc.progressScreenLevelLabel(userProfile.level + 1),
                    ),
                    Center(
                      child: Text(
                        loc.progressScreenXpToNextLevel(xpToNext), // <<< FIXED
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(loc.progressScreenVolumeTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), 
                    const SizedBox(height: 10),
                    if (state.volumePerMuscleGroup7Days.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text(loc.progressScreenNoVolumeData, style: TextStyle(color: Colors.grey.shade600))), 
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MuscleMapWidget(
                              key: ValueKey('front_map_${userProfile.gender}_${state.volumePerMuscleGroup7Days.hashCode}'),
                              svgPath: frontSvgPath,
                              muscleData: state.volumePerMuscleGroup7Days,
                              baseColor: baseMuscleColor,
                              midColor: midMuscleColor,
                              maxColor: maxMuscleColor,
                              midThreshold: midThresholdMuscle,
                              maxThreshold: maxThresholdMuscle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MuscleMapWidget(
                              key: ValueKey('back_map_${userProfile.gender}_${state.volumePerMuscleGroup7Days.hashCode}'),
                              svgPath: backSvgPath,
                              muscleData: state.volumePerMuscleGroup7Days,
                              baseColor: baseMuscleColor,
                              midColor: midMuscleColor,
                              maxColor: maxMuscleColor,
                              midThreshold: midThresholdMuscle,
                              maxThreshold: maxThresholdMuscle,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),

                    Text(loc.progressScreenRpeTrendTitle(ProgressCubit.maxWorkoutsForTrend), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), 
                    const SizedBox(height: 10),
                    if (exercisesWithRpeTrend.isEmpty)
                      Text(loc.progressScreenNoRpeData, style: const TextStyle(color: Colors.grey)) 
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercisesWithRpeTrend.length,
                        itemBuilder: (context, index) {
                          final entry = exercisesWithRpeTrend[index];
                          final exerciseName = context.read<ProgressCubit>().getExerciseNameById(context, entry.key);
                          final double rpeForColorAndAvg = state.avgRpePerExercise30Days[entry.key] ??
                                                     (entry.value.isNotEmpty ? entry.value.reduce((a,b) => a+b) / entry.value.length : 5.0);
                          final rpeColor = _getRpeColor(rpeForColorAndAvg);

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exerciseName.toUpperCase(),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                            fontSize: 15,
                                          )
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${loc.progressScreenAvgRpeLabel}${rpeForColorAndAvg.toStringAsFixed(1)}', 
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: rpeColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 30,
                                      child: ValueSparkline(
                                        dataPoints: entry.value,
                                        lineColor: rpeColor,
                                        smooth: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 30),

                    Text(loc.progressScreenStrengthTrendTitle(ProgressCubit.maxWorkoutsForTrend), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), 
                    const SizedBox(height: 10),
                     if (exercisesWithWeightTrend.isEmpty)
                      Text(loc.progressScreenNoWeightData, style: const TextStyle(color: Colors.grey)) 
                    else
                       ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercisesWithWeightTrend.length,
                        itemBuilder: (context, index) {
                          final entry = exercisesWithWeightTrend[index];
                          final exerciseName = context.read<ProgressCubit>().getExerciseNameById(context, entry.key);
                          final double avgWeight = entry.value.isNotEmpty ? entry.value.reduce((a,b) => a+b) / entry.value.length : 0.0;
                          final trendColor = _getTrendColor(entry.value);

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exerciseName.toUpperCase(),
                                           style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                            fontSize: 15,
                                          )
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${loc.progressScreenAvgWeightLabel}${avgWeight.toStringAsFixed(1)} ${loc.progressScreenKgUnit}', 
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: trendColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 30,
                                      child: ValueSparkline(
                                        dataPoints: entry.value,
                                        lineColor: trendColor,
                                        smooth: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 30),

                    Text(loc.progressScreenAdviceTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), 
                    const SizedBox(height: 10),
                    BlocBuilder<NotificationsCubit, NotificationsState>(
                      builder: (context, notificationsState) {
                        if (notificationsState is NotificationsLoaded) {
                          final adviceNotifications = notificationsState.notifications
                              .where((n) => n.type == NotificationType.advice)
                              .take(3) 
                              .toList();
                          if (adviceNotifications.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(loc.progressScreenNoAdvice, style: const TextStyle(color: Colors.blueGrey)), 
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: adviceNotifications.length,
                            itemBuilder: (ctx, index) {
                              return NotificationListItem(notification: adviceNotifications[index]);
                            },
                          );
                        } else if (notificationsState is NotificationsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (notificationsState is NotificationsError) {
                          return Text(loc.progressScreenErrorLoadAdvice(notificationsState.message), style: const TextStyle(color: Colors.red)); 
                        }
                        return Text(loc.progressScreenLoadingAdvice); 
                      },
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.lightbulb_outline),
                        label: Text(loc.progressScreenButtonSendTestAdvice), 
                        onPressed: () => _createTestAdviceNotifications(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent.shade400,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
          } else {
            contentToShow = Center(child: Text(loc.progressScreenNoData)); 
            developer.log("ProgressScreen: Reached unexpected state: $state", name: "ProgressScreen.Build");
          }

          return RefreshIndicator(
            onRefresh: () async {
              developer.log("Pull-to-refresh initiated on ProgressScreen", name: "ProgressScreen.Refresh");
              context.read<ProgressCubit>().refreshData();
            },
            child: contentToShow,
          );
        },
      ),
    );
  }
}

class ValueSparkline extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final double strokeWidth;
  final bool smooth;

  const ValueSparkline({
    super.key,
    required this.dataPoints,
    this.lineColor = Colors.orange,
    this.strokeWidth = 2.0,
    this.smooth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.length < 2) {
      return Container(
        alignment: Alignment.center,
        child: Text('~', style: TextStyle(fontSize: 24, color: lineColor.withOpacity(0.5))),
      );
    }
    return CustomPaint(
      painter: _SparklinePainter(
          dataPoints: dataPoints,
          lineColor: lineColor,
          strokeWidth: strokeWidth,
          smooth: smooth),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final double strokeWidth;
  final bool smooth;

  _SparklinePainter({
    required this.dataPoints,
    required this.lineColor,
    required this.strokeWidth,
    required this.smooth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    double maxVal = dataPoints.reduce((a, b) => a > b ? a : b);

    double paddingY = (maxVal - minVal) * 0.15;
    if (paddingY < 0.5 && maxVal > 0) paddingY = 0.5;
    if (maxVal - minVal < 1.0) { 
        minVal = minVal - 0.5; 
        maxVal = maxVal + 0.5;
    } else { 
        paddingY = (maxVal - minVal) * 0.1; 
        minVal -= paddingY;
        maxVal += paddingY;
    }
    if (minVal == maxVal) { 
        minVal -= 0.5; 
        maxVal += 0.5;
    }


    double valRange = maxVal - minVal;
    if (valRange == 0) valRange = 1;

    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      double x = (i / (dataPoints.length - 1)) * size.width;
      double y = size.height * (1 - ((dataPoints[i] - minVal) / valRange));
      points.add(Offset(x, y.clamp(0.0, size.height)));
    }

    if (!smooth || points.length < 2) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    } else {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i+1];

        final cp1x = p0.dx + (p1.dx - p0.dx) / 2.5;
        final cp1y = p0.dy;
        final cp2x = p1.dx - (p1.dx - p0.dx) / 2.5;
        final cp2y = p1.dy;

        path.cubicTo(cp1x, cp1y, cp2x, cp2y, p1.dx, p1.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
           oldDelegate.lineColor != lineColor ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.smooth != smooth;
  }
}