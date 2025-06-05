// lib/features/notifications/presentation/widgets/notification_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:muscle_up/l10n/app_localizations.dart'; // Import AppLocalizations

import '../../../../core/domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';
import '../screens/notification_detail_screen.dart';

class NotificationListItem extends StatelessWidget {
  final AppNotification notification;

  const NotificationListItem({super.key, required this.notification});

  Widget _getLeadingWidget(BuildContext context, AppNotification notification) {
    final theme = Theme.of(context);
    final bool isUnread = !notification.isRead;
    final Color iconColor = isUnread ? theme.colorScheme.primary : Colors.grey.shade700;
    final Color avatarBgColor = isUnread
        ? theme.colorScheme.primary.withAlpha((0.15 * 255).round())
        : Colors.grey.shade200;

    if (notification.type == NotificationType.achievementUnlocked &&
        notification.iconName != null &&
        (notification.iconName!.endsWith('.png') || notification.iconName!.endsWith('.gif'))) {
      return CircleAvatar(
        backgroundColor: avatarBgColor,
        radius: 20, // Consistent with Icon size
        child: Padding(
          padding: const EdgeInsets.all(4.0), // Small padding for the image
          child: Image.asset(
            notification.iconName!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image asset fails to load
              return Icon(Icons.emoji_events_outlined, color: iconColor, size: 24);
            },
          ),
        ),
      );
    } else if (notification.type == NotificationType.newFollower &&
               notification.senderProfilePicUrl != null &&
               notification.senderProfilePicUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: avatarBgColor, // Or a different color for followers
        backgroundImage: NetworkImage(notification.senderProfilePicUrl!),
        onBackgroundImageError: (_, __) {}, // Handle error if needed
        child: notification.senderProfilePicUrl == null || notification.senderProfilePicUrl!.isEmpty
            ? Icon(Icons.person_add_alt_1_outlined, color: iconColor, size: 24)
            : null,
      );
    }

    // Default icon logic
    IconData iconData;
    if (notification.iconName != null) {
      final iconMap = {
        'emoji_events': Icons.emoji_events_outlined,
        'fitness_center': Icons.fitness_center_outlined,
        'notifications': Icons.notifications_active_outlined,
        'reminder': Icons.alarm_on_outlined,
        'info_outline': Icons.info_outline,
        'person_add_alt_1': Icons.person_add_alt_1_outlined, // For newFollower fallback
        'lightbulb_outline': Icons.lightbulb_outline, // For advice
        'military_tech': Icons.military_tech_outlined, // For record claim voting/verification
        'gavel': Icons.gavel_outlined, // For record claim denied/expired
      };
      iconData = iconMap[notification.iconName!.toLowerCase()] ?? Icons.notifications_active_outlined;
    } else {
      switch (notification.type) {
        case NotificationType.achievementUnlocked:
          iconData = Icons.emoji_events_outlined;
          break;
        case NotificationType.workoutReminder:
          iconData = Icons.alarm_on_outlined;
          break;
        case NotificationType.newFollower:
          iconData = Icons.person_add_alt_1_outlined;
          break;
        case NotificationType.routineShared:
          iconData = Icons.share_outlined;
          break;
        case NotificationType.systemMessage:
          iconData = Icons.info_outline;
          break;
        case NotificationType.advice:
          iconData = Icons.lightbulb_outline;
          break;
        default:
          iconData = Icons.notifications_active_outlined;
      }
    }
    return CircleAvatar(
      backgroundColor: avatarBgColor,
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // For localization
    final timeAgo = DateFormat.MMMd().add_jm().format(notification.timestamp.toDate());
    final bool isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        developer.log('Dismissed notification ${notification.id} in direction: $direction', name: 'NotificationListItem');
        context.read<NotificationsCubit>().deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.notificationListItemSnackbarRemoved(notification.title)), // LOCALIZED
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: loc.notificationListItemSnackbarUndo, // LOCALIZED
              onPressed: () {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.delete_forever, color: Colors.white),
            const SizedBox(width: 8),
            Text(loc.notificationListItemDismissDelete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // LOCALIZED
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade700,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(loc.notificationListItemDismissDelete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // LOCALIZED
            const SizedBox(width: 8),
            const Icon(Icons.delete_forever, color: Colors.white),
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
          leading: _getLeadingWidget(context, notification), // UPDATED
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
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationDetailScreen(notification: notification),
              ),
            );
          },
        ),
      ),
    );
  }
}