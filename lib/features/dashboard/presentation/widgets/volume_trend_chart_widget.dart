// lib/features/dashboard/presentation/widgets/volume_trend_chart_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

enum VolumeTrend { positive, negative, neutral }

class VolumeTrendChartWidget extends StatelessWidget {
  final List<double> volumes; // Об'єми в кг

  const VolumeTrendChartWidget({super.key, required this.volumes});

  VolumeTrend get _trend {
    if (volumes.length < 2) return VolumeTrend.neutral;
    if (volumes.last > volumes.first) return VolumeTrend.positive;
    if (volumes.last < volumes.first) return VolumeTrend.negative;
    return VolumeTrend.neutral;
  }

  LinearGradient get _gradient {
    switch (_trend) {
      case VolumeTrend.positive:
        return const LinearGradient(
          colors: [Color.fromRGBO(0, 255, 30, 1), Color.fromRGBO(0, 102, 43, 1)],
          stops: [0.0, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case VolumeTrend.negative:
        return const LinearGradient(
          colors: [Color.fromRGBO(253, 29, 29, 1), Color.fromRGBO(84, 0, 0, 1)],
          stops: [0.5, 1.0], 
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case VolumeTrend.neutral:
      default:
        return const LinearGradient(
          colors: [Color.fromRGBO(255, 157, 0, 1), Color.fromRGBO(255, 0, 0, 1)],
          stops: [0.0, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color defaultTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color chartBackgroundColor = isDarkMode ? Colors.grey[850]! : Colors.white;


    if (volumes.isEmpty) {
      return _buildMessageContainer(context, "Log workouts to see your volume trend.", chartBackgroundColor, defaultTextColor);
    }
    if (volumes.length < 2 && volumes.isNotEmpty) {
      return _buildMessageContainer(context, "Log at least two workouts to see the trend.", chartBackgroundColor, defaultTextColor);
    }
     if (volumes.length == 1) { 
      final singleVolumeK = (volumes.first / 1000).toStringAsFixed(1);
      return _buildMessageContainer(context, "Last workout volume: $singleVolumeK k kg.\nMore workouts needed for trend.", chartBackgroundColor, defaultTextColor, isSinglePoint: true);
    }


    return AspectRatio(
      aspectRatio: 1.8, 
      child: Container(
        padding: const EdgeInsets.only(right: 16, left: 6, top: 20, bottom: 10),
        decoration: BoxDecoration(
           color: chartBackgroundColor, // Змінено на білий або темний залежно від теми
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 0.5) // Тонка рамка
        ),
        child: CustomPaint(
          painter: _VolumeChartPainter(
            volumes: volumes.map((v) => v / 1000).toList(), 
            gradient: _gradient,
            textColor: defaultTextColor, // Адаптивний колір тексту
            gridColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, // Адаптивний колір сітки
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context, String message, Color backgroundColor, Color textColor, {bool isSinglePoint = false}) {
    return Container(
      height: 150, 
      decoration: BoxDecoration(
         color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 0.5)
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: isSinglePoint ? FontWeight.w600 : FontWeight.normal),
          ),
        ),
      ),
    );
  }
}

class _VolumeChartPainter extends CustomPainter {
  final List<double> volumes; 
  final LinearGradient gradient;
  final Color textColor;
  final Color gridColor; // Додано колір сітки

  _VolumeChartPainter({required this.volumes, required this.gradient, required this.textColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (volumes.length < 2) return;

    final Paint linePaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final Paint pointPaint = Paint()
        ..color = gradient.colors.first.withOpacity(0.9) 
        ..style = PaintingStyle.fill;

    final Paint gridPaint = Paint()
      ..color = gridColor.withOpacity(0.5) // Використовуємо переданий колір сітки
      ..strokeWidth = 0.5;

    const double yAxisLabelPadding = 28.0;
    const double xAxisLabelPadding = 20.0;
    final double chartWidth = size.width - yAxisLabelPadding;
    final double chartHeight = size.height - xAxisLabelPadding;

    double maxVolume = volumes.reduce(math.max);
    double minVolume = volumes.reduce(math.min);

    if (maxVolume == minVolume) {
        maxVolume += (maxVolume * 0.2).clamp(1.0, double.infinity); 
        minVolume -= (minVolume * 0.2).clamp(0.0, maxVolume > 0 ? (maxVolume*0.1).clamp(0.5, double.infinity) : 0.5); 
        if (minVolume < 0) minVolume = 0;
    } else {
      final rangePadding = (maxVolume - minVolume) * 0.1;
      maxVolume += rangePadding;
      minVolume -= rangePadding;
      if (minVolume < 0) minVolume = 0;
    }
    if (maxVolume == minVolume) maxVolume = minVolume +1; 

    final double yRange = maxVolume - minVolume;
    final double xStep = chartWidth / (volumes.length - 1);

    final TextPainter textPainter = TextPainter(textAlign: TextAlign.right, textDirection: ui.TextDirection.ltr);

    int numHLines = 4;
    for (int i = 0; i <= numHLines; i++) {
      final yVal = minVolume + (yRange / numHLines) * i;
      final yPos = chartHeight - (yVal - minVolume) / yRange * chartHeight;

      canvas.drawLine(Offset(yAxisLabelPadding, yPos), Offset(size.width, yPos), gridPaint);
      
      textPainter.text = TextSpan(text: '${yVal.toStringAsFixed(yVal < 10 && yVal != 0 ? 1:0)}k', style: TextStyle(color: textColor, fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(yAxisLabelPadding - textPainter.width - 4, yPos - textPainter.height / 2));
    }
    
    // Мітки X (номери тренувань) - БЕЗ ВЕРТИКАЛЬНИХ ЛІНІЙ
    for (int i = 0; i < volumes.length; i++) {
      final xPos = yAxisLabelPadding + i * xStep;
      textPainter.text = TextSpan(text: 'W${i + 1}', style: TextStyle(color: textColor, fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, chartHeight + 4));
    }

    final Path linePath = Path();
    final Path fillPath = Path();

    final List<Offset> points = [];
    for (int i = 0; i < volumes.length; i++) {
      final x = yAxisLabelPadding + i * xStep;
      final y = chartHeight - (volumes[i] - minVolume) / yRange * chartHeight;
      points.add(Offset(x, y.clamp(0.0, chartHeight))); 
    }

    linePath.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, chartHeight);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp1x = p0.dx + (p1.dx - p0.dx) / 2; 
      final cp1y = p0.dy;                      
      final cp2x = p0.dx + (p1.dx - p0.dx) / 2; 
      final cp2y = p1.dy;                      

      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p1.dx, p1.dy);
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, p1.dx, p1.dy);
    }
    
    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    final Paint areaFillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final Color startColor = gradient.colors.first.withOpacity(0.35);
    final Color endColor = gradient.colors.last.withOpacity(0.05);

    areaFillPaint.shader = LinearGradient(
        colors: [startColor, endColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(fillPath, areaFillPaint);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 4.0, pointPaint); 
       canvas.drawCircle(point, 4.0, Paint()..color = Colors.white ..style = PaintingStyle.stroke ..strokeWidth = 1.5); 
    }
  }

  @override
  bool shouldRepaint(_VolumeChartPainter oldDelegate) {
    return oldDelegate.volumes != volumes || 
           oldDelegate.gradient != gradient || 
           oldDelegate.textColor != textColor ||
           oldDelegate.gridColor != gridColor; // Додано перевірку для gridColor
  }
}