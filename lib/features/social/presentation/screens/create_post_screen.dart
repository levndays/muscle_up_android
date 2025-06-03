// lib/features/social/presentation/screens/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/post.dart'; // For PostType
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/create_post_cubit.dart';
import 'dart:developer' as developer;
// NEW IMPORT
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/entities/predefined_exercise.dart'; // To select exercise for record
import '../../../exercise_explorer/presentation/screens/exercise_explorer_screen.dart'; // To select exercise for record
import '../../../routines/presentation/screens/user_routines_screen.dart'; // NEW IMPORT FOR ROUTINE SELECTION

class CreatePostScreen extends StatefulWidget {
  final UserRoutine? routineToShare;

  const CreatePostScreen({super.key, this.routineToShare});

  static Route<bool> route({UserRoutine? routineToShare}) { // Update route method
    return MaterialPageRoute<bool>(
      builder: (_) => CreatePostScreen(routineToShare: routineToShare),
    );
  }

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _areCommentsEnabled = true;
  PostType _selectedPostType = PostType.standard; // Default post type

  // Fields for Routine Share posts
  UserRoutine? _selectedRoutine; // NEW: holds the selected routine for sharing

  // Fields for Record Claim posts
  PredefinedExercise? _selectedExerciseForRecord;
  final TextEditingController _recordWeightController = TextEditingController();
  final TextEditingController _recordRepsController = TextEditingController();
  final TextEditingController _recordVideoUrlController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.routineToShare != null) {
      _selectedPostType = PostType.routineShare; // Automatically select RoutineShare if routine is passed
      _selectedRoutine = widget.routineToShare; // NEW: Initialize selected routine
      _textController.text = "Check out my new routine: ${widget.routineToShare!.name}!";
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _recordWeightController.dispose();
    _recordRepsController.dispose();
    _recordVideoUrlController.dispose();
    super.dispose();
  }

  // New: Method to build the post type selection widget
  Widget _buildPostTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton<PostType>(
        segments: const <ButtonSegment<PostType>>[
          ButtonSegment<PostType>(
            value: PostType.standard,
            label: Text('Standard'),
            icon: Icon(Icons.note),
          ),
          ButtonSegment<PostType>(
            value: PostType.routineShare,
            label: Text('Routine'),
            icon: Icon(Icons.share),
          ),
          ButtonSegment<PostType>(
            value: PostType.recordClaim,
            label: Text('Record'),
            icon: Icon(Icons.emoji_events),
          ),
        ],
        selected: <PostType>{_selectedPostType},
        onSelectionChanged: (Set<PostType> newSelection) {
          setState(() {
            _selectedPostType = newSelection.first;
            // Clear record claim fields if switching away from record type
            if (_selectedPostType != PostType.recordClaim) {
              _selectedExerciseForRecord = null;
              _recordWeightController.clear();
              _recordRepsController.clear();
              _recordVideoUrlController.clear();
            }
            // Clear routine share fields if switching away from routine type
            if (_selectedPostType != PostType.routineShare) {
              _selectedRoutine = null;
            }
            // If switching to routine share and no routine was initially passed,
            // prompt user to select one.
            if (_selectedPostType == PostType.routineShare && widget.routineToShare == null) {
              // The `_buildRoutineShareFields` will handle the selection UI.
            }
          });
        },
        showSelectedIcon: false, // For a cleaner look
      ),
    );
  }

  // NEW: Method to build routine share specific fields
  Widget _buildRoutineShareFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Routine to Share:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(
            _selectedRoutine?.name ?? 'Select Routine*',
            style: _selectedRoutine == null
                ? Theme.of(context).inputDecorationTheme.hintStyle
                : Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: _selectedRoutine != null
              ? Text('${_selectedRoutine!.exercises.length} exercises')
              : null,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            // NEW: Use UserRoutinesScreen.route with nullable return type
            final UserRoutine? selectedRoutine = await Navigator.of(context).push<UserRoutine?>(
              UserRoutinesScreen.route(isSelectionMode: true),
            );
            if (selectedRoutine != null) {
              setState(() {
                _selectedRoutine = selectedRoutine;
                if (_textController.text.trim().isEmpty || _textController.text.contains("Check out my new routine")) {
                  _textController.text = "Check out my new routine: ${_selectedRoutine!.name}!";
                }
              });
            }
          },
          shape: Theme.of(context).inputDecorationTheme.border, // Apply default input border style
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tileColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),
      ],
    );
  }


  // New: Method to build record claim specific fields
  Widget _buildRecordClaimFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Record Details:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(
            _selectedExerciseForRecord?.name ?? 'Select Exercise*',
            style: _selectedExerciseForRecord == null
                ? Theme.of(context).inputDecorationTheme.hintStyle
                : Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            final PredefinedExercise? selectedExercise = await Navigator.of(context).push<PredefinedExercise>(
              MaterialPageRoute(builder: (_) => const ExerciseExplorerScreen(isSelectionMode: true)),
            );
            if (selectedExercise != null) {
              setState(() {
                _selectedExerciseForRecord = selectedExercise;
              });
            }
          },
          shape: Theme.of(context).inputDecorationTheme.border, // Apply default input border style
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tileColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recordWeightController,
          decoration: const InputDecoration(labelText: 'Weight (kg)*'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Weight is required';
            final n = double.tryParse(value);
            if (n == null || n <= 0) return 'Invalid weight';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recordRepsController,
          decoration: const InputDecoration(labelText: 'Repetitions*'),
          keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Reps are required';
            final n = int.tryParse(value);
            if (n == null || n <= 0) return 'Invalid repetitions';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recordVideoUrlController,
          decoration: const InputDecoration(labelText: 'Video URL (optional)'),
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              // Check if parsing failed OR if it's not an absolute URI (e.g., just "myvideo.mp4")
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Enter a valid URL';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePostCubit(
        RepositoryProvider.of<PostRepository>(context),
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.routineToShare != null ? 'Share Routine' : 'Create Post'),
          actions: [
            BlocBuilder<CreatePostCubit, CreatePostState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is CreatePostLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            Map<String, dynamic>? recordDetails;
                            Map<String, dynamic>? routineSnapshot;
                            String? relatedRoutineId;

                            if (_selectedPostType == PostType.recordClaim) {
                              if (_selectedExerciseForRecord == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select an exercise for the record.'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              recordDetails = {
                                'exerciseId': _selectedExerciseForRecord!.id,
                                'exerciseName': _selectedExerciseForRecord!.name,
                                'weightKg': double.parse(_recordWeightController.text),
                                'reps': int.parse(_recordRepsController.text),
                                if (_recordVideoUrlController.text.isNotEmpty)
                                  'videoUrl': _recordVideoUrlController.text,
                              };
                            } else if (_selectedPostType == PostType.routineShare) {
                               if (_selectedRoutine == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a routine to share.'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              routineSnapshot = _selectedRoutine!.toMap();
                              relatedRoutineId = _selectedRoutine!.id;
                            }

                            context.read<CreatePostCubit>().submitPost(
                                  textContent: _textController.text,
                                  isCommentsEnabled: _areCommentsEnabled,
                                  type: _selectedPostType,
                                  relatedRoutineId: relatedRoutineId,
                                  routineSnapshot: routineSnapshot,
                                  recordDetails: recordDetails,
                                );
                          }
                        },
                  child: state is CreatePostLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state is CreatePostSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post published successfully!'), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop(true);
            } else if (state is CreatePostFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostTypeSelector(), // Always show selector
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          // Allow empty text if it's a routine or record share, assuming the snapshot provides content
                          if (_selectedPostType == PostType.routineShare || _selectedPostType == PostType.recordClaim) return null;
                          return 'Post content cannot be empty.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Comments'),
                      subtitle: Text(_areCommentsEnabled ? 'Users can comment on this post' : 'Comments are disabled'),
                      value: _areCommentsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _areCommentsEnabled = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    // Display routine details if sharing a routine
                    if (_selectedPostType == PostType.routineShare)
                      _buildRoutineShareFields(),
                    // NEW: Display record claim fields if selected
                    if (_selectedPostType == PostType.recordClaim)
                      _buildRecordClaimFields(),
                    const SizedBox(height: 20),
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