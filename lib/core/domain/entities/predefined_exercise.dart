// lib/core/domain/entities/predefined_exercise.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For BuildContext if used in getters
import 'package:muscle_up/l10n/app_localizations.dart'; // To get current locale

class PredefinedExercise {
  final String id;
  final Map<String, String> name; // e.g., {'en': 'Bench Press', 'uk': 'Жим лежачи'}
  final String normalizedName; // Based on default language, e.g., English, for searching
  final Map<String, String> primaryMuscleGroup;
  final Map<String, List<String>> secondaryMuscleGroups;
  final Map<String, List<String>> equipmentNeeded;
  final Map<String, String> description;
  final String? videoDemonstrationUrl;
  final String difficultyLevel; // Consider localizing this if it's 'Beginner', 'Intermediate', etc.
  final List<String> tags; // Tags might also need a localization strategy

  PredefinedExercise({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.equipmentNeeded,
    required this.description,
    this.videoDemonstrationUrl,
    required this.difficultyLevel,
    required this.tags,
  });

  // Helper method to get the localized name based on BuildContext
  String getLocalizedName(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName.split('_').first; // 'en' or 'uk'
    return name[locale] ?? name['en'] ?? name.values.firstOrNull ?? id;
  }

  String getLocalizedPrimaryMuscleGroup(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName.split('_').first;
    return primaryMuscleGroup[locale] ?? primaryMuscleGroup['en'] ?? primaryMuscleGroup.values.firstOrNull ?? '';
  }

  List<String> getLocalizedSecondaryMuscleGroups(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName.split('_').first;
    return secondaryMuscleGroups[locale] ?? secondaryMuscleGroups['en'] ?? secondaryMuscleGroups.values.firstOrNull ?? [];
  }
   List<String> getLocalizedEquipmentNeeded(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName.split('_').first;
    return equipmentNeeded[locale] ?? equipmentNeeded['en'] ?? equipmentNeeded.values.firstOrNull ?? [];
  }

  String getLocalizedDescription(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName.split('_').first;
    return description[locale] ?? description['en'] ?? description.values.firstOrNull ?? '';
  }

  // Fallback getter if BuildContext is not available (e.g., in some Cubit logic)
  // This will try to use 'en' as a fallback or the first available name.
  String get nameFallback {
      return name['en'] ?? name.values.firstOrNull ?? id;
  }


  factory PredefinedExercise.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Exercise data is null for ID: ${snapshot.id}!");

    Map<String, String> _parseLocalizedMap(dynamic fieldData, String defaultFallbackValue, String fieldName) {
      if (fieldData is Map) {
        return Map<String, String>.from(fieldData.map((k, v) => MapEntry(k.toString(), v.toString())));
      } else if (fieldData is String) {
        // Legacy support: if it's a single string, assume it's for 'en'
        return {'en': fieldData};
      }
      // developer.log("Warning: Localized field '$fieldName' for exercise '${snapshot.id}' is not a Map or String, using fallback.", name: "PredefinedExercise.fromFirestore");
      return {'en': defaultFallbackValue};
    }

    Map<String, List<String>> _parseLocalizedListMap(dynamic fieldData, String fieldName) {
      if (fieldData is Map) {
        return Map<String, List<String>>.from(fieldData.map((k, v) => MapEntry(
          k.toString(),
          (v is List) ? List<String>.from(v.map((item) => item.toString())) : <String>[]
        )));
      } else if (fieldData is List) {
         // Legacy support for a single list (assume 'en')
        return {'en': List<String>.from(fieldData.map((item) => item.toString()))};
      }
      // developer.log("Warning: Localized list field '$fieldName' for exercise '${snapshot.id}' is not a Map or List, using empty fallback.", name: "PredefinedExercise.fromFirestore");
      return {'en': []};
    }
    
    String englishName = '';
    final nameData = data['name'];
    if (nameData is Map && nameData['en'] is String) {
      englishName = nameData['en'];
    } else if (nameData is String) {
      englishName = nameData;
    } else {
      englishName = snapshot.id;
    }


    return PredefinedExercise(
      id: snapshot.id,
      name: _parseLocalizedMap(data['name'], snapshot.id, 'name'),
      normalizedName: data['normalizedName'] as String? ?? englishName.toLowerCase(),
      primaryMuscleGroup: _parseLocalizedMap(data['primaryMuscleGroup'], 'Unknown', 'primaryMuscleGroup'),
      secondaryMuscleGroups: _parseLocalizedListMap(data['secondaryMuscleGroups'], 'secondaryMuscleGroups'),
      equipmentNeeded: _parseLocalizedListMap(data['equipmentNeeded'], 'equipmentNeeded'),
      description: _parseLocalizedMap(data['description'], '', 'description'),
      videoDemonstrationUrl: data['videoDemonstrationUrl'] as String?,
      difficultyLevel: data['difficultyLevel'] as String? ?? 'Unknown',
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name, // Store the map
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