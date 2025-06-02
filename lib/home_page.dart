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
import 'core/domain/repositories/routine_repository.dart'; // For FAB logic
import 'core/domain/entities/routine.dart'; // For FAB logic
import 'features/routines/presentation/screens/create_edit_routine_screen.dart'; // For FAB logic
import 'features/workout_tracking/presentation/screens/active_workout_screen.dart';
import 'core/domain/entities/workout_session.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart';
import 'features/progress/presentation/screens/progress_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provides NotificationsCubit to the entire HomePage widget tree
    return BlocProvider<NotificationsCubit>(
      create: (cubitContext) => NotificationsCubit(
        RepositoryProvider.of<NotificationRepository>(cubitContext),
        fb_auth.FirebaseAuth.instance,
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
  int _selectedIndex = -1; // -1 indicates the Dashboard (main tab, not in BottomNav)

  static final List<Widget> _bottomNavScreens = <Widget>[
    const UserRoutinesScreen(),
    const ExerciseExplorerScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  static final List<String> _bottomNavScreenTitles = <String>[
    'My Routines',
    'Explore Exercises',
    'My Progress',
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
      _selectedIndex = -1; // Special index for the dashboard
    });
  }

  void _navigateToProfileFromDashboard() {
    developer.log("Dashboard request: Navigating to Profile", name: "HomePage");
    setState(() {
      _selectedIndex = 3; // Index for the "Profile" tab
    });
  }

  void _navigateToProgressFromDashboard() {
    developer.log("Dashboard request: Navigating to Progress", name: "HomePage");
    setState(() {
      _selectedIndex = 2; // Index for the "Progress" tab
    });
  }

  Future<void> _handleFabPress() async {
    final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to start a workout.')),
        );
      }
      return;
    }

    final workoutLogRepo = RepositoryProvider.of<WorkoutLogRepository>(context);
    WorkoutSession? activeSession;

    try {
      activeSession = await workoutLogRepo.getActiveWorkoutSessionStream(userId).first;
    } catch (e) {
      developer.log("Error checking active session for FAB: $e", name: "HomePage.FAB");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking active session: ${e.toString()}')),
        );
      }
      return;
    }

    if (!mounted) return;

    if (activeSession != null && activeSession.status == WorkoutStatus.inProgress) {
      developer.log("Resuming active workout: ${activeSession.id}", name: "HomePage.FAB");
      Navigator.of(context).push(ActiveWorkoutScreen.route());
    } else {
      // No active session, check for existing routines
      developer.log("No active workout. Checking for existing routines.", name: "HomePage.FAB");
      final routineRepository = RepositoryProvider.of<RoutineRepository>(context);
      List<UserRoutine> userRoutines = [];

      try {
        userRoutines = await routineRepository.getUserRoutines(userId);
      } catch (e) {
        developer.log("Error fetching routines for FAB: $e", name: "HomePage.FAB");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not load routines. Please try again. Error: ${e.toString()}')),
          );
        }
        return;
      }

      if (!mounted) return;

      if (userRoutines.isNotEmpty) {
        // Routines exist, navigate to UserRoutinesScreen tab
        developer.log("Routines exist (${userRoutines.length}). Navigating to UserRoutinesScreen tab.", name: "HomePage.FAB");
        setState(() {
          _selectedIndex = 0; // 0 is the index for the "ROUTINES" tab
        });
      } else {
        // No routines, navigate to CreateEditRoutineScreen
        developer.log("No routines. Navigating to CreateEditRoutineScreen.", name: "HomePage.FAB");
        final routineWasCreated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const CreateEditRoutineScreen(),
          ),
        );

        if (routineWasCreated == true && mounted) {
          // If a routine was created, navigate to the routines tab
          developer.log("Routine was created. Navigating to UserRoutinesScreen tab.", name: "HomePage.FAB");
          setState(() {
            _selectedIndex = 0; // 0 is the index for the "ROUTINES" tab
          });
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New routine created! Select it from the list to start.')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    developer.log("HomePageContent building, _selectedIndex: $_selectedIndex", name: "HomePage");
    
    Widget currentBody;
    bool showFab = false;
    Widget appBarTitle; 

    final TextStyle? baseMuscleUpStyle = Theme.of(context).appBarTheme.titleTextStyle;
    final Color muscleUpOrangeColor = Theme.of(context).colorScheme.primary; 
    final Color defaultAppBarTextColor = Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.black87;


    if (_selectedIndex == -1) { // Dashboard
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
    } else if (_selectedIndex >= 0 && _selectedIndex < _bottomNavScreens.length) {
      currentBody = _bottomNavScreens[_selectedIndex];
      showFab = false; 
      
      final screenTitleText = _bottomNavScreenTitles[_selectedIndex];
      
      appBarTitle = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _navigateToDashboard,
            child: RichText(
              text: TextSpan(
                style: baseMuscleUpStyle?.copyWith(fontSize: 20), 
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
              fontSize: 18, 
              fontWeight: baseMuscleUpStyle.fontWeight, 
              color: defaultAppBarTextColor, 
            ),
          ),
        ],
      );
    } else {
      // Fallback case, should ideally not happen
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
        centerTitle: true,
      ),
      body: currentBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab 
          ? Container(
             margin: const EdgeInsets.only(bottom: 12.0),
              child: FloatingActionButton.extended(
                onPressed: _handleFabPress,
                label: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.fitness_center, color: Colors.white),
                backgroundColor: Theme.of(context).colorScheme.primary,
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
            icon: Icon(Icons.explore_outlined), 
            activeIcon: Icon(Icons.explore),
            label: 'EXPLORE',
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