// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/routines/presentation/screens/user_routines_screen.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'core/domain/repositories/notification_repository.dart';
import 'core/domain/repositories/workout_log_repository.dart'; // <--- НОВИЙ ІМПОРТ
import 'features/workout_tracking/presentation/screens/active_workout_screen.dart'; // <--- НОВИЙ ІМПОРТ
import 'core/domain/entities/workout_session.dart'; // <--- НОВИЙ ІМПОРТ для WorkoutStatus
// TODO: Розглянути можливість створення "WorkoutChooserDialog" для вибору рутини або порожнього тренування

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Posts")), body: const Center(child: Text("Posts Screen Content")));
}
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Progress")), body: const Center(child: Text("Progress Screen Content")));
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Profile")), body: const Center(child: Text("Profile Screen Content")));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // NotificationsCubit надається тут
    return BlocProvider<NotificationsCubit>(
      create: (cubitContext) => NotificationsCubit(
        RepositoryProvider.of<NotificationRepository>(cubitContext),
        fb_auth.FirebaseAuth.instance,
      ),
      // Можливо, варто додати сюди StreamProvider або BlocProvider для активної сесії,
      // щоб FAB міг реагувати на її наявність.
      // Або робити запит до репозиторію при натисканні FAB.
      // Для простоти, поки що будемо робити запит.
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  int _selectedIndex = -1; // -1 для DashboardScreen

  static final List<Widget> _bottomNavScreens = <Widget>[
    const UserRoutinesScreen(), // index 0
    const PostsScreen(),        // index 1
    const ProgressScreen(),     // index 2
    const ProfileScreen(),      // index 3
  ];

  void _onItemTapped(int index) {
    developer.log("BottomNav tapped, index: $index", name: "HomePage");
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToDashboard() {
    developer.log("Navigating to Dashboard", name: "HomePage");
    setState(() {
      _selectedIndex = -1;
    });
  }

  void _navigateToProfile() {
    setState(() => _selectedIndex = 3);
  }

  void _navigateToProgress() {
    setState(() => _selectedIndex = 2);
  }

  // Обробник для FAB
  Future<void> _handleFabPress() async {
    final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a workout.')),
      );
      return;
    }

    final workoutLogRepo = RepositoryProvider.of<WorkoutLogRepository>(context);
    
    // Перевіряємо, чи є активна сесія через стрім (або одноразовий запит)
    // Для простоти FAB, використаємо одноразовий запит через getActiveWorkoutSessionStream().first
    // В ідеалі, HomePage мав би слухати цей стрім постійно, щоб оновлювати вигляд FAB.
    WorkoutSession? activeSession;
    try {
      activeSession = await workoutLogRepo.getActiveWorkoutSessionStream(userId).first;
    } catch (e) {
      developer.log("Error checking active session for FAB: $e", name: "HomePage");
    }
    
    if (mounted) { // Перевірка, чи віджет ще в дереві
      if (activeSession != null && activeSession.status == WorkoutStatus.inProgress) {
        developer.log("Resuming active workout: ${activeSession.id}", name: "HomePage.FAB");
        Navigator.of(context).push(ActiveWorkoutScreen.route()); // Відкриваємо екран, Cubit підхопить активну сесію
      } else {
        developer.log("No active workout, showing options to start new.", name: "HomePage.FAB");
        // TODO: Показати діалог вибору: Start from Routine / Start Empty Workout
        // Поки що просто перехід на порожній ActiveWorkoutScreen
        // (або краще на UserRoutinesScreen, щоб користувач вибрав рутину)

        // Приклад простого діалогу:
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Start New Workout'),
            content: const Text('How would you like to start?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  setState(() { _selectedIndex = 0; }); // Перехід на екран Рутин
                },
                child: const Text('From Routine'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  Navigator.of(context).push(ActiveWorkoutScreen.route()); // Порожнє тренування
                },
                child: const Text('Empty Workout'),
              ),
            ],
          ),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Start Workout FAB Tapped! (Logic to be implemented: choose routine or empty)')),
        // );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    developer.log("HomePageContent building, _selectedIndex: $_selectedIndex", name: "HomePage");
    Widget currentBody;
    bool showFab = false;

    if (_selectedIndex == -1) { // Dashboard
      currentBody = DashboardScreen(
        onProfileTap: _navigateToProfile,
        onProgressTap: _navigateToProgress,
      );
      showFab = true;
    } else {
      currentBody = _bottomNavScreens[_selectedIndex];
      if (_selectedIndex == 0) { // Routines screen also has FAB
         showFab = false; // UserRoutinesScreen тепер має свій FAB
      }
    }

    Widget appBarTitleWidget = GestureDetector(
      onTap: _navigateToDashboard,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).appBarTheme.titleTextStyle,
          children: const <TextSpan>[
            TextSpan(text: 'Muscle', style: TextStyle(color: Color(0xFFED5D1A))),
            TextSpan(text: 'UP'),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: appBarTitleWidget,
        centerTitle: true,
      ),
      body: currentBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab // Показуємо FAB тільки на дашборді
          ? Container(
              margin: const EdgeInsets.only(bottom: 12.0), // Збільшено відступ
              child: FloatingActionButton.extended(
                onPressed: _handleFabPress, // <--- НОВИЙ ОБРОБНИК
                label: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900, // Black
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.fitness_center, color: Colors.white),
                backgroundColor: const Color(0xFFED5D1A),
                // shape: const StadiumBorder(), // Можна замінити на RoundedRectangleBorder
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                elevation: 6.0,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'ROUTINES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined), // Раніше було posts, можливо, це буде ExerciseExplorer
            activeIcon: Icon(Icons.search),
            label: 'EXPLORE', // Змінив на Explore
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'PROGRESS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
        currentIndex: (_selectedIndex >= 0 && _selectedIndex < _bottomNavScreens.length) ? _selectedIndex : 0,
        onTap: _onItemTapped,
      ),
    );
  }
}