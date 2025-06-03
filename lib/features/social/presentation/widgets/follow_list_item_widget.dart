// lib/features/social/presentation/widgets/follow_list_item_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../screens/view_user_profile_screen.dart'; // Для переходу на профіль

class FollowListItemWidget extends StatelessWidget {
  final UserProfile userProfile;

  const FollowListItemWidget({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        backgroundImage: userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty
            ? NetworkImage(userProfile.profilePictureUrl!)
            : null,
        child: userProfile.profilePictureUrl == null || userProfile.profilePictureUrl!.isEmpty
            ? Icon(Icons.person, size: 22, color: theme.colorScheme.primary)
            : null,
      ),
      title: Text(
        userProfile.displayName ?? userProfile.username ?? 'Unknown User',
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: userProfile.username != null && userProfile.username!.isNotEmpty
          ? Text(
              '@${userProfile.username}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.of(context).push(ViewUserProfileScreen.route(userProfile.uid));
      },
    );
  }
}