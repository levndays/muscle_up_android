// lib/features/workout_tracking/presentation/widgets/current_set_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/logged_exercise.dart';
import '../../../../core/domain/entities/logged_set.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../cubit/active_workout_cubit.dart'; 
import 'dart:math' as math;
import 'package:muscle_up/l10n/app_localizations.dart';

// --- RpeSlider Widget ---
class RpeSlider extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const RpeSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<RpeSlider> createState() => _RpeSliderState();
}

class _RpeSliderState extends State<RpeSlider> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant RpeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _currentValue) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient gradient = LinearGradient(
      colors: [Colors.green.shade400, Colors.yellow.shade500, Colors.red.shade500],
      stops: const [0.0, 0.5, 1.0],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _currentValue.toString(),
          style: const TextStyle(
            fontFamily: _CurrentSetDisplayState.ibmPlexMonoFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 22.0,
                thumbColor: Colors.black,
                overlayColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 2.0),
                trackShape: GradientRectSliderTrackShape(gradient: gradient),
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              ),
              child: Slider(
                value: _currentValue.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (double value) {
                  setState(() { _currentValue = value.round(); });
                  widget.onChanged(_currentValue);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- GradientRectSliderTrackShape ---
class GradientRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final LinearGradient gradient;
  final bool darkenInactive;
  const GradientRectSliderTrackShape({required this.gradient, this.darkenInactive = true});
  @override
  void paint(PaintingContext context, Offset offset, { required RenderBox parentBox, required SliderThemeData sliderTheme, required Animation<double> enableAnimation, required TextDirection textDirection, required Offset thumbCenter, Offset? secondaryOffset, bool isDiscrete = false, bool isEnabled = false, double additionalActiveTrackHeight = 2}) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) { return; }
    final Rect trackRect = getPreferredRect(parentBox: parentBox, offset: offset, sliderTheme: sliderTheme, isEnabled: isEnabled, isDiscrete: isDiscrete);
    final Paint paint = Paint()..shader = gradient.createShader(trackRect);
    context.canvas.drawRRect(RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2)), paint);
  }
}

// --- CurrentSetDisplay Widget ---
class CurrentSetDisplay extends StatefulWidget {
  final LoggedExercise currentExercise;
  final PredefinedExercise? fullExerciseDetails; // <-- THIS IS THE PARAMETER
  final LoggedSet currentSet;
  final int exerciseIndex;
  final int setIndex;
  final int totalSetsInExercise;
  final void Function({required bool next}) onRequestSetNavigation;
  final VoidCallback onCompleteWorkoutRequested;

  const CurrentSetDisplay({
    super.key,
    required this.currentExercise,
    this.fullExerciseDetails, // <-- THIS IS THE PARAMETER
    required this.currentSet,
    required this.exerciseIndex,
    required this.setIndex,
    required this.totalSetsInExercise,
    required this.onRequestSetNavigation,
    required this.onCompleteWorkoutRequested,
  });
  @override
  State<CurrentSetDisplay> createState() => _CurrentSetDisplayState();
}

class _CurrentSetDisplayState extends State<CurrentSetDisplay> {
  late TextEditingController _weightController;
  late int _repsCount;
  late List<int> _rpePerRep;

  static const Color primaryOrange = Color(0xFFED5D1A);
  static const Color textBlackColor = Colors.black87;
  static const String ibmPlexMonoFont = 'IBMPlexMono';

  @override
  void initState() {
    super.initState();
    _initializeSetData(widget.currentSet, widget.currentExercise, widget.setIndex);
  }

  @override
  void didUpdateWidget(covariant CurrentSetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSet != oldWidget.currentSet || widget.currentExercise != oldWidget.currentExercise || widget.setIndex != oldWidget.setIndex) {
      _initializeSetData(widget.currentSet, widget.currentExercise, widget.setIndex);
    }
  }

  void _initializeSetData(LoggedSet set, LoggedExercise exercise, int currentSetIndex) {
    double? weightForTextField;

    if (set.weightKg != null && set.weightKg! > 0) {
        weightForTextField = set.weightKg;
    } 
    else if (currentSetIndex > 0) { 
        if (exercise.completedSets.length > currentSetIndex - 1) {
            final previousSet = exercise.completedSets[currentSetIndex - 1];
            if (previousSet.isCompleted && previousSet.weightKg != null && previousSet.weightKg! > 0) {
                weightForTextField = previousSet.weightKg; 
            }
        }
    }

    _weightController = TextEditingController(text: weightForTextField?.toStringAsFixed(weightForTextField != null && weightForTextField % 1 == 0 ? 0 : 1) ?? '0');
    _repsCount = set.reps ?? 8;
    _rpePerRep = List.filled(20, 0); 
    final rpeData = _parseRpeNotes(set.notes);
    if (rpeData != null) {
      for (int i = 0; i < rpeData.length; i++) {
        if (i < _rpePerRep.length) _rpePerRep[i] = rpeData[i];
      }
    } else {
      for (int i = 0; i < _repsCount; i++) {
         if (i < _rpePerRep.length) _rpePerRep[i] = 5;
      }
    }
  }

  List<int>? _parseRpeNotes(String? notes) { if (notes == null || !notes.startsWith("RPE_DATA:")) return null; try { final dataString = notes.substring("RPE_DATA:".length); if (dataString.isEmpty) return []; return dataString.split(',').map(int.parse).toList(); } catch (e) { return null; } }
  String _rpeToStringNotes(List<int> rpeValues, int activeReps) { if (activeReps <= 0 || rpeValues.isEmpty) return "RPE_DATA:"; final safeActiveReps = math.min(activeReps, rpeValues.length); if (safeActiveReps <= 0) return "RPE_DATA:"; return "RPE_DATA:${rpeValues.sublist(0, safeActiveReps).join(',')}"; }

  void _saveSetDataToCubit() {
    final cubit = context.read<ActiveWorkoutCubit>();
    final weightText = _weightController.text.replaceAll(',', '.');
    final weight = double.tryParse(weightText);
    final notesWithRpe = _rpeToStringNotes(_rpePerRep, _repsCount);
    cubit.updateLoggedSet(exerciseIndex: widget.exerciseIndex, setIndex: widget.setIndex, weight: weight, reps: _repsCount, isCompleted: true, notes: notesWithRpe);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Widget _buildRepControlButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(width: 44, height: 44, child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: const CircleBorder(), padding: EdgeInsets.zero, elevation: 2), child: Icon(icon, color: Colors.white, size: 22)));
  }
  
  Widget _buildWeightControlButton(IconData icon, VoidCallback onPressed, {bool isSmall = false}) {
    return SizedBox(
      width: isSmall ? 38 : 44, 
      height: isSmall ? 38 : 44, 
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange.withOpacity(0.9), 
          shape: const CircleBorder(), 
          padding: EdgeInsets.zero, 
          elevation: 1
        ), 
        child: Icon(icon, color: Colors.white, size: isSmall ? 18 : 22)
      )
    );
  }

  Future<void> _showEditWeightDialog() async {
    final loc = AppLocalizations.of(context)!;
    final tempWeightController = TextEditingController(text: _weightController.text);
    final newWeight = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(loc.currentSetDisplayWeightDialogTitle, style: const TextStyle(fontFamily: ibmPlexMonoFont)),
          content: SingleChildScrollView(
            child: TextField(
              controller: tempWeightController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              decoration: InputDecoration(hintText: loc.currentSetDisplayWeightDialogHint),
              style: const TextStyle(fontFamily: ibmPlexMonoFont, fontSize: 18)
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(loc.currentSetDisplayWeightDialogButtonCancel)),
            ElevatedButton(onPressed: () => Navigator.pop(dialogCtx, tempWeightController.text), child: Text(loc.currentSetDisplayWeightDialogButtonSet))
          ]
        );
      }
    );
    if (newWeight != null && newWeight.isNotEmpty) {
      setState(() { _weightController.text = newWeight.replaceAll(',', '.'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final workoutState = context.watch<ActiveWorkoutCubit>().state;
    int totalExercises = 0;
    if (workoutState is ActiveWorkoutInProgress) {
      totalExercises = workoutState.session.completedExercises.length;
    }

    bool isFirstSetOverall = widget.exerciseIndex == 0 && widget.setIndex == 0;
    bool isLastSetOfCurrentExercise = widget.setIndex == widget.totalSetsInExercise - 1;
    bool isLastExercise = totalExercises > 0 && widget.exerciseIndex == totalExercises - 1;
    bool isLastSetOverall = isLastExercise && isLastSetOfCurrentExercise;
    
    String muscleGroupsText = loc.currentSetDisplayMuscleGroupsLoading;
    if (widget.fullExerciseDetails != null) {
      final primary = widget.fullExerciseDetails!.getLocalizedPrimaryMuscleGroup(context);
      final secondary = widget.fullExerciseDetails!.getLocalizedSecondaryMuscleGroups(context);
      if (secondary.isNotEmpty) {
        muscleGroupsText = '$primary, ${secondary.join(', ')}'.toUpperCase();
      } else {
        muscleGroupsText = primary.toUpperCase();
      }
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.currentExercise.exerciseNameSnapshot.toUpperCase(), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 24, color: textBlackColor)),
                Text(muscleGroupsText, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    RichText(text: TextSpan(style: theme.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w900), children: [ TextSpan(text: loc.currentSetDisplaySetLabelPrefix, style: const TextStyle(color: textBlackColor)), TextSpan(text: '${widget.setIndex + 1}', style: const TextStyle(color: primaryOrange))])),
                    const Spacer(),
                    _buildWeightControlButton(Icons.remove, () {
                      double currentWeight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;
                      currentWeight = (currentWeight - 1.0).clamp(0.0, 999.0);
                      setState(() { _weightController.text = currentWeight.toStringAsFixed(currentWeight % 1 == 0 ? 0 : 1); });
                    }, isSmall: true),
                    InkWell(
                      onTap: _showEditWeightDialog, 
                      borderRadius: BorderRadius.circular(8), 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), 
                        child: Row(
                          mainAxisSize: MainAxisSize.min, 
                          children: [ 
                            const Icon(Icons.fitness_center, size: 18, color: textBlackColor), 
                            const SizedBox(width: 4), 
                            Text(loc.currentSetDisplayWeightLabelPrefix, style: theme.textTheme.bodyLarge?.copyWith(fontFamily: ibmPlexMonoFont, fontSize: 13, color: textBlackColor, fontWeight: FontWeight.bold)), 
                            Text(_weightController.text.isNotEmpty ? _weightController.text : "0", style: theme.textTheme.bodyLarge?.copyWith(fontFamily: ibmPlexMonoFont, fontWeight: FontWeight.bold, color: primaryOrange, fontSize: 15)), 
                            const SizedBox(width: 2), 
                            Text(loc.currentSetDisplayUnitKgSuffix, style: theme.textTheme.bodyLarge?.copyWith(fontFamily: ibmPlexMonoFont, color: primaryOrange, fontSize: 13, fontWeight: FontWeight.bold))
                          ]
                        )
                      )
                    ),
                     _buildWeightControlButton(Icons.add, () {
                      double currentWeight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;
                      currentWeight += 1.0;
                      setState(() { _weightController.text = currentWeight.toStringAsFixed(currentWeight % 1 == 0 ? 0 : 1); });
                    }, isSmall: true),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            Column(
              children: [
                RichText(text: TextSpan(style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 26), children: [TextSpan(text: '$_repsCount ', style: const TextStyle(color: primaryOrange)), TextSpan(text: loc.currentSetDisplayRepsLabelSuffix, style: const TextStyle(color: textBlackColor))])),
                const SizedBox(height: 6),
                Text(loc.currentSetDisplayRpeHelpText, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(fontFamily: ibmPlexMonoFont, fontSize: 12, color: textBlackColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(
                    height: 220,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      _buildRepControlButton(Icons.remove, () { if (_repsCount > 0) { setState(() { _repsCount--; if (_repsCount >= 0 && _repsCount < _rpePerRep.length) _rpePerRep[_repsCount] = 0; }); } }),
                      const SizedBox(width: 5),
                      Expanded(child: _repsCount > 0 ? SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children: List.generate(_repsCount, (index) { return Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0), child: SizedBox(height: double.infinity, child: RpeSlider(initialValue: _rpePerRep[index], onChanged: (val) { setState(() { _rpePerRep[index] = val; }); }))); }))) : Center(child: Text(loc.currentSetDisplayNoRepsPlaceholder, style: TextStyle(fontFamily: ibmPlexMonoFont, color: Colors.grey.shade600)))),
                      const SizedBox(width: 5),
                      _buildRepControlButton(Icons.add, () { if (_repsCount < _rpePerRep.length) { setState(() { if (_repsCount >= 0 && _repsCount < _rpePerRep.length) _rpePerRep[_repsCount] = 5; _repsCount++; }); } })
                    ])
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0, top: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(loc.currentSetDisplayButtonPrevSet, style: TextStyle(fontFamily: ibmPlexMonoFont, fontSize: 13, fontWeight: FontWeight.bold, color: isFirstSetOverall ? Colors.grey.shade400 : textBlackColor)),
                    onPressed: isFirstSetOverall ? null : () { _saveSetDataToCubit(); widget.onRequestSetNavigation(next: false); },
                  ),
                  isLastSetOverall
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      label: Text(loc.currentSetDisplayButtonFinishWorkout, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () {
                        _saveSetDataToCubit();
                        widget.onCompleteWorkoutRequested();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    )
                  : TextButton(
                      child: Text(isLastSetOfCurrentExercise ? loc.currentSetDisplayButtonNextExercise : loc.currentSetDisplayButtonNextSet, style: const TextStyle(fontFamily: ibmPlexMonoFont, fontSize: 13, fontWeight: FontWeight.bold, color: textBlackColor)),
                      onPressed: () { _saveSetDataToCubit(); widget.onRequestSetNavigation(next: true); },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}