// lib/features/notifications/presentation/screens/notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_up/core/domain/entities/app_notification.dart';
import 'package:muscle_up/l10n/app_localizations.dart'; // Import AppLocalizations

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  Widget _getLeadingWidgetForDetail(BuildContext context, AppNotification notification) {
    final theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.primary;
    final Color avatarBgColor = theme.colorScheme.primary.withOpacity(0.1);

    if (notification.type == NotificationType.achievementUnlocked &&
        notification.iconName != null &&
        (notification.iconName!.endsWith('.png') || notification.iconName!.endsWith('.gif'))) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: avatarBgColor,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            notification.iconName!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.emoji_events, size: 32, color: iconColor);
            },
          ),
        ),
      );
    } else if (notification.type == NotificationType.newFollower &&
               notification.senderProfilePicUrl != null &&
               notification.senderProfilePicUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: avatarBgColor,
        backgroundImage: NetworkImage(notification.senderProfilePicUrl!),
        onBackgroundImageError: (_, __) {},
        child: notification.senderProfilePicUrl == null || notification.senderProfilePicUrl!.isEmpty
            ? Icon(Icons.person_add_alt_1, size: 32, color: iconColor)
            : null,
      );
    }

    IconData iconData;
    if (notification.iconName != null) {
      final iconMap = {
        'emoji_events': Icons.emoji_events,
        'fitness_center': Icons.fitness_center,
        'notifications': Icons.notifications_active,
        'reminder': Icons.alarm_on,
        'info_outline': Icons.info,
        'person_add_alt_1': Icons.person_add_alt_1,
        'lightbulb_outline': Icons.lightbulb_outline,
        'military_tech': Icons.military_tech,
        'gavel': Icons.gavel,
      };
      iconData = iconMap[notification.iconName!.toLowerCase()] ?? Icons.notifications_active;
    } else {
       switch (notification.type) {
        case NotificationType.achievementUnlocked:
          iconData = Icons.emoji_events;
          break;
        case NotificationType.workoutReminder:
          iconData = Icons.alarm_on;
          break;
        case NotificationType.newFollower:
          iconData = Icons.person_add_alt_1;
          break;
        case NotificationType.routineShared:
          iconData = Icons.share;
          break;
        case NotificationType.systemMessage:
          iconData = Icons.info;
          break;
        case NotificationType.advice:
           iconData = Icons.lightbulb_outline;
           break;
        default:
          iconData = Icons.notifications_active;
      }
    }
     return CircleAvatar(
        radius: 28,
        backgroundColor: avatarBgColor,
        child: Icon(iconData, size: 32, color: iconColor),
      );
  }


  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final loc = AppLocalizations.of(context)!;
    return DateFormat.yMMMMd(loc.localeName).add_jm().format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final loc = AppLocalizations.of(context)!;
    
    final localizedTitle = notification.getLocalizedTitle(context);
    final localizedMessage = notification.getLocalizedMessage(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedTitle),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 1,
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
                    _getLeadingWidgetForDetail(context, notification),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        localizedTitle,
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
                    _formatTimestamp(context, notification.timestamp.toDate()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                const Divider(height: 32, thickness: 0.8),
                Text(
                  localizedMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: onSurfaceColor.withOpacity(0.85),
                      ),
                ),
                if (notification.isRead) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        loc.notificationDetailStatusRead,
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
}