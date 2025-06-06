// lib/features/routines/presentation/screens/create_edit_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:muscle_up/l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _manageRoutineCubit.updateRoutineName(_nameController.text);
      _manageRoutineCubit.updateRoutineDescription(_descriptionController.text);
      _manageRoutineCubit.updateScheduledDays(_selectedDays);
      _manageRoutineCubit.saveRoutine();
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.createEditRoutineSnackbarFormErrors), backgroundColor: Colors.orangeAccent),
        );
    }
  }

  Future<void> _deleteRoutine() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.routineListItemDeleteConfirmTitle),
        content: Text(loc.routineListItemDeleteConfirmMessage(_nameController.text)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.routineListItemDeleteConfirmButtonCancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.routineListItemDeleteConfirmButtonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _manageRoutineCubit.deleteRoutine();
    }
  }

  Widget _buildExerciseItem(BuildContext context, RoutineExercise exercise, int index) {
    final loc = AppLocalizations.of(context)!;
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
              title: Text(loc.editExerciseDialogTitle(exercise.exerciseNameSnapshot)),
              content: Form(
                key: formKeyDialog,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: setsCtrl,
                    decoration: InputDecoration(labelText: '${loc.addExerciseDialogSetsLabel}*'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? loc.addExerciseDialogSetsErrorInvalid : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notesCtrl,
                    decoration: InputDecoration(labelText: loc.addExerciseDialogNotesLabel),
                    maxLines: 2,
                  ),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(loc.addExerciseDialogButtonCancel)),
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
                  child: Text(loc.editExerciseDialogButtonUpdate),
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
    final loc = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _manageRoutineCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_manageRoutineCubit.isEditingMode ? loc.createEditRoutineScreenTitleEdit : loc.createEditRoutineScreenTitleCreate),
          actions: [
            if (_manageRoutineCubit.isEditingMode)
              IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: _deleteRoutine, tooltip: loc.createEditRoutineTooltipDelete),
          ],
        ),
        body: BlocConsumer<ManageRoutineCubit, ManageRoutineState>(
          listener: (context, state) {
            if (state is ManageRoutineSuccess) {
              String statusMessage;
              if (state.message.contains("updated")) {
                statusMessage = loc.createEditRoutineStatusUpdated;
              } else if (state.message.contains("created")) {
                statusMessage = loc.createEditRoutineStatusCreated;
              } else if (state.message.contains("deleted")) {
                statusMessage = loc.createEditRoutineStatusDeleted;
              } else {
                statusMessage = loc.createEditRoutineSuccessMessage(state.message);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(statusMessage), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
              );
              Navigator.of(context).pop(true);
            } else if (state is ManageRoutineFailure) {
              String errorMessage;
              if (state.error.contains("name cannot be empty")) {
                errorMessage = loc.createEditRoutineErrorNameEmpty;
              } else if (state.error.contains("must have at least one exercise")) {
                errorMessage = loc.createEditRoutineErrorNoExercises;
              } else if (state.error.contains("Cannot delete a new or unsaved routine")) {
                errorMessage = loc.createEditRoutineErrorDeleteNew;
              } else {
                errorMessage = loc.createEditRoutineErrorMessage(state.error);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage), backgroundColor: Colors.red,  duration: const Duration(seconds: 3)),
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
              String loadingMessage = state.loadingMessage ?? '';
              if (loadingMessage.contains("Saving")) {
                loadingMessage = loc.createEditRoutineLoadingMessageSaving;
              } else if (loadingMessage.contains("Deleting")) {
                loadingMessage = loc.createEditRoutineLoadingMessageDeleting;
              }
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if(loadingMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(loadingMessage),
                  ]
                ],
              ));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: loc.createEditRoutineNameLabel),
                      validator: (value) => value == null || value.trim().isEmpty ? loc.createEditRoutineNameErrorEmpty : null,
                      onChanged: (_) => setState((){}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: loc.createEditRoutineDescriptionLabel),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(loc.createEditRoutineScheduledDaysLabel, style: Theme.of(context).textTheme.titleMedium),
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
                        Text(loc.createEditRoutineExercisesLabel(currentDisplayRoutine.exercises.length), style: Theme.of(context).textTheme.titleMedium),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(loc.createEditRoutineButtonAddExercise),
                          onPressed: () async {
                            final RoutineExercise? newExercise = await showAddExerciseToRoutineDialog(context);
                            if (newExercise != null) {
                              _manageRoutineCubit.addExerciseToRoutine(newExercise);
                               setState((){});
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (currentDisplayRoutine.exercises.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text(loc.createEditRoutineNoExercisesPlaceholder, style: const TextStyle(color: Colors.grey))),
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
          BlocBuilder<ManageRoutineCubit, ManageRoutineState>(
            builder: (context, state) {
              bool canSave = _manageRoutineCubit.currentRoutineSnapshot.name.trim().isNotEmpty &&
                             _manageRoutineCubit.currentRoutineSnapshot.exercises.isNotEmpty;
              
              if(state is ManageRoutineExercisesUpdated){
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
                            _manageRoutineCubit.isEditingMode ? loc.createEditRoutineButtonSaveChanges : loc.createEditRoutineButtonCreateRoutine,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}