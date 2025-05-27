// lib/core/domain/entities/predefined_exercise.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PredefinedExercise {
  final String id;
  final String name;
  final String normalizedName;
  final String primaryMuscleGroup;
  final List<String> secondaryMuscleGroups;
  final List<String> equipmentNeeded;
  final String description;
  final String? videoDemonstrationUrl;
  final String difficultyLevel;
  final List<String> tags;

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

  factory PredefinedExercise.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Exercise data is null!");
    return PredefinedExercise(
      id: snapshot.id,
      name: data['name'] ?? '',
      normalizedName: data['normalizedName'] ?? '',
      primaryMuscleGroup: data['primaryMuscleGroup'] ?? '',
      secondaryMuscleGroups: List<String>.from(data['secondaryMuscleGroups'] ?? []),
      equipmentNeeded: List<String>.from(data['equipmentNeeded'] ?? []),
      description: data['description'] ?? '',
      videoDemonstrationUrl: data['videoDemonstrationUrl'],
      difficultyLevel: data['difficultyLevel'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() { // Необхідно для адмін-панелі або майбутнього створення вправ з додатку
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