// lib/features/progress/presentation/widgets/muscle_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui show lerpDouble; // Explicit import for lerpDouble
import 'dart:math' as math; // For math.min

class MuscleMapWidget extends StatefulWidget {
  final String svgPath;
  final Map<String, double> muscleData;
  final double midThreshold;
  final double maxThreshold;
  final Color baseColor;
  final Color midColor;
  final Color maxColor;

  const MuscleMapWidget({
    super.key,
    required this.svgPath,
    required this.muscleData,
    this.midThreshold = 10.0,
    this.maxThreshold = 20.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.midColor = const Color(0xFFED5D1A),
    this.maxColor = const Color(0xFFD50000),
  });

  @override
  State<MuscleMapWidget> createState() => _MuscleMapWidgetState();
}

class _MuscleMapWidgetState extends State<MuscleMapWidget> {
  String? _processedSvgString;
  String _lastProcessedSvgPath = '';
  Map<String, double> _lastProcessedMuscleData = {};
  Key _svgKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadAndProcessSvg();
  }

  @override
  void didUpdateWidget(covariant MuscleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.svgPath != oldWidget.svgPath ||
        !_mapEquals(widget.muscleData, oldWidget.muscleData)) {
      _loadAndProcessSvg();
    }
  }

  bool _mapEquals(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadAndProcessSvg() async {
    // Avoid reprocessing if data and path haven't changed and SVG is already processed.
    if (_lastProcessedSvgPath == widget.svgPath &&
        _mapEquals(_lastProcessedMuscleData, widget.muscleData) &&
        _processedSvgString != null) {
      return;
    }
    if (mounted) {
      setState(() {
        _processedSvgString = null; // Show loading indicator
      });
    }

    try {
      String svgString = await rootBundle.loadString(widget.svgPath);
      String modifiedSvg = _applyColorsToSvg(svgString, widget.muscleData);

      if (mounted) {
        setState(() {
          _processedSvgString = modifiedSvg;
          _lastProcessedSvgPath = widget.svgPath;
          _lastProcessedMuscleData = Map.from(widget.muscleData);
          _svgKey = UniqueKey(); // Force SvgPicture to rebuild
        });
      }
    } catch (e, s) {
      developer.log('MuscleMapWidget: Error loading/processing SVG: $e', name: 'MuscleMapWidget', error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _processedSvgString = null; // Indicate error or use a placeholder error SVG
        });
      }
    }
  }

  Color _getColorForValue(double value) {
    if (value <= 0) {
      return widget.baseColor;
    }
    if (value >= widget.maxThreshold) {
      return widget.maxColor;
    }
    // Interpolate color based on thresholds
    if (value <= widget.midThreshold) {
      double t = (widget.midThreshold == 0) ? 1.0 : (value / widget.midThreshold); // Avoid division by zero
      return Color.lerp(widget.baseColor, widget.midColor, t.clamp(0.0, 1.0)) ?? widget.midColor;
    } else {
      double t = (widget.maxThreshold == widget.midThreshold) ? 1.0 : ((value - widget.midThreshold) / (widget.maxThreshold - widget.midThreshold)); // Avoid division by zero
      return Color.lerp(widget.midColor, widget.maxColor, t.clamp(0.0, 1.0)) ?? widget.maxColor;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.hex}';
  }

  String _applyColorsToSvg(String svgString, Map<String, double> muscleData) {
    String result = svgString;
    final String baseHexColor = _colorToHex(widget.baseColor);

    // Step 1: Replace all 'currentColor' fills with the baseColor.
    // This ensures unmentioned muscle groups get the base color.
    result = result.replaceAllMapped(
        RegExp(r'''fill\s*=\s*["\']currentColor["\']''', caseSensitive: false), 
        (match) => 'fill="$baseHexColor"'
    );

    // Step 2: Iterate through provided muscleData and apply specific colors.
    muscleData.forEach((muscleId, value) {
      final Color color = _getColorForValue(value);
      final String hexColor = _colorToHex(color);
      
      // Regex to find a <g> tag with a specific id attribute.
      final RegExp groupRegex = RegExp(
        '(<g[^>]*id\\s*=\\s*["\']$muscleId["\'][^>]*>)(.*?)(<\/g>)',
        dotAll: true, // Allows '.' to match newlines.
        caseSensitive: false,
      );

      result = result.replaceAllMapped(groupRegex, (groupMatch) {
        String groupTagOpen = groupMatch.group(1)!;
        String groupContent = groupMatch.group(2)!;
        String groupTagClose = groupMatch.group(3)!;
        
        // Replace any fill attribute within the paths of this specific group.
        // This will override the baseColor set in Step 1 for this muscle group.
        String modifiedContent = groupContent.replaceAllMapped(
            RegExp(r'''fill\s*=\s*["\']([^"\']+)["\']''', caseSensitive: false),
            (pathFillMatch) => 'fill="$hexColor"'
        );
        return groupTagOpen + modifiedContent + groupTagClose;
      });
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_processedSvgString == null) {
      return const Center(
        child: SizedBox(
          width: 50, height: 50, 
          child: CircularProgressIndicator(strokeWidth: 2)
        )
      );
    }
    
    return SvgPicture.string(
      _processedSvgString!,
      key: _svgKey, // Ensures SvgPicture rebuilds when the SVG string changes
      width: MediaQuery.of(context).size.width / 2 - 20, // Adapts width
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
    );
  }
}

extension HexColor on Color {
  /// Returns the hex string for a color (e.g., "FF0000" for red).
  /// Alpha channel is excluded.
  String get hex => '${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
}