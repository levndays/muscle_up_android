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

    // Створюємо градієнт
    final Shader textGradientShader = LinearGradient(
      colors: gradientColors.length >= 2 ? gradientColors : [gradientColors.first, gradientColors.first], // Захист, якщо кольорів менше 2
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)); // Rect розмір приблизний, але для ShaderMask це не так критично

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Вирівнюємо по верху
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
                  fontWeight: FontWeight.w900, // Black
                  fontStyle: FontStyle.italic,
                  // Колір тут буде замінено ShaderMask, але краще вказати базовий
                  color: Colors.white, // Базовий колір, який буде "залитий" градієнтом
                  height: 1.1, // Трохи зменшуємо міжрядковий інтервал
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // Відступ між назвою ліги та рівнем
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              level.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900, // Black
                color: const Color(0xFFE91E63), // Яскравий рожевий/пурпурний
                fontSize: 38, // Збільшимо розмір цифри рівня
                height: 0.9,
              ),
            ),
            Text(
              'LEVEL',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 0.5,
                height: 0.9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}