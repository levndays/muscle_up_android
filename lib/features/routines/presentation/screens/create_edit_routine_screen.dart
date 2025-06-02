// lib/features/routines/presentation/screens/create_edit_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import '../cubit/manage_routine_cubit.dart';
import '../widgets/add_exercise_to_routine_dialog.dart';

class CreateEditRoutineScreen extends StatefulWidget {
  final UserRoutine? routineToEdit;

  const CreateEditRoutineScreen({super.key, this.routineToEdit});

  @override
  State<CreateEditRoutineScreen> createState() => _CreateEditRoutineScreenState();
}

class _CreateEditRoutineScreenState extends State<CreateEditRoutineScreen> {
  late final ManageRoutineCubit _manageRoutineCubit;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _selectedDays = [];

  final List<String> _availableDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    _manageRoutineCubit = ManageRoutineCubit(
      RepositoryProvider.of<RoutineRepository>(context),
      FirebaseAuth.instance,
      initialRoutine: widget.routineToEdit,
    );

    if (widget.routineToEdit != null) {
      _nameController.text = widget.routineToEdit!.name;
      _descriptionController.text = widget.routineToEdit!.description ?? '';
      _selectedDays = List<String>.from(widget.routineToEdit!.scheduledDays);
    }

    _nameController.addListener(() {
      _manageRoutineCubit.updateRoutineName(_nameController.text);
    });
    _descriptionController.addListener(() {
      _manageRoutineCubit.updateRoutineDescription(_descriptionController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _manageRoutineCubit.close();
    super.dispose();
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      _manageRoutineCubit.updateRoutineName(_nameController.text);
      _manageRoutineCubit.updateRoutineDescription(_descriptionController.text);
      _manageRoutineCubit.updateScheduledDays(_selectedDays);
      _manageRoutineCubit.saveRoutine();
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.'), backgroundColor: Colors.orangeAccent),
      );
    }
  }

  Future<void> _deleteRoutine() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${_nameController.text}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _manageRoutineCubit.deleteRoutine();
    }
  }

  Widget _buildExerciseItem(BuildContext context, RoutineExercise exercise, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(exercise.exerciseNameSnapshot),
        subtitle: Text('${exercise.numberOfSets} sets${exercise.notes != null && exercise.notes!.isNotEmpty ? " - ${exercise.notes}" : ""}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            _manageRoutineCubit.removeExerciseFromRoutine(index);
          },
        ),
        onTap: () async {
          final TextEditingController setsCtrl = TextEditingController(text: exercise.numberOfSets.toString());
          final TextEditingController notesCtrl = TextEditingController(text: exercise.notes ?? '');
          final formKeyDialog = GlobalKey<FormState>();

          final RoutineExercise? updatedExerciseDetails = await showDialog<RoutineExercise>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: Text('Edit "${exercise.exerciseNameSnapshot}"'),
              content: Form(
                key: formKeyDialog,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: setsCtrl,
                    decoration: const InputDecoration(labelText: 'Number of Sets*'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? 'Invalid sets count' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 2,
                  ),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (formKeyDialog.currentState!.validate()) {
                       Navigator.pop(dialogCtx, RoutineExercise(
                        predefinedExerciseId: exercise.predefinedExerciseId,
                        exerciseNameSnapshot: exercise.exerciseNameSnapshot,
                        numberOfSets: int.parse(setsCtrl.text),
                        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                      ));
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          );
          if (updatedExerciseDetails != null) {
            _manageRoutineCubit.updateExerciseInRoutine(index, updatedExerciseDetails);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _manageRoutineCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_manageRoutineCubit.isEditingMode ? 'Edit Routine' : 'Create Routine'),
          actions: [
            if (_manageRoutineCubit.isEditingMode)
              IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: _deleteRoutine, tooltip: 'Delete Routine'),
            // Кнопка "Зберегти" видалена з AppBar
          ],
        ),
        body: BlocConsumer<ManageRoutineCubit, ManageRoutineState>(
          listener: (context, state) {
            if (state is ManageRoutineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
              );
              Navigator.of(context).pop(true);
            } else if (state is ManageRoutineFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red,  duration: const Duration(seconds: 3)),
              );
            }
          },
          builder: (context, state) {
            UserRoutine currentDisplayRoutine = _manageRoutineCubit.currentRoutineSnapshot;
            if (state is ManageRoutineExercisesUpdated) {
              currentDisplayRoutine = state.updatedRoutine;
            } else if (state is ManageRoutineInitial) {
              currentDisplayRoutine = state.routine;
            } else if (state is ManageRoutineSuccess) {
              currentDisplayRoutine = state.savedRoutine;
            }
            
            bool canSave = currentDisplayRoutine.name.trim().isNotEmpty && currentDisplayRoutine.exercises.isNotEmpty;

            if (state is ManageRoutineLoading) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if(state.loadingMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(state.loadingMessage!),
                  ]
                ],
              ));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Додано відступ знизу для кнопки
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Routine Name*'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Name cannot be empty' : null,
                      onChanged: (_) => setState((){}), // Для оновлення стану кнопки
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Text('Scheduled Days:', style: Theme.of(context).textTheme.titleMedium),
                    Wrap(
                      spacing: 8.0,
                      children: _availableDays.map((day) {
                        final isSelected = _selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                              _manageRoutineCubit.updateScheduledDays(List.from(_selectedDays));
                            });
                          },
                          selectedColor: Theme.of(context).primaryColorLight,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Exercises (${currentDisplayRoutine.exercises.length}):', style: Theme.of(context).textTheme.titleMedium),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add'),
                          onPressed: () async {
                            final RoutineExercise? newExercise = await showAddExerciseToRoutineDialog(context);
                            if (newExercise != null) {
                              _manageRoutineCubit.addExerciseToRoutine(newExercise);
                               setState((){}); // Для оновлення стану кнопки
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (currentDisplayRoutine.exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text('No exercises added yet. Tap "Add" to begin.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentDisplayRoutine.exercises.length,
                        itemBuilder: (ctx, index) {
                          return _buildExerciseItem(context, currentDisplayRoutine.exercises[index], index);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        persistentFooterButtons: [
          BlocBuilder<ManageRoutineCubit, ManageRoutineState>( // Обертаємо кнопку в BlocBuilder
            builder: (context, state) {
              bool canSave = _manageRoutineCubit.currentRoutineSnapshot.name.trim().isNotEmpty &&
                             _manageRoutineCubit.currentRoutineSnapshot.exercises.isNotEmpty;
              
              if(state is ManageRoutineExercisesUpdated){ // Додатково перевіряємо зі стану, якщо він оновився
                  canSave = state.updatedRoutine.name.trim().isNotEmpty && state.updatedRoutine.exercises.isNotEmpty;
              } else if (state is ManageRoutineInitial) {
                  canSave = state.routine.name.trim().isNotEmpty && state.routine.exercises.isNotEmpty;
              }


              if (canSave) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: (state is ManageRoutineLoading) ? null : _saveRoutine,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: (state is ManageRoutineLoading)
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            _manageRoutineCubit.isEditingMode ? 'Save Changes' : 'Create Routine',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                );
              }
              return const SizedBox.shrink(); // Порожній віджет, якщо кнопка невидима
            },
          ),
        ],
      ),
    );
  }
}