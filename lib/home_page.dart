// lib/home_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Імпорти екранів для вкладок
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart';
import 'features/routines/presentation/screens/user_routines_screen.dart';
// (Можливо) екран профілю
// import 'features/profile/presentation/screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Список віджетів (екранів) для кожної вкладки
  // Важливо: ці екрани повинні коректно отримувати свої залежності (кубіти/репозиторії)
  // через BlocProvider/RepositoryProvider з контексту, якщо вони їх створюють.
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const ExerciseExplorerScreen(), // Цей екран вже має свій BlocProvider
    const UserRoutinesScreen(),     // Цей екран вже має свій BlocProvider
    // const ProfileScreen(), // Додати, коли буде готовий
  ];

  // Список заголовків для AppBar
  static const List<String> _appBarTitles = <String>[
    'Dashboard',
    'Exercise Library',
    'My Routines',
    // 'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // AuthGate автоматично обробить перенаправлення
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: IndexedStack( // Використовуємо IndexedStack для збереження стану екранів
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Routines',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person_outline),
          //   activeIcon: Icon(Icons.person),
          //   label: 'Profile',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}