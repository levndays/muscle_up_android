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
      _animationController.reset(); 
      _updateAnimation();
      _animationController.forward(); 
    }
  }

  void _updateAnimation() {
    final double targetFill = widget.xpForNextLevel > 0 ? (widget.currentXp.toDouble() / widget.xpForNextLevel.toDouble()).clamp(0.0, 1.0) : 0.0;
    _fillAnimation = Tween<double>(
      begin: _fillAnimation_safeBeginValue(), 
      end: targetFill,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutQuart));
  }

  double _fillAnimation_safeBeginValue() {
    try {
      // if _fillAnimation is not yet initialized, .value will throw.
      // This can happen if didUpdateWidget is called before initState's _updateAnimation completes,
      // or if the widget is rebuilt quickly.
      return _fillAnimation.value; 
    } catch (e) {
      // Default to 0 if not initialized or in an error state.
      return 0.0; 
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
    const Color progressBarBackground = Color(0xFFE0E0E0); 
    // Новий градієнт відповідно до твого запиту
    const LinearGradient progressBarGradient = LinearGradient(
      colors: [
        Color.fromRGBO(131, 58, 180, 1), // rgba(131, 58, 180, 1)
        Color.fromRGBO(253, 29, 29, 1),  // rgba(253, 29, 29, 1)
        Color.fromRGBO(252, 176, 69, 1) // rgba(252, 176, 69, 1)
      ],
      stops: [0.0, 0.5, 1.0], // 0%, 50%, 100%
      begin: Alignment.centerLeft, // 90deg - зліва направо
      end: Alignment.centerRight,
    );

    return Column(
      children: [
        AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, child) {
            return Container( 
              height: 18,
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
              child: ClipRRect( 
                borderRadius: BorderRadius.circular(9),
                child: LayoutBuilder( 
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: maxWidth * _fillAnimation.value, 
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: progressBarGradient,
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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