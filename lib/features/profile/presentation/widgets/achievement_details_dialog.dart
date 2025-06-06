// lib/features/profile/presentation/widgets/achievement_details_dialog.dart
import 'package:flutter/material.dart';

class AchievementDetailsDialog extends StatelessWidget {
  final String name;
  final String description;
  final String emblemAssetPath;

  const AchievementDetailsDialog({
    super.key,
    required this.name,
    required this.description,
    required this.emblemAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
              emblemAssetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.shield_outlined, color: Colors.grey, size: 50);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
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