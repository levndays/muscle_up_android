// lib/features/notifications/presentation/widgets/notification_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';

class NotificationListItem extends StatelessWidget {
  final AppNotification notification;

  const NotificationListItem({super.key, required this.notification});

  IconData _getIconForNotificationType(NotificationType type, String? customIconName) {
    if (customIconName != null) {
      final iconMap = {
        'emoji_events': Icons.emoji_events_outlined,
        'fitness_center': Icons.fitness_center_outlined,
        'notifications': Icons.notifications_active_outlined,
        'reminder': Icons.alarm_on_outlined,
        'info_outline': Icons.info_outline,
      };
      return iconMap[customIconName.toLowerCase()] ?? Icons.notifications_active_outlined;
    }

    switch (type) {
      case NotificationType.achievementUnlocked:
        return Icons.emoji_events_outlined;
      case NotificationType.workoutReminder:
        return Icons.alarm_on_outlined;
      case NotificationType.newFollower:
        return Icons.person_add_alt_1_outlined;
      case NotificationType.routineShared:
        return Icons.share_outlined;
      case NotificationType.systemMessage:
        return Icons.info_outline;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = DateFormat.MMMd().add_jm().format(notification.timestamp.toDate()); // Ця змінна тепер буде використовуватися
    final bool isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        developer.log('Dismissed notification ${notification.id} in direction: $direction', name: 'NotificationListItem');
        context.read<NotificationsCubit>().deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.title} removed.'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // TODO: Реалізувати логіку скасування видалення, якщо потрібно
                developer.log('UNDO pressed for ${notification.id} - not implemented', name: 'NotificationListItem');
              },
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red.shade700,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.delete_forever, color: Colors.white),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade700,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete_forever, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        elevation: isUnread ? 2.5 : 1.0,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isUnread
              ? BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).round()), width: 1.0)
              : BorderSide.none,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isUnread
                ? Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).round())
                : Colors.grey.shade200,
            child: Icon(
              _getIconForNotificationType(notification.type, notification.iconName),
              color: isUnread ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              color: isUnread ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            notification.message,
            style: TextStyle(
              color: isUnread ? Theme.of(context).colorScheme.onSurface.withAlpha((0.8 * 255).round()) : Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // ВИПРАВЛЕНО: Відновлено код для trailing
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo, // Використовуємо змінну
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUnread ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                      fontSize: 11,
                    ),
              ),
              if (isUnread)
                const SizedBox(height: 4),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            if (isUnread) {
              context.read<NotificationsCubit>().markNotificationAsRead(notification.id);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tapped on: ${notification.title} (ID: ${notification.id})'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}