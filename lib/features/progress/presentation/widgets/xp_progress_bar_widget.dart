// lib/features/progress/presentation/widgets/xp_progress_bar_widget.dart
import 'package:flutter/material.dart';

class XPProgressBarWidget extends StatefulWidget {
  final int currentXp; // XP на поточній шкалі (від 0 до xpForNextLevel)
  final int xpForNextLevel; // Загальна кількість XP для поточного рівня
  final String startLevelXpText; // Текст для початку шкали (наприклад, "0" або "500 XP")
  final String endLevelXpText; // Текст для кінця шкали (наприклад, "200 XP" або "1000 XP")

  const XPProgressBarWidget({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.startLevelXpText,
    required this.endLevelXpText,
  });

  @override
  State<XPProgressBarWidget> createState() => _XPProgressBarWidgetState();
}

class _XPProgressBarWidgetState extends State<XPProgressBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Тривалість анімації
      vsync: this,
    );

    _updateAnimation();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant XPProgressBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentXp != oldWidget.currentXp || widget.xpForNextLevel != oldWidget.xpForNextLevel) {
      // Оновлюємо анімацію, якщо дані змінилися
      _animationController.reset(); // Скидаємо контролер
      _updateAnimation();
      _animationController.forward(); // Запускаємо знову
    }
  }

  void _updateAnimation() {
    final double targetFill = widget.xpForNextLevel > 0 ? (widget.currentXp.toDouble() / widget.xpForNextLevel.toDouble()).clamp(0.0, 1.0) : 0.0;
    _fillAnimation = Tween<double>(
      begin: _fillAnimation_safeBeginValue(), // Попереднє значення або 0
      end: targetFill,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutQuart));
  }

  // Безпечне отримання початкового значення для Tween
  double _fillAnimation_safeBeginValue() {
    try {
      return _fillAnimation.value; // Якщо анімація вже існує
    } catch (e) {
      return 0.0; // Початкове значення, якщо анімації ще немає
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color progressBarBackground = Color(0xFFE0E0E0); // Світло-сірий
    // Градієнт для заповнення
    const LinearGradient progressBarGradient = LinearGradient(
      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Фіолетовий градієнт
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );


    return Column(
      children: [
        AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, child) {
            return Container(
              height: 18, // Збільшена висота
              decoration: BoxDecoration(
                color: progressBarBackground,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _fillAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: progressBarGradient,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.startLevelXpText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'Inter',
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.endLevelXpText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'Inter',
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}