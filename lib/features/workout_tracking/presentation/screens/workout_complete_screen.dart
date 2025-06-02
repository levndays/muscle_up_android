// lib/features/workout_tracking/presentation/screens/workout_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../auth_gate.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final WorkoutSession completedSession;
  final int xpGained;
  final UserProfile userProfileAtCompletion;

  const WorkoutCompleteScreen({
    super.key,
    required this.completedSession,
    required this.xpGained,
    required this.userProfileAtCompletion,
  });

  static Route<void> route(WorkoutSession session, int xp, UserProfile profile) {
    return MaterialPageRoute<void>(
      builder: (_) => WorkoutCompleteScreen(
          completedSession: session,
          xpGained: xp,
          userProfileAtCompletion: profile
      ),
      fullscreenDialog: true,
    );
  }

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _xpFillController;
  late Animation<double> _xpFillAnimation;

  final int xpPerLevelBase = 200;
  int currentLevelXpStartForBar = 0;
  int xpToCompleteLevelForBar = 200;
  int currentXpOnBarStartVisual = 0;
  int levelBeforeThisWorkoutVisual = 1;
  bool levelUpOccurred = false;

  // Функція для розрахунку рівня на основі загального XP
  int _calculateLevelFromXp(int totalXp) {
    if (totalXp < 0) return 1;
    int level = 1;
    int xpForNextLevelUp = xpPerLevelBase; // XP для переходу з 1 на 2
    int cumulativeXpForLevelStart = 0;

    while (totalXp >= cumulativeXpForLevelStart + xpForNextLevelUp) {
      cumulativeXpForLevelStart += xpForNextLevelUp;
      level++;
      xpForNextLevelUp = xpPerLevelBase + (level - 1) * 50; // XP для наступного *нового* рівня
    }
    return level;
  }

  // Функція для розрахунку загального XP, необхідного для досягнення початку *даного* рівня
  int _calculateTotalXpForLevelStart(int targetLevel) {
    if (targetLevel <= 1) return 0;
    int totalXp = 0;
    for (int i = 1; i < targetLevel; i++) { // Рахуємо XP для всіх *попередніх* рівнів
      totalXp += (xpPerLevelBase + (i - 1) * 50);
    }
    return totalXp;
  }


  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    final profileAfterWorkout = widget.userProfileAtCompletion;
    final xpGainedThisWorkout = widget.xpGained;

    // 1. Визначаємо XP та рівень *до* цього тренування
    final totalXpBeforeThisWorkout = profileAfterWorkout.xp - xpGainedThisWorkout;
    levelBeforeThisWorkoutVisual = _calculateLevelFromXp(totalXpBeforeThisWorkout);

    // 2. Визначаємо, чи відбувся левел-ап
    levelUpOccurred = profileAfterWorkout.level > levelBeforeThisWorkoutVisual;
    developer.log(
        "WorkoutComplete Init: XP_Gained: $xpGainedThisWorkout, TotalXP_Before: $totalXpBeforeThisWorkout, Level_Before: $levelBeforeThisWorkoutVisual, ProfileLevel_After: ${profileAfterWorkout.level}. Level Up Occurred: $levelUpOccurred",
        name: "WorkoutCompleteScreen"
    );


    // 3. Розрахунок для XP бару (на основі рівня ДО тренування)
    currentLevelXpStartForBar = _calculateTotalXpForLevelStart(levelBeforeThisWorkoutVisual);
    xpToCompleteLevelForBar = (xpPerLevelBase + (levelBeforeThisWorkoutVisual - 1) * 50);
    if (xpToCompleteLevelForBar <= 0) xpToCompleteLevelForBar = xpPerLevelBase; // Захист

    currentXpOnBarStartVisual = (totalXpBeforeThisWorkout - currentLevelXpStartForBar).clamp(0, xpToCompleteLevelForBar);

    _xpFillController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    double initialFillPercent = (currentXpOnBarStartVisual.toDouble() / xpToCompleteLevelForBar.toDouble()).clamp(0.0, 1.0);
    // Якщо був левел ап, анімація заповнює шкалу старого рівня до 100%.
    // Якщо не було, анімація заповнює до нового поточного значення XP на шкалі старого рівня.
    double finalAnimatedFillPercent = levelUpOccurred
        ? 1.0
        : ((currentXpOnBarStartVisual + xpGainedThisWorkout).toDouble() / xpToCompleteLevelForBar.toDouble()).clamp(0.0, 1.0);

    _xpFillAnimation = Tween<double>(begin: initialFillPercent, end: finalAnimatedFillPercent).animate(
      CurvedAnimation(parent: _xpFillController, curve: Curves.easeOutQuart),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (levelUpOccurred) { // Конфетті тільки при реальному левел-апі
        _confettiController.play();
      }
      _xpFillController.forward();
    });
  }


  @override
  void dispose() {
    _confettiController.dispose();
    _xpFillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationMinutes = widget.completedSession.durationSeconds != null ? (widget.completedSession.durationSeconds! / 60).floor() : 0;
    final volumeFormatted = widget.completedSession.totalVolume?.toStringAsFixed(1) ?? "0";

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 120, height: 120, child: Lottie.asset('assets/animations/trophy_animation.json', repeat: false)),
                  const SizedBox(height: 16),
                  Text(levelUpOccurred ? 'LEVEL UP!' : 'Workout Complete!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: levelUpOccurred ? Colors.amber.shade700 : theme.colorScheme.primary), textAlign: TextAlign.center),
                  if (levelUpOccurred) Text('You reached Level ${widget.userProfileAtCompletion.level}!', style: theme.textTheme.titleLarge?.copyWith(color: Colors.amber.shade600), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  if (widget.completedSession.routineNameSnapshot != null) Text(widget.completedSession.routineNameSnapshot!, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text('Duration: $durationMinutes min', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey.shade700)),
                  Text('Total Volume: $volumeFormatted KG', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey.shade700)),
                  const SizedBox(height: 24),
                  
                  Text('+${widget.xpGained} XP GAINED', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _xpFillAnimation,
                    builder: (context, child) {
                      int displayCurrentLevel = levelBeforeThisWorkoutVisual;
                      int displayNextLevel = levelBeforeThisWorkoutVisual + 1;
                      int displayXpOnBar = (currentXpOnBarStartVisual + (widget.xpGained * _xpFillAnimation.value)).round();
                      int displayTotalXpForLevel = xpToCompleteLevelForBar;

                      if (levelUpOccurred && _xpFillAnimation.isCompleted) {
                        // Після анімації (і левел апу) показуємо дані для нового рівня
                        displayCurrentLevel = widget.userProfileAtCompletion.level;
                        displayNextLevel = widget.userProfileAtCompletion.level + 1;
                        
                        final newLevelStartXp = _calculateTotalXpForLevelStart(displayCurrentLevel);
                        displayTotalXpForLevel = (_calculateTotalXpForLevelStart(displayNextLevel) - newLevelStartXp);
                        if (displayTotalXpForLevel <= 0) displayTotalXpForLevel = xpPerLevelBase;
                        displayXpOnBar = (widget.userProfileAtCompletion.xp - newLevelStartXp).clamp(0, displayTotalXpForLevel);
                      } else {
                         displayXpOnBar = displayXpOnBar.clamp(0, displayTotalXpForLevel);
                      }


                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: LinearProgressIndicator(
                              value: levelUpOccurred && _xpFillAnimation.isCompleted 
                                      ? (displayXpOnBar.toDouble() / displayTotalXpForLevel.toDouble()).clamp(0.0, 1.0)
                                      : _xpFillAnimation.value, 
                              minHeight: 14,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('LVL $displayCurrentLevel', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  '$displayXpOnBar/${displayTotalXpForLevel} XP',
                                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'IBMPlexMono'),
                                ),
                                Text('LVL $displayNextLevel', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () { 
                       Navigator.of(context).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (context) => const AuthGate()),
                         (Route<dynamic> route) => false,
                       );
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    child: const Text('Awesome!'),
                  ),
                ],
              ),
            ),
            if (levelUpOccurred) // Конфетті тільки при реальному левел-апі
              Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, numberOfParticles: 25, gravity: 0.15, emissionFrequency: 0.03, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow])),
          ],
        ),
      ),
    );
  }
}