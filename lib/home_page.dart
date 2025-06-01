// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/routines/presentation/screens/user_routines_screen.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'core/domain/repositories/notification_repository.dart';
import 'core/domain/repositories/workout_log_repository.dart';
import 'features/workout_tracking/presentation/screens/active_workout_screen.dart';
import 'core/domain/entities/workout_session.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart';
import 'features/progress/presentation/screens/progress_screen.dart'; // <--- ДОДАНО ІМПОРТ НОВОГО ЕКРАНУ

// Старий плейсхолдер можна видалити або залишити закоментованим для історії
// class ProgressScreenPlaceholder extends StatelessWidget {
//   const ProgressScreenPlaceholder({super.key});
//   @override
//   Widget build(BuildContext context) => const Scaffold( 
//       body: Center(child: Text("Progress Screen Content Placeholder")),
//     );
// }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Надаємо NotificationsCubit для всього дерева віджетів HomePage
    return BlocProvider<NotificationsCubit>(
      create: (cubitContext) => NotificationsCubit(
        RepositoryProvider.of<NotificationRepository>(cubitContext),
        fb_auth.FirebaseAuth.instance, // Передаємо екземпляр FirebaseAuth
      ),
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
  int _selectedIndex = -1; // -1 означає Dashboard (головна вкладка, не в BottomNav)

  // Список віджетів для BottomNavigationBar
  static final List<Widget> _bottomNavScreens = <Widget>[
    const UserRoutinesScreen(),
    const ExerciseExplorerScreen(),
    const ProgressScreen(), // <--- ЗАМІНЕНО ПЛЕЙСХОЛДЕР НА НОВИЙ ЕКРАН
    const ProfileScreen(),
  ];

  // Відповідні заголовки для AppBar
  static final List<String> _bottomNavScreenTitles = <String>[
    'My Routines',
    'Explore Exercises',
    'My Progress', // Оновлено заголовок
    'Profile',
  ];

  void _onItemTapped(int index) {
    developer.log("BottomNav tapped, index: $index", name: "HomePage");
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToDashboard() {
    developer.log("Navigating to Dashboard (AppBar tap)", name: "HomePage");
    setState(() {
      _selectedIndex = -1; // Спеціальний індекс для дашборду
    });
  }

  // Колбеки для навігації з DashboardScreen
  void _navigateToProfileFromDashboard() {
    developer.log("Dashboard request: Navigating to Profile", name: "HomePage");
    setState(() {
      _selectedIndex = 3; // Індекс для вкладки "Profile"
    });
  }

  void _navigateToProgressFromDashboard() {
    developer.log("Dashboard request: Navigating to Progress", name: "HomePage");
    setState(() {
      _selectedIndex = 2; // Індекс для вкладки "Progress"
    });
  }

  // Обробник натискання на FloatingActionButton
  Future<void> _handleFabPress() async {
    final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Користувач не увійшов, показуємо повідомлення
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a workout.')),
      );
      return;
    }

    final workoutLogRepo = RepositoryProvider.of<WorkoutLogRepository>(context);
    WorkoutSession? activeSession;
    try {
      // Отримуємо ОДИН раз, а не підписуємось, щоб уникнути проблем з mounted
      activeSession = await workoutLogRepo.getActiveWorkoutSessionStream(userId).first;
    } catch (e) {
      developer.log("Error checking active session for FAB: $e", name: "HomePage");
      // Можна показати помилку користувачеві, якщо потрібно
    }

    if (!mounted) return; // Перевірка mounted перед навігацією

    if (activeSession != null && activeSession.status == WorkoutStatus.inProgress) {
      // Якщо є активна сесія, переходимо до неї
      developer.log("Resuming active workout: ${activeSession.id}", name: "HomePage.FAB");
      Navigator.of(context).push(ActiveWorkoutScreen.route());
    } else {
      // Якщо активної сесії немає, показуємо діалог вибору
      developer.log("No active workout, showing options to start new.", name: "HomePage.FAB");
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Start New Workout'),
          content: const Text('How would you like to start?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                // Переключаємося на вкладку Рутин
                setState(() { _selectedIndex = 0; }); 
              },
              child: const Text('From Routine'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).push(ActiveWorkoutScreen.route()); // Запускаємо порожнє тренування
              },
              child: const Text('Empty Workout'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log("HomePageContent building, _selectedIndex: $_selectedIndex", name: "HomePage");
    
    Widget currentBody;
    bool showFab = false;
    Widget appBarTitle; 

    final TextStyle? baseMuscleUpStyle = Theme.of(context).appBarTheme.titleTextStyle;
    // Припускаємо, що primaryOrange визначено в темі, або використовуємо константу
    final Color muscleUpOrangeColor = Theme.of(context).colorScheme.primary; 
    final Color defaultAppBarTextColor = Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.black87;


    if (_selectedIndex == -1) { // Dashboard
      currentBody = DashboardScreen(
        onProfileTap: _navigateToProfileFromDashboard,
        onProgressTap: _navigateToProgressFromDashboard,
      );
      showFab = true;
      appBarTitle = GestureDetector(
        onTap: _navigateToDashboard, // Клік на "MuscleUP" веде на дашборд
        child: RichText(
          text: TextSpan(
            style: baseMuscleUpStyle, // Базовий стиль з теми AppBar
            children: <TextSpan>[
              TextSpan(text: 'Muscle', style: TextStyle(color: muscleUpOrangeColor)),
              const TextSpan(text: 'UP'), // 'UP' матиме колір з baseMuscleUpStyle
            ],
          ),
        ),
      );
    } else if (_selectedIndex >= 0 && _selectedIndex < _bottomNavScreens.length) {
      currentBody = _bottomNavScreens[_selectedIndex];
      showFab = false; // Не показуємо FAB на інших вкладках
      
      final screenTitleText = _bottomNavScreenTitles[_selectedIndex];
      
      // AppBar для інших вкладок: "MuscleUP | Назва Вкладки"
      appBarTitle = Row(
        mainAxisSize: MainAxisSize.min, // Щоб Row не розтягувався на всю ширину
        children: [
          GestureDetector(
            onTap: _navigateToDashboard, // Навігація на дашборд при кліку на MuscleUP
            child: RichText(
              text: TextSpan(
                style: baseMuscleUpStyle?.copyWith(fontSize: 20), // Трохи менший шрифт для лого
                children: <TextSpan>[
                  TextSpan(text: 'Muscle', style: TextStyle(color: muscleUpOrangeColor)),
                  const TextSpan(text: 'UP'),
                ],
              ),
            ),
          ),
          Text(
            '  |  $screenTitleText',
            style: baseMuscleUpStyle?.copyWith(
              fontSize: 18, // Трохи менший шрифт для назви вкладки
              fontWeight: baseMuscleUpStyle.fontWeight, 
              color: defaultAppBarTextColor, 
            ),
          ),
        ],
      );
    } else {
      // Аварійний випадок, якщо _selectedIndex виходить за межі (малоймовірно)
      currentBody = DashboardScreen(
        onProfileTap: _navigateToProfileFromDashboard,
        onProgressTap: _navigateToProgressFromDashboard,
      );
      showFab = true;
      appBarTitle = GestureDetector(
        onTap: _navigateToDashboard,
        child: RichText(
          text: TextSpan(
            style: baseMuscleUpStyle,
            children: <TextSpan>[
              TextSpan(text: 'Muscle', style: TextStyle(color: muscleUpOrangeColor)),
              const TextSpan(text: 'UP'),
            ],
          ),
        ),
      );
      developer.log("HomePageContent: _selectedIndex out of bounds, defaulting to Dashboard", name: "HomePage", level: 1000);
    }

    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        centerTitle: true, // Центрує title, якщо він єдиний елемент або flexibleSpace не використовується
      ),
      body: currentBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab 
          ? Container( // Додаємо відступ знизу для FAB
             margin: const EdgeInsets.only(bottom: 12.0), // Можна налаштувати відступ
              child: FloatingActionButton.extended(
                onPressed: _handleFabPress, // Оновлено
                label: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900, // Black
                    color: Colors.white, // Колір тексту кнопки FAB
                  ),
                ),
                icon: const Icon(Icons.fitness_center, color: Colors.white), // Колір іконки FAB
                backgroundColor: Theme.of(context).colorScheme.primary, // Використовуємо колір з теми
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                elevation: 6.0,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
         items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center), // Активна іконка
            label: 'ROUTINES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined), 
            activeIcon: Icon(Icons.explore), // Активна іконка
            label: 'EXPLORE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events), // Активна іконка
            label: 'PROGRESS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person), // Активна іконка
            label: 'PROFILE',
          ),
        ],
        currentIndex: (_selectedIndex >= 0 && _selectedIndex < _bottomNavScreens.length) ? _selectedIndex : 0, // Захист від виходу за межі
        onTap: _onItemTapped,
        // Властивості з теми вже мають бути застосовані, але для певності:
        // type: BottomNavigationBarType.fixed,
        // showUnselectedLabels: true, 
      ),
    );
  }
}