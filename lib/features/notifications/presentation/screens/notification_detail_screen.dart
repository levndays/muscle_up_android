// lib/features/notifications/presentation/screens/notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_up/core/domain/entities/app_notification.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  IconData _getIconForNotificationType(NotificationType type, String? customIconName) {
    // Ця логіка дублює ту, що в NotificationListItem,
    // в ідеалі її можна винести в helper або розширення для AppNotification.
    // Поки що залишимо тут для простоти.
    if (customIconName != null) {
      final iconMap = {
        'emoji_events': Icons.emoji_events, // Використовуємо заповнені іконки для більшої виразності
        'fitness_center': Icons.fitness_center,
        'notifications': Icons.notifications_active,
        'reminder': Icons.alarm_on,
        'info_outline': Icons.info,
      };
      return iconMap[customIconName.toLowerCase()] ?? Icons.notifications_active;
    }

    switch (type) {
      case NotificationType.achievementUnlocked:
        return Icons.emoji_events;
      case NotificationType.workoutReminder:
        return Icons.alarm_on;
      case NotificationType.newFollower:
        return Icons.person_add_alt_1;
      case NotificationType.routineShared:
        return Icons.share;
      case NotificationType.systemMessage:
        return Icons.info;
      default:
        return Icons.notifications_active;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    // Більш детальне форматування для екрану деталей
    return DateFormat('EEEE, MMMM d, yyyy HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(notification.title),
        backgroundColor: Theme.of(context).cardColor, // Або інший колір
        elevation: 1, // Невелика тінь
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(
                        _getIconForNotificationType(notification.type, notification.iconName),
                        size: 32,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatTimestamp(notification.timestamp.toDate()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                const Divider(height: 32, thickness: 0.8),
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5, // Міжрядковий інтервал
                        color: onSurfaceColor.withOpacity(0.85),
                      ),
                ),
                const SizedBox(height: 24),
                if (notification.relatedEntityId != null || notification.relatedEntityType != null) ...[
                  const Divider(height: 24, thickness: 0.8),
                  Text(
                    'Related Information:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (notification.relatedEntityType != null)
                    _buildInfoRow(context, 'Type:', notification.relatedEntityType!),
                  if (notification.relatedEntityId != null)
                    _buildInfoRow(context, 'ID:', notification.relatedEntityId!),
                  const SizedBox(height: 10),
                  // TODO: В майбутньому тут може бути кнопка для переходу до пов'язаної сутності
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Логіка навігації до relatedEntity
                  //   },
                  //   child: Text('View ${notification.relatedEntityType ?? 'Details'}'),
                  // )
                ],
                // Якщо сповіщення вже прочитане, можна показати невеликий індикатор
                if (notification.isRead) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Read',
                        style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}