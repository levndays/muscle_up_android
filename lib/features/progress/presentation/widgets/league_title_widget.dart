// lib/features/progress/presentation/widgets/league_title_widget.dart
import 'package:flutter/material.dart';

class LeagueTitleWidget extends StatelessWidget {
  final String leagueName;
  final int level;
  final List<Color> gradientColors;
  final VoidCallback? onLeagueTap;

  const LeagueTitleWidget({
    super.key,
    required this.leagueName,
    required this.level,
    required this.gradientColors,
    this.onLeagueTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color levelNumberColor = Color(0xFF0D47A1); // Насичений синій для числа рівня
    const Color levelTextColor = Colors.black54; // Колір для слова "LEVEL"

    final Shader textGradientShader = LinearGradient(
      colors: gradientColors.length >= 2 ? gradientColors : [gradientColors.first, gradientColors.first],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Вирівнювання по верху для всієї Row
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLeagueTap,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => textGradientShader,
              child: Text(
                leagueName.toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white, // Базовий колір для градієнту
                  height: 1.1,
                ),
                maxLines: 2, // Дозволимо два рядки, якщо назва ліги довга
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Вирівнювання по правому краю
          mainAxisSize: MainAxisSize.min, // Щоб Column займав мінімальну висоту
          children: [
            Text(
              level.toString(),
              style: theme.textTheme.headlineLarge?.copyWith( // Збільшимо шрифт
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
                color: levelNumberColor, // Новий колір
                fontSize: 40, // Збільшений розмір для числа
                height: 0.9, // Зменшуємо висоту рядка, щоб наблизити до "LEVEL"
              ),
            ),
            Text(
              'LEVEL',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: levelTextColor, // Колір для тексту "LEVEL"
                letterSpacing: 1.5, // Трохи розріджуємо букви
                fontSize: 10, // Менший розмір для "LEVEL"
                height: 0.9, // Зменшуємо висоту рядка
              ),
            ),
          ],
        ),
      ],
    );
  }
}