// lib/features/progress/presentation/widgets/muscle_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;

class MuscleMapWidget extends StatelessWidget {
  final String svgPath;
  final Map<String, double> muscleData; // SVG_Path_ID -> Value (кількість сетів)
  final double maxThreshold; 
  final double midThreshold; 
  final Color baseColor;      
  final Color midColor;       
  final Color maxColor;       

  const MuscleMapWidget({
    super.key,
    required this.svgPath,
    required this.muscleData,
    this.maxThreshold = 20.0,
    this.midThreshold = 10.0, // 10 сетів = помаранчевий (основний колір додатку)
    this.baseColor = const Color(0xFFE0E0E0), // Світло-сірий, майже білий
    this.midColor = const Color(0xFFED5D1A),  // Основний помаранчевий
    this.maxColor = const Color(0xFFB71C1C),   // Насичений червоний
  });

  Color _calculateMuscleColor(double value) {
    if (value <= 0) return baseColor; 
    if (value >= maxThreshold) return maxColor; 

    if (value <= midThreshold) {
      final t = midThreshold == 0 ? 1.0 : (value / midThreshold).clamp(0.0, 1.0); 
      return Color.lerp(baseColor, midColor, t) ?? midColor;
    } else {
      final range = maxThreshold - midThreshold;
      final t = range == 0 ? 1.0 : ((value - midThreshold) / range).clamp(0.0, 1.0); 
      return Color.lerp(midColor, maxColor, t) ?? maxColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(svgPath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          developer.log("Error loading SVG from path $svgPath: ${snapshot.error}", name:"MuscleMapWidget");
          return Center(child: Icon(Icons.error_outline, color: Colors.red.shade300, size: 40));
        }
        
        String rawSvg = snapshot.data!;
        
        muscleData.forEach((muscleId, value) {
          final Color muscleColor = _calculateMuscleColor(value);
          final String colorHex = '#${muscleColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
          
          // Регулярний вираз для пошуку групи <g id="muscleId">
          final RegExp groupRegex = RegExp(
            r'''(<g\s+id=["']''' + RegExp.escape(muscleId) + r'''["'][^>]*>)((?:.|\n)*?)(</g>)''', // Потрійні лапки для raw string
            dotAll: true
          );

          rawSvg = rawSvg.replaceAllMapped(groupRegex, (groupMatch) {
            String groupStartTag = groupMatch.group(1)!;
            String groupContent = groupMatch.group(2) ?? '';
            String groupEndTag = groupMatch.group(3)!;

            // Замінюємо fill="currentColor" або будь-який існуючий fill="value" на новий колір
            // всередині <path> елементів цієї групи.
            // Використовуємо \3 для зворотного посилання на тип лапок.
            final RegExp pathFillRegex = RegExp(
              r'''(<path[^>]*?)(\s*fill=(["'])(?:currentColor|[^"']*)?\3)([^>]*>)''', // Потрійні лапки
              caseSensitive: false, 
              dotAll: true
            );
            
            groupContent = groupContent.replaceAllMapped(pathFillRegex, (pathMatch) {
              // group(1) - частина до fill
              // group(4) - частина після fill атрибуту до кінця тегу
              return '${pathMatch.group(1)} fill="$colorHex"${pathMatch.group(4)}';
            });

            // Якщо потрібно додати fill, коли його взагалі немає в <path> (менш імовірно для вашого SVG)
            // Цю частину можна закоментувати, якщо всі потрібні <path> вже мають fill="currentColor"
            /*
            final RegExp pathWithoutFillRegex = RegExp(
              r'''(<path)([^>]*?)(?<!\sfill=)(>)''', // Потрійні лапки
              caseSensitive: false,
              dotAll: true
            );
            groupContent = groupContent.replaceAllMapped(pathWithoutFillRegex, (pathMatch) {
               String pathAttributes = pathMatch.group(2) ?? '';
               if (!pathAttributes.toLowerCase().contains('fill=')) {
                 return '${pathMatch.group(1)}$pathAttributes fill="$colorHex"${pathMatch.group(3)}';
               }
               return pathMatch.group(0)!; 
            });
            */

            return groupStartTag + groupContent + groupEndTag;
          });
        });

        try {
          return SvgPicture.string(
            rawSvg,
            width: MediaQuery.of(context).size.width / 2.5, 
            placeholderBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } catch (e, s) {
          developer.log("Error rendering modified SVG for $svgPath: $e", name:"MuscleMapWidget", error: e, stackTrace: s);
          return Center(child: Icon(Icons.broken_image_outlined, color: Colors.orange.shade300, size: 40));
        }
      },
    );
  }
}