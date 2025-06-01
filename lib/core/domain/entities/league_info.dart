// lib/core/domain/entities/league_info.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Для Color

class LeagueInfo extends Equatable {
  final String leagueId;
  final String name;
  final int minLevel;
  final int? maxLevel; // Nullable для останньої ліги
  final int minXp; // Може бути 0 для початкової
  final int? maxXp; // Nullable для останньої ліги
  final List<Color> gradientColors; // Список кольорів для градієнту
  final String? description;

  const LeagueInfo({
    required this.leagueId,
    required this.name,
    required this.minLevel,
    this.maxLevel,
    required this.minXp,
    this.maxXp,
    required this.gradientColors,
    this.description,
  });

  factory LeagueInfo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("LeagueInfo data is null!");

    List<Color> colors = (data['gradientColors'] as List<dynamic>?)
            ?.map((hexColor) {
              try {
                final String colorString = hexColor.toString().replaceAll('#', '');
                return Color(int.parse('FF$colorString', radix: 16));
              } catch (e) {
                // print('Error parsing color $hexColor: $e');
                return Colors.grey; // Default color on error
              }
            })
            .toList() ??
        [Colors.grey, Colors.blueGrey]; // Default gradient on error or missing
    
    if (colors.isEmpty) { // Забезпечуємо, що завжди є хоча б один колір
      colors = [Colors.grey, Colors.blueGrey];
    }


    return LeagueInfo(
      leagueId: snapshot.id,
      name: data['name'] ?? 'Unknown League',
      minLevel: data['minLevel'] as int? ?? 0,
      maxLevel: data['maxLevel'] as int?,
      minXp: data['minXp'] as int? ?? 0,
      maxXp: data['maxXp'] as int?,
      gradientColors: colors,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // leagueId буде ID документа
      'name': name,
      'minLevel': minLevel,
      'maxLevel': maxLevel,
      'minXp': minXp,
      'maxXp': maxXp,
      'gradientColors': gradientColors.map((color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}').toList(),
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        leagueId,
        name,
        minLevel,
        maxLevel,
        minXp,
        maxXp,
        gradientColors,
        description,
      ];
}