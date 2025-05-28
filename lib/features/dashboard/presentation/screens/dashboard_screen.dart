// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onProgressTap;

  const DashboardScreen({
    super.key,
    required this.onProfileTap,
    required this.onProgressTap,
  });

  static const Color primaryOrange = Color(0xFFED5D1A);
  static const Color textBlack = Colors.black87;
  static const String ibmPlexMonoFont = 'IBMPlexMono'; // Константа для назви шрифту

  Widget _buildStatsItem(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textBlack,
                fontFamily: ibmPlexMonoFont, // <--- ЗМІНА ШРИФТУ
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Icon(Icons.notifications_active_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text('Notification Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('This is a placeholder for notification content #${index + 1}. Tap to see details.'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on Notification ${index + 1}')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'User';
    
    final int unreadNotificationsCount = 3;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (user != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onProfileTap,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome,',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: textBlack,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onProgressTap,
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: primaryOrange, size: 32),
                        const SizedBox(width: 6),
                        Text(
                          '3', 
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            Text(
              'STATS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textBlack,
                    fontFamily: ibmPlexMonoFont, // <--- ЗМІНА ШРИФТУ
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'TOTAL VOLUME OVER LAST 7 DAYS GRAPH PLACEHOLDER',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textBlack, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatsItem(context, '78 KG', 'WEIGHT'),
                _buildStatsItem(context, '3 DAY', 'STREAK'),
                _buildStatsItem(context, '100%', 'ADHERENCE'),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'NOTIFICATIONS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textBlack,
                        fontFamily: ibmPlexMonoFont, // <--- ЗМІНА ШРИФТУ
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                if (unreadNotificationsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: const BoxDecoration(
                      color: primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: 10, 
              itemBuilder: (context, index) {
                return _buildNotificationItem(context, index);
              },
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }
}