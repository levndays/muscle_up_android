// lib/features/progress/presentation/widgets/league_title_widget.dart
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LeagueTitleWidget extends StatefulWidget {
  final String leagueName;
  final int level;
  final List<Color> gradientColors;
  final VoidCallback? onLeagueTap;
  final bool showLevel; // NEW: Optional parameter

  const LeagueTitleWidget({
    super.key,
    required this.leagueName,
    required this.level,
    required this.gradientColors,
    this.onLeagueTap,
    this.showLevel = true, // NEW: Default to true
  });

  @override
  State<LeagueTitleWidget> createState() => _LeagueTitleWidgetState();
}

class _LeagueTitleWidgetState extends State<LeagueTitleWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimationLeft;
  late Animation<Offset> _slideAnimationRight;

  late AnimationController _gradientController;
  late Animation<double> _gradientRotationAnimation;
  late Animation<double> _gradientShiftAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200), // SLOWED DOWN: from 800ms
      vsync: this,
    );

    _slideAnimationLeft = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _slideAnimationRight = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _gradientController = AnimationController(
      duration: const Duration(seconds: 8), // SLOWED DOWN: from 5s
      vsync: this,
    )..repeat();

    _gradientRotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi)
        .animate(_gradientController);

    _gradientShiftAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: -1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: -1.0), weight: 50),
    ]).animate(_gradientController);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color levelLabelColor =
        theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
            Colors.grey.shade700;

    return Row(
      mainAxisAlignment: widget.showLevel ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center, // Center if no level
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SlideTransition(
            position: _slideAnimationLeft,
            child: GestureDetector(
              onTap: widget.onLeagueTap,
              child: AnimatedBuilder(
                animation: _gradientController,
                builder: (context, child) {
                  final Alignment gradientStart = Alignment(
                    math.cos(_gradientRotationAnimation.value),
                    math.sin(_gradientRotationAnimation.value),
                  );
                  final Alignment gradientEnd = Alignment(
                    -math.cos(_gradientRotationAnimation.value + _gradientShiftAnimation.value * math.pi / 2),
                    -math.sin(_gradientRotationAnimation.value + _gradientShiftAnimation.value * math.pi / 2),
                  );

                  final Shader leagueNameGradientShader = LinearGradient(
                    colors: widget.gradientColors.length >= 2
                        ? widget.gradientColors
                        : [widget.gradientColors.first, widget.gradientColors.first],
                    begin: gradientStart,
                    end: gradientEnd,
                    tileMode: TileMode.mirror,
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 250.0, 70.0));

                  return ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => leagueNameGradientShader,
                    child: Text(
                      widget.leagueName.toUpperCase(),
                      textAlign: widget.showLevel ? TextAlign.left : TextAlign.center, // Center if no level
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
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.showLevel) ...[ // Conditionally show level
          const SizedBox(width: 16),
          SlideTransition(
            position: _slideAnimationRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _gradientController,
                  builder: (context, child) {
                    final Shader levelNumberGradientShader = LinearGradient(
                       colors: widget.gradientColors.length >= 2
                          ? widget.gradientColors.reversed.toList()
                          : [widget.gradientColors.first, widget.gradientColors.first],
                      begin: Alignment(
                        math.sin(_gradientRotationAnimation.value + math.pi / 2),
                        math.cos(_gradientRotationAnimation.value + math.pi / 2),
                      ),
                      end: Alignment(
                        -math.sin(_gradientRotationAnimation.value + math.pi / 2 + _gradientShiftAnimation.value * math.pi / 3),
                        -math.cos(_gradientRotationAnimation.value + math.pi / 2 + _gradientShiftAnimation.value * math.pi / 3),
                      ),
                       tileMode: TileMode.mirror,
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 60.0, 60.0));

                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => levelNumberGradientShader,
                      child: Text(
                        widget.level.toString(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 38,
                          height: 1.0,
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'LEVEL',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: levelLabelColor,
                    letterSpacing: 1.5,
                    fontSize: 10,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}