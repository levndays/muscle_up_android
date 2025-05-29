// lib/features/workout_tracking/presentation/screens/workout_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math'; 

import '../../../../core/domain/entities/workout_session.dart';
import '../../../../auth_gate.dart'; // <--- ЗМІНЕНО ІМПОРТ

class WorkoutCompleteScreen extends StatefulWidget {
  final WorkoutSession completedSession;
  final int xpGained;

  const WorkoutCompleteScreen({
    super.key,
    required this.completedSession,
    required this.xpGained,
  });

  static Route<void> route(WorkoutSession session, int xp) {
    return MaterialPageRoute<void>(
      builder: (_) => WorkoutCompleteScreen(completedSession: session, xpGained: xp),
      fullscreenDialog: true, 
    );
  }

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationMinutes = widget.completedSession.durationSeconds != null
        ? (widget.completedSession.durationSeconds! / 60).floor()
        : 0;
    final volumeFormatted = widget.completedSession.totalVolume?.toStringAsFixed(1) ?? "0";

    return WillPopScope( // <--- Забороняємо системну кнопку "назад"
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
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 100),
                  const SizedBox(height: 24),
                  Text('Workout Complete!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if (widget.completedSession.routineNameSnapshot != null) Text(widget.completedSession.routineNameSnapshot!, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Duration: $durationMinutes min', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
                  Text('Total Volume: $volumeFormatted KG', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 30), const SizedBox(width: 12), Text('+${widget.xpGained} XP', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber.shade800))])),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const AuthGate()), // <--- НАВІГАЦІЯ ЧЕРЕЗ AuthGate
                            (Route<dynamic> route) => false, 
                      );
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    child: const Text('Awesome!'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive, 
                shouldLoop: false, numberOfParticles: 20, gravity: 0.2, emissionFrequency: 0.05,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ),
          ],
        ),
      ),
    );
  }
}