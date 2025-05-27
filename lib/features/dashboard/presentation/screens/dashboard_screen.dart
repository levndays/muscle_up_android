// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// TODO: Імпортувати UserRoutinesCubit/State та RoutineRepository, якщо будете показувати тут рутини
// import '../../../routines/presentation/cubit/user_routines_cubit.dart';
// import '../../../../core/domain/repositories/routine_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // TODO: Для відображення рутин тут, можна було б створити окремий BlocProvider
    // або використовувати BlocBuilder для UserRoutinesCubit, якщо він надається вище (наприклад, у HomePage)
    // Однак, для простоти, поки що не будемо завантажувати рутини прямо тут,
    // а лише покажемо базову інформацію.

    return Scaffold(
      // AppBar тут не потрібен, бо він буде на HomePage
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (user != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.displayName ?? user.email ?? 'Fitness Enthusiast',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Today's Focus",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              // Тут можна відобразити заплановану рутину на сьогодні, якщо є
              // Або якусь мотиваційну цитату
              Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 30, color: Color(0xFFED5D1A)),
                      SizedBox(height: 8),
                      Text(
                        "No workout scheduled for today (yet!).\nCheck your routines or start a new one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Quick Actions",
                style: Theme.of(context).textTheme.titleLarge,
              ),
               const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Routine'),
                onPressed: () {
                  // Для навігації на екран створення рутин, потрібно щоб HomePage мала спосіб
                  // змінити вкладку та/або запустити навігацію.
                  // Поки що, це може бути просто кнопка-заглушка, або ми можемо
                  // використати `Navigator.push` напряму до `CreateEditRoutineScreen`.
                  // Для цього `CreateEditRoutineScreen` має бути доступним
                  // (і мати доступ до `RoutineRepository` через `RepositoryProvider`).
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Navigate to Create Routine from Routines Tab for now.'))
                   );
                },
              ),
              const SizedBox(height: 12),
               ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Start Empty Workout (Soon)'),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Feature coming soon!'))
                   );
                },
              ),


            ] else ...[
              const Center(child: Text('User information unavailable. Please try logging in again.')),
            ],
            const SizedBox(height: 30),
            Text(
              'Version: 0.1.0', // Як у pubspec.yaml
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}