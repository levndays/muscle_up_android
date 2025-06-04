// lib/features/leagues/presentation/widgets/animated_spotlight_background.dart
import 'dart:math' as math; // CORRECTED: Added import for math and Random
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AnimatedSpotlightBackground extends StatefulWidget {
  const AnimatedSpotlightBackground({super.key});

  @override
  State<AnimatedSpotlightBackground> createState() => _AnimatedSpotlightBackgroundState();
}

class _AnimatedSpotlightBackgroundState extends State<AnimatedSpotlightBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _angleAnimations;
  late List<Animation<double>> _intensityAnimations; 
  final int _numSpotlights = 2; 
  final math.Random _random = math.Random(); // CORRECTED: Used math.Random

  final List<Color> _spotlightColors = [
    Colors.white.withOpacity(0.15), 
    Colors.white.withOpacity(0.05), 
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_numSpotlights, (index) {
      return AnimationController(
        duration: Duration(seconds: _random.nextInt(5) + 8), 
        vsync: this,
      )..repeat(reverse: true);
    });

    _angleAnimations = List.generate(_numSpotlights, (index) {
      double initialAngleOffset = (_random.nextDouble() - 0.5) * 0.2; 
      double angleAmplitude = 0.15 + _random.nextDouble() * 0.1; 

      return Tween<double>(
        begin: -angleAmplitude + initialAngleOffset,
        end: angleAmplitude + initialAngleOffset,
      ).animate(CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOutSine));
    });
    
    _intensityAnimations = List.generate(_numSpotlights, (index) {
       return TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.0), weight: 40),
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.7), weight: 30),
        TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.9), weight: 30),
      ]).animate(CurvedAnimation(parent: _controllers[index], curve: Curves.linear));
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black, 
      ),
      child: CustomPaint(
        painter: _SpotlightPainter(
          angleAnimations: _angleAnimations,
          intensityAnimations: _intensityAnimations,
          spotlightColors: _spotlightColors,
          numSpotlights: _numSpotlights,
        ),
        child: Container(), 
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final List<Animation<double>> angleAnimations;
  final List<Animation<double>> intensityAnimations;
  final List<Color> spotlightColors;
  final int numSpotlights;

  _SpotlightPainter({
    required this.angleAnimations,
    required this.intensityAnimations,
    required this.spotlightColors,
    required this.numSpotlights,
  }) : super(repaint: Listenable.merge([...angleAnimations, ...intensityAnimations]));


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < numSpotlights; i++) {
      final angle = angleAnimations[i].value;
      final intensity = intensityAnimations[i].value.clamp(0.5, 1.0); 

      final Offset source;
      if (numSpotlights == 1) {
        source = Offset(size.width / 2, size.height * 1.15);
      } else {
        final double xPosition = (i == 0) ? size.width * 0.20 : size.width * 0.80;
        source = Offset(xPosition, size.height * 1.1); 
      }

      final Offset p1 = Offset(
        source.dx + math.cos(math.pi / 2 + angle - 0.25) * size.height * 1.5, 
        source.dy - math.sin(math.pi / 2 + angle - 0.25) * size.height * 1.5,
      );
      final Offset p2 = Offset(
        source.dx + math.cos(math.pi / 2 + angle + 0.25) * size.height * 1.5,
        source.dy - math.sin(math.pi / 2 + angle + 0.25) * size.height * 1.5,
      );
      
      final path = Path()
        ..moveTo(source.dx, source.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      paint.shader = ui.Gradient.linear(
        source, 
        Offset( (p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 ), 
        [
          spotlightColors[0].withOpacity(spotlightColors[0].opacity * intensity), 
          spotlightColors[1].withOpacity(spotlightColors[1].opacity * intensity * 0.5), 
          Colors.transparent, 
        ],
        [0.0, 0.4, 1.0], 
      );
      paint.style = PaintingStyle.fill;

      canvas.drawPath(path, paint);

      final Paint baseLightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4 * intensity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(source, 15, baseLightPaint); 
    }

    final Rect stageLightRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.85),
        width: size.width * 0.7,
        height: size.height * 0.15);

    final Paint stageLightPaint = Paint()
      ..shader = ui.Gradient.radial(
        stageLightRect.center,
        stageLightRect.width / 2,
        [
          Colors.white.withOpacity(0.08 * intensityAnimations.first.value.clamp(0.6, 1.0)), 
          Colors.transparent,
        ],
         [0.0, 1.0],
      );
    canvas.drawOval(stageLightRect, stageLightPaint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) => true; 
}