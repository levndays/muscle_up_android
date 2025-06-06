// lib/features/profile/presentation/widgets/achievement_details_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/domain/entities/achievement.dart';

class AchievementDetailsDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailsDialog({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic name/description logic for personalized achievements like records
    String achievementName = achievement.name;
    String achievementDescription = achievement.description;
    if (achievement.isPersonalized) {
      // For now, using a generic placeholder. This can be expanded later
      // if more details are passed to the dialog.
      const detailPlaceholder = "Record"; 
      achievementName = achievement.name.replaceAll('[Detail]', detailPlaceholder);
      achievementDescription = achievement.description.replaceAll('[Detail]', detailPlaceholder);
    }
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              achievement.emblemAssetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.shield_outlined, color: Colors.grey, size: 50);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            achievementName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            achievementDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}