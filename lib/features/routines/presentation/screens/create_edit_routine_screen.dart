// lib/features/routines/presentation/screens/create_edit_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // для доступу до репо та auth
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart'; // для доступу до репо
import '../cubit/manage_routine_cubit.dart';
import '../cubit/user_routines_cubit.dart'; // для оновлення списку рутин
import '../widgets/add_exercise_to_routine_dialog.dart'; // Діалог, який ми щойно створили

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
  List<String> _selectedDays = []; // Для вибору днів тижня

  final List<String> _availableDays = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
  ];

  @override
  void initState() {
    super.initState();
    _manageRoutineCubit = ManageRoutineCubit(
      RepositoryProvider.of<RoutineRepository>(context),
      FirebaseAuth.instance, // Передаємо FirebaseAuth
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
      // Переконуємось, що останні зміни з контролерів передані в кубіт
      _manageRoutineCubit.updateRoutineName(_nameController.text);
      _manageRoutineCubit.updateRoutineDescription(_descriptionController.text);
      _manageRoutineCubit.updateScheduledDays(_selectedDays);
      
      _manageRoutineCubit.saveRoutine();
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
        subtitle: Text('${exercise.numberOfSets} sets'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            _manageRoutineCubit.removeExerciseFromRoutine(index);
          },
        ),
        onTap: () async {
           // TODO: Редагування вправи в рутині (наприклад, зміна кількості підходів)
          // Можна відкрити діалог схожий на той, що використовується для додавання,
          // але з попередньо заповненими даними.
          final TextEditingController setsCtrl = TextEditingController(text: exercise.numberOfSets.toString());
          final TextEditingController notesCtrl = TextEditingController(text: exercise.notes ?? '');
          final formKey = GlobalKey<FormState>();

          final RoutineExercise? updatedExerciseDetails = await showDialog<RoutineExercise>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: Text('Edit "${exercise.exerciseNameSnapshot}"'),
              content: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: setsCtrl,
                    decoration: const InputDecoration(labelText: 'Number of Sets'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? 'Invalid sets' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
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
          title: Text(widget.routineToEdit == null ? 'Create Routine' : 'Edit Routine'),
          actions: [
            if (widget.routineToEdit != null)
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: _deleteRoutine,
                tooltip: 'Delete Routine',
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRoutine,
              tooltip: 'Save Routine',
            ),
          ],
        ),
        body: BlocConsumer<ManageRoutineCubit, ManageRoutineState>(
          listener: (context, state) {
            if (state is ManageRoutineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              // Оновлюємо список рутин на попередньому екрані
              context.read<UserRoutinesCubit>().routineAddedOrUpdated(state.savedRoutine);

              Navigator.of(context).pop(); // Повертаємось назад після успіху
            } else if (state is ManageRoutineFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            UserRoutine currentDisplayRoutine = _manageRoutineCubit.currentRoutineSnapshot;
            if (state is ManageRoutineExercisesUpdated) { // Оновлюємо відображення, якщо вправи змінились
              currentDisplayRoutine = state.updatedRoutine;
            } else if (state is ManageRoutineInitial) {
              currentDisplayRoutine = state.routine;
            }


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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Routine Name'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Name cannot be empty' : null,
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
                              // Оновлюємо кубіт, якщо потрібно, або перед збереженням
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
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (currentDisplayRoutine.exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: Text('No exercises added yet. Tap "Add" to begin.')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Для списку всередині SingleChildScrollView
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
      ),
    );
  }
}