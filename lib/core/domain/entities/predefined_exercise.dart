// lib/core/domain/entities/predefined_exercise.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For Locale
import 'package:muscle_up/l10n/app_localizations.dart'; // To get current locale

class PredefinedExercise {
  final String id;
  final Map<String, String> name; // e.g., {'en': 'Bench Press', 'uk': 'Жим лежачи'}
  final Map<String, String> primaryMuscleGroup;
  final Map<String, List<String>> secondaryMuscleGroups; // e.g., {'en': ['Triceps', 'Shoulders'], 'uk': ['Трицепс', 'Плечі']}
  final Map<String, List<String>> equipmentNeeded;
  final Map<String, String> description;
  final String? videoDemonstrationUrl;
  final String difficultyLevel; // This might also need localization if it's free text
  final List<String> tags; // Tags might also need a localization strategy

  final String normalizedName; // Keep for searching, based on a default language e.g. English

  PredefinedExercise({
    required this.id,
    required this.name,
    required this.normalizedName, // Based on default language, e.g., English
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.equipmentNeeded,
    required this.description,
    this.videoDemonstrationUrl,
    required this.difficultyLevel,
    required this.tags,
  });

  String getLocalizedName(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    return name[locale] ?? name['en'] ?? name.values.firstOrNull ?? id;
  }

  String getLocalizedPrimaryMuscleGroup(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    return primaryMuscleGroup[locale] ?? primaryMuscleGroup['en'] ?? primaryMuscleGroup.values.firstOrNull ?? '';
  }

  List<String> getLocalizedSecondaryMuscleGroups(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    return secondaryMuscleGroups[locale] ?? secondaryMuscleGroups['en'] ?? secondaryMuscleGroups.values.firstOrNull ?? [];
  }

  List<String> getLocalizedEquipmentNeeded(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    return equipmentNeeded[locale] ?? equipmentNeeded['en'] ?? equipmentNeeded.values.firstOrNull ?? [];
  }

  String getLocalizedDescription(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    return description[locale] ?? description['en'] ?? description.values.firstOrNull ?? '';
  }


  factory PredefinedExercise.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Exercise data is null!");

    // Helper to parse localized maps, falling back to English or the first available
    Map<String, String> _parseLocalizedMap(dynamic fieldData, String defaultKey) {
      if (fieldData is Map) {
        return Map<String, String>.from(fieldData.map((k, v) => MapEntry(k.toString(), v.toString())));
      } else if (fieldData is String) {
        // Legacy support: if it's a single string, assume it's for 'en' or default
        return {'en': fieldData};
      }
      return {'en': defaultKey}; // Fallback
    }

    Map<String, List<String>> _parseLocalizedListMap(dynamic fieldData) {
      if (fieldData is Map) {
        return Map<String, List<String>>.from(fieldData.map((k, v) => MapEntry(
          k.toString(),
          (v is List) ? List<String>.from(v.map((item) => item.toString())) : <String>[]
        )));
      }
      return {'en': []}; // Fallback
    }

    return PredefinedExercise(
      id: snapshot.id,
      name: _parseLocalizedMap(data['name'], snapshot.id),
      normalizedName: data['normalizedName'] ?? (data['name'] is String ? (data['name'] as String).toLowerCase() : snapshot.id.toLowerCase()),
      primaryMuscleGroup: _parseLocalizedMap(data['primaryMuscleGroup'], 'Unknown'),
      secondaryMuscleGroups: _parseLocalizedListMap(data['secondaryMuscleGroups']),
      equipmentNeeded: _parseLocalizedListMap(data['equipmentNeeded']),
      description: _parseLocalizedMap(data['description'], ''),
      videoDemonstrationUrl: data['videoDemonstrationUrl'],
      difficultyLevel: data['difficultyLevel'] ?? '', // Consider localizing this if it's 'Beginner', 'Intermediate', etc.
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // toJson would also need to be updated if you allow client-side creation/update
  // For now, assuming it's primarily read from Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'normalizedName': normalizedName,
      'primaryMuscleGroup': primaryMuscleGroup,
      'secondaryMuscleGroups': secondaryMuscleGroups,
      'equipmentNeeded': equipmentNeeded,
      'description': description,
      'videoDemonstrationUrl': videoDemonstrationUrl,
      'difficultyLevel': difficultyLevel,
      'tags': tags,
    };
  }
}