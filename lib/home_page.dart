// lib/home_page.dart
import 'package:flutter/material.dart'; 

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/routines/presentation/screens/user_routines_screen.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1; 

  static final List<Widget> _bottomNavScreens = <Widget>[
    const UserRoutinesScreen(), // 0
    const PostsScreen(),        // 1
    const ProgressScreen(),     // 2
    const ProfileScreen(),      // 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToDashboard() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  // --- НОВІ КОЛБЕКИ ---
  void _navigateToProfile() {
    setState(() {
      _selectedIndex = 3; // Індекс вкладки "PROFILE"
    });
  }

  void _navigateToProgress() {
    setState(() {
      _selectedIndex = 2; // Індекс вкладки "PROGRESS"
    });
  }
  // --- КІНЕЦЬ НОВИХ КОЛБЕКІВ ---


  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    bool showFab = false;

    if (_selectedIndex == -1) {
      // --- ПЕРЕДАЄМО КОЛБЕКИ В DASHBOARDSCREEN ---
      currentBody = DashboardScreen(
        onProfileTap: _navigateToProfile,
        onProgressTap: _navigateToProgress,
      );
      // --- КІНЕЦЬ ПЕРЕДАЧІ КОЛБЕКІВ ---
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