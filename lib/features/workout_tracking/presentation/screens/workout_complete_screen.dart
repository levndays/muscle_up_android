// lib/features/workout_tracking/presentation/screens/workout_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../auth_gate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // Не потрібен, якщо UserProfile передається
// import '../../../profile/presentation/cubit/user_profile_cubit.dart';

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
  int currentLevelXpStart = 0;
  int xpToNextLevelTotal = 200; // Загальна кількість XP для наступного рівня
  int currentXpOnBarStart = 0; // XP на шкалі ДО цього тренування (відносно початку рівня)
  int currentLevel = 1;
  bool levelUp = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3)); // Коротша анімація конфетті
    
    final profile = widget.userProfileAtCompletion;
    currentLevel = profile.level;
    // XP, який був *до* цього тренування відносно початку всіх рівнів
    final totalXpBeforeThisWorkout = profile.xp - widget.xpGained; 
    
    currentLevelXpStart = _calculateTotalXpForLevelStart(currentLevel);
    final nextLevelXpTarget = _calculateTotalXpForLevelStart(currentLevel + 1);
    xpToNextLevelTotal = nextLevelXpTarget - currentLevelXpStart;
    if (xpToNextLevelTotal <= 0) xpToNextLevelTotal = xpPerLevelBase; // Захист

    currentXpOnBarStart = (totalXpBeforeThisWorkout - currentLevelXpStart).clamp(0, xpToNextLevelTotal);
      
    if (profile.xp >= nextLevelXpTarget) {
      levelUp = true;
    }

    _xpFillController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    double initialFillPercent = (currentXpOnBarStart / xpToNextLevelTotal).clamp(0.0, 1.0);
    // Кінцевий відсоток заповнення відносно поточного рівня (може бути > 1.0, якщо левел ап)
    double finalRawFillPercent = ((currentXpOnBarStart + widget.xpGained) / xpToNextLevelTotal);
    // Обмежуємо анімацію до 1.0, якщо немає левел апу, або якщо левел ап, але показуємо тільки заповнення поточного
    double finalAnimatedFillPercent = levelUp ? 1.0 : finalRawFillPercent.clamp(0.0, 1.0);


    _xpFillAnimation = Tween<double>(begin: initialFillPercent, end: finalAnimatedFillPercent).animate(
      CurvedAnimation(parent: _xpFillController, curve: Curves.easeOutQuart), // Плавніша крива
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _xpFillController.forward();
    });
  }

  int _calculateTotalXpForLevelStart(int level) {
    if (level <= 1) return 0;
    int totalXpForLevel = 0;
    for (int i = 1; i < level; i++) {
      totalXpForLevel += (xpPerLevelBase + (i - 1) * 50);
    }
    return totalXpForLevel;
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

    // XP, яке буде відображатися під шкалою (поточне анімоване значення)
    // int displayedXpOnBar = (currentXpOnBarStart + (widget.xpGained * _xpFillAnimation.value)).round().clamp(0, xpToNextLevelTotal);
    // Якщо левел ап, то після заповнення шкали можемо показати XP для нового рівня
    // Для простоти, поки що показуємо прогрес на поточній шкалі.

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
                  Text(levelUp ? 'LEVEL UP!' : 'Workout Complete!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: levelUp ? Colors.amber.shade700 : theme.colorScheme.primary), textAlign: TextAlign.center),
                  if (levelUp) Text('You reached Level ${widget.userProfileAtCompletion.level}!', style: theme.textTheme.titleLarge?.copyWith(color: Colors.amber.shade600), textAlign: TextAlign.center),
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
                      // Розрахунок поточного відображуваного XP на шкалі
                      int animatedXpOnBar = (currentXpOnBarStart + (widget.xpGained * (_xpFillAnimation.value - _xpFillAnimation.drive(Tween(begin:0.0, end:0.0)).value ))).round();
                      // Якщо початкове значення було 0, анімація починається з 0.
                      // Якщо початкове було >0, то анімація додає до нього.
                      // Потрібно, щоб початкова точка анімації була xp ДО тренування, а кінцева - xp ПІСЛЯ.
                      
                      double currentAnimatedAbsoluteXp = (currentXpOnBarStart + (widget.xpGained * _xpFillAnimation.value)).toDouble();
                      if (levelUp && _xpFillAnimation.value == 1.0) { // Якщо левел ап і анімація завершена
                         currentAnimatedAbsoluteXp = (widget.userProfileAtCompletion.xp - _calculateTotalXpForLevelStart(widget.userProfileAtCompletion.level)).toDouble();
                         xpToNextLevelTotal = _calculateTotalXpForLevelStart(widget.userProfileAtCompletion.level + 1) - _calculateTotalXpForLevelStart(widget.userProfileAtCompletion.level);
                      }


                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: LinearProgressIndicator(
                              value: _xpFillAnimation.value, 
                              minHeight: 14, // Трохи товстіша
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
                                Text('LVL ${levelUp ? widget.userProfileAtCompletion.level -1 : currentLevel}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  '${currentAnimatedAbsoluteXp.round()}/${xpToNextLevelTotal} XP',
                                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'IBMPlexMono'),
                                ),
                                Text('LVL ${levelUp ? widget.userProfileAtCompletion.level : currentLevel + 1}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AuthGate()), (Route<dynamic> route) => false); },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    child: const Text('Awesome!'),
                  ),
                ],
              ),
            ),
            Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, numberOfParticles: 25, gravity: 0.15, emissionFrequency: 0.03, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow])),
          ],
        ),
      ),
    );
  }
}