// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/routines/presentation/screens/user_routines_screen.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
// НЕ ПОТРІБЕН: import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'core/domain/repositories/notification_repository.dart';

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
  int _selectedIndex = -1;

  static final List<Widget> _bottomNavScreens = <Widget>[
    const UserRoutinesScreen(),
    const PostsScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
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
    developer.log("Navigating to Profile tab", name: "HomePage");
    setState(() {
      _selectedIndex = 3;
    });
  }

  void _navigateToProgress() {
    developer.log("Navigating to Progress tab", name: "HomePage");
    setState(() {
      _selectedIndex = 2;
    });
  }

  // ВИДАЛЕНО: void _navigateToNotifications() { ... }

  @override
  Widget build(BuildContext context) {
    developer.log("HomePageContent building, _selectedIndex: $_selectedIndex", name: "HomePage");
    Widget currentBody;
    bool showFab = false;

    if (_selectedIndex == -1) {
      currentBody = DashboardScreen(
        onProfileTap: _navigateToProfile,
        onProgressTap: _navigateToProgress,
        // ВИДАЛЕНО: onNotificationsTap: _navigateToNotifications,
      );
      showFab = true;
    } else {
      currentBody = _bottomNavScreens[_selectedIndex];
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
        actions: const [ // Прибираємо іконку сповіщень звідси, бо лічильник тепер на дашборді
          // Можна залишити, якщо хочете якусь іншу глобальну дію
          // SizedBox(width: 8),
        ],
      ),
      body: currentBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab
          ? Container(
              margin: const EdgeInsets.only(bottom: 3.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Start Workout FAB Tapped! (Logic to be implemented)')),
                  );
                },
                label: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.fitness_center, color: Colors.white),
                backgroundColor: const Color(0xFFED5D1A),
                shape: const StadiumBorder(),
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
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'POSTS',
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