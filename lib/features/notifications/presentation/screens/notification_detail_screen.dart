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


  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('EEEE, MMMM d, yyyy HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final loc = AppLocalizations.of(context)!; // For localization

    return Scaffold(
      appBar: AppBar(
        title: Text(notification.title),
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
                    _getLeadingWidgetForDetail(context, notification), // UPDATED
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
                        height: 1.5,
                        color: onSurfaceColor.withOpacity(0.85),
                      ),
                ),
                const SizedBox(height: 24),
                if (notification.relatedEntityId != null || notification.relatedEntityType != null) ...[
                  const Divider(height: 24, thickness: 0.8),
                  Text(
                    loc.notificationDetailRelatedInfoTitle, // LOCALIZED
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (notification.relatedEntityType != null)
                    _buildInfoRow(context, loc.notificationDetailRelatedInfoTypeLabel, notification.relatedEntityType!), // LOCALIZED
                  if (notification.relatedEntityId != null)
                    _buildInfoRow(context, loc.notificationDetailRelatedInfoIdLabel, notification.relatedEntityId!), // LOCALIZED
                  const SizedBox(height: 10),
                ],
                if (notification.isRead) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        loc.notificationDetailStatusRead, // LOCALIZED
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