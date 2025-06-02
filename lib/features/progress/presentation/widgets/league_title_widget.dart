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
    // Колір для слова "LEVEL" - можна зробити трохи темнішим для кращого контрасту
    final Color levelLabelColor = theme.textTheme.bodySmall?.color?.withOpacity(0.7) ?? Colors.grey.shade700;

    final Shader leagueNameGradientShader = LinearGradient(
      colors: gradientColors.length >= 2 ? gradientColors : [gradientColors.first, gradientColors.first],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)); // Орієнтовні розміри для ліги

    // Градієнт для номера рівня, використовуємо ті ж кольори, що й для ліги
    final Shader levelNumberGradientShader = LinearGradient(
      colors: gradientColors.length >= 2 ? gradientColors : [gradientColors.first, gradientColors.first],
      begin: Alignment.topCenter, // Можна погратися з напрямком градієнту для числа
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0.0, 0.0, 50.0, 50.0)); // Орієнтовні розміри для числа рівня

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, // <--- ЗМІНЕНО: вирівнюємо по центру по вертикалі
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLeagueTap,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => leagueNameGradientShader,
              child: Text(
                leagueName.toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white, 
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // Відступ між назвою ліги та рівнем
        Column(
          crossAxisAlignment: CrossAxisAlignment.center, // <--- ЗМІНЕНО: центруємо текст рівня
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask( // <--- ДОДАНО ShaderMask для номера рівня
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => levelNumberGradientShader, // Використовуємо градієнт ліги
              child: Text(
                level.toString(),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // Базовий колір для градієнту
                  fontSize: 38, // Можна трохи зменшити, якщо 40 завелике
                  height: 1.0,    // <--- ЗМІНЕНО: для кращого прилягання до "LEVEL"
                ),
              ),
            ),
            // SizedBox(height: 0), // Можна прибрати або зменшити відступ
            Text(
              'LEVEL',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: levelLabelColor, // Використовуємо визначений колір
                letterSpacing: 1.5, 
                fontSize: 10,
                height: 1.0, // <--- ЗМІНЕНО: для кращого прилягання
              ),
            ),
          ],
        ),
      ],
    );
  }
}