// lib/features/social/presentation/screens/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/post.dart'; 
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/create_post_cubit.dart';
import 'dart:developer' as developer;
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../../../exercise_explorer/presentation/screens/exercise_explorer_screen.dart';
import '../../../routines/presentation/screens/user_routines_screen.dart';
import '../../../../core/services/image_picker_service.dart';

class CreatePostScreen extends StatefulWidget {
  final UserRoutine? routineToShare;
  final Post? postToEdit;

  const CreatePostScreen({super.key, this.routineToShare, this.postToEdit});

  static Route<bool> route({UserRoutine? routineToShare, Post? postToEdit}) { 
    return MaterialPageRoute<bool>(
      builder: (_) => CreatePostScreen(routineToShare: routineToShare, postToEdit: postToEdit),
    );
  }

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _areCommentsEnabled = true;
  PostType _selectedPostType = PostType.standard;

  UserRoutine? _selectedRoutine;

  PredefinedExercise? _selectedExerciseForRecord;
  final TextEditingController _recordWeightController = TextEditingController();
  final TextEditingController _recordRepsController = TextEditingController();
  final TextEditingController _recordVideoUrlController = TextEditingController();

  File? _selectedMediaImage;
  String? _existingMediaUrl;
  bool _removeExistingMedia = false;

  bool get _isEditing => widget.postToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      final post = widget.postToEdit!;
      _selectedPostType = post.type;
      _textController.text = post.textContent;
      _areCommentsEnabled = post.isCommentsEnabled;
      _existingMediaUrl = post.mediaUrl;

      if (post.type == PostType.routineShare && post.routineSnapshot != null) {
        _selectedRoutine = UserRoutine.fromFirestore(
           _DummyDocumentSnapshot(post.routineSnapshot!, post.relatedRoutineId ?? 'temp_edit_id')
        );
      } else if (post.type == PostType.recordClaim && post.recordDetails != null) {
        _recordWeightController.text = post.recordDetails!['weightKg']?.toString() ?? '';
        _recordRepsController.text = post.recordDetails!['reps']?.toString() ?? '';
        _recordVideoUrlController.text = post.recordDetails!['videoUrl'] ?? '';
         if (post.recordDetails!['exerciseName'] != null && post.recordDetails!['exerciseId'] != null) {
            _selectedExerciseForRecord = PredefinedExercise(
                id: post.recordDetails!['exerciseId'],
                name: post.recordDetails!['exerciseName'],
                normalizedName: post.recordDetails!['exerciseName'].toLowerCase(),
                primaryMuscleGroup: post.recordDetails!['primaryMuscleGroup'] ?? '',
                secondaryMuscleGroups: List<String>.from(post.recordDetails!['secondaryMuscleGroups'] ?? []),
                equipmentNeeded: List<String>.from(post.recordDetails!['equipmentNeeded'] ?? []),
                description: '',
                difficultyLevel: '',
                tags: []);
        }
      }
    } else if (widget.routineToShare != null) {
      _selectedPostType = PostType.routineShare;
      _selectedRoutine = widget.routineToShare;
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

  Future<void> _pickMediaImage() async {
    final ImagePickerService imagePickerService = ImagePickerService();
    final File? image = await imagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedMediaImage = image;
        _existingMediaUrl = null; 
        _removeExistingMedia = false;
      });
    }
  }

  Widget _buildPostTypeSelector() {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text("Post Type: ${_selectedPostType.name.toUpperCase()}", style: Theme.of(context).textTheme.titleMedium),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton<PostType>(
        segments: const <ButtonSegment<PostType>>[
          ButtonSegment<PostType>(value: PostType.standard, label: Text('Standard'), icon: Icon(Icons.note_outlined)),
          ButtonSegment<PostType>(value: PostType.routineShare, label: Text('Routine'), icon: Icon(Icons.share_outlined)),
          ButtonSegment<PostType>(value: PostType.recordClaim, label: Text('Record'), icon: Icon(Icons.emoji_events_outlined)),
        ],
        selected: <PostType>{_selectedPostType},
        onSelectionChanged: (Set<PostType> newSelection) {
          setState(() {
            _selectedPostType = newSelection.first;
             _selectedRoutine = null;
            _selectedExerciseForRecord = null;
            _recordWeightController.clear();
            _recordRepsController.clear();
            _recordVideoUrlController.clear();
            _selectedMediaImage = null;
            _removeExistingMedia = false;
          });
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          selectedForegroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildRoutineShareFields() {
    if (_isEditing && _selectedPostType == PostType.routineShare) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Shared Routine:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            title: Text(_selectedRoutine?.name ?? 'Routine details unavailable'),
            subtitle: _selectedRoutine != null ? Text('${_selectedRoutine!.exercises.length} exercises') : null,
            leading: const Icon(Icons.list_alt_rounded),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: Theme.of(context).inputDecorationTheme.border,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Routine to Share:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(_selectedRoutine?.name ?? 'Select Routine*', style: _selectedRoutine == null ? Theme.of(context).inputDecorationTheme.hintStyle : Theme.of(context).textTheme.bodyLarge),
          subtitle: _selectedRoutine != null ? Text('${_selectedRoutine!.exercises.length} exercises') : null,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            final UserRoutine? selectedRoutine = await Navigator.of(context).push<UserRoutine?>(UserRoutinesScreen.route(isSelectionMode: true));
            if (selectedRoutine != null) {
              setState(() {
                _selectedRoutine = selectedRoutine;
                if (_textController.text.trim().isEmpty || _textController.text.contains("Check out my new routine")) {
                  _textController.text = "Check out my new routine: ${_selectedRoutine!.name}!";
                }
              });
            }
          },
          shape: Theme.of(context).inputDecorationTheme.border,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tileColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),
      ],
    );
  }

  Widget _buildRecordClaimFields() {
     if (_isEditing && _selectedPostType == PostType.recordClaim) {
        return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const SizedBox(height: 16),
           Text('Record Details (Read-only):', style: Theme.of(context).textTheme.titleMedium),
           const SizedBox(height: 8),
           ListTile(title: Text('Exercise: ${_selectedExerciseForRecord?.name ?? 'N/A'}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           const SizedBox(height: 8),
           ListTile(title: Text('Weight: ${_recordWeightController.text} kg'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           const SizedBox(height: 8),
           ListTile(title: Text('Reps: ${_recordRepsController.text}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           if (_recordVideoUrlController.text.isNotEmpty) ...[
             const SizedBox(height: 8),
             ListTile(title: Text('Video: ${_recordVideoUrlController.text}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           ]
         ],
        );
     }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Record Details:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(_selectedExerciseForRecord?.name ?? 'Select Exercise*', style: _selectedExerciseForRecord == null ? Theme.of(context).inputDecorationTheme.hintStyle : Theme.of(context).textTheme.bodyLarge),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            final PredefinedExercise? selectedExercise = await Navigator.of(context).push<PredefinedExercise>(MaterialPageRoute(builder: (_) => const ExerciseExplorerScreen(isSelectionMode: true)));
            if (selectedExercise != null) setState(() => _selectedExerciseForRecord = selectedExercise);
          },
          shape: Theme.of(context).inputDecorationTheme.border,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tileColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _recordWeightController, decoration: const InputDecoration(labelText: 'Weight (kg)*'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false), validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Invalid weight' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _recordRepsController, decoration: const InputDecoration(labelText: 'Repetitions*'), keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false), validator: (v) => (v == null || v.trim().isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? 'Invalid repetitions' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _recordVideoUrlController, decoration: const InputDecoration(labelText: 'Video URL (optional)'), keyboardType: TextInputType.url, validator: (v) => (v != null && v.isNotEmpty && (Uri.tryParse(v) == null || !Uri.tryParse(v)!.hasAbsolutePath)) ? 'Enter a valid URL' : null),
      ],
    );
  }

 Widget _buildMediaPicker() {
    if (_selectedPostType != PostType.standard && _isEditing) {
      if (_existingMediaUrl != null && _existingMediaUrl!.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attached Media (Read-only):', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_existingMediaUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Attach Image${_isEditing && _existingMediaUrl != null ? " (Optional - Replaces Existing)" : " (Optional)"}:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_selectedMediaImage != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedMediaImage!, height: 180, width: double.infinity, fit: BoxFit.cover)),
              IconButton(icon: CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)), onPressed: () => setState(() { _selectedMediaImage = null; _removeExistingMedia = _existingMediaUrl != null; }), tooltip: 'Remove Image'),
            ],
          )
        else if (_existingMediaUrl != null && !_removeExistingMedia)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_existingMediaUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)),
              IconButton(icon: CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)), onPressed: () => setState(() { _removeExistingMedia = true; }), tooltip: 'Remove Existing Image'),
            ],
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add Image'),
            onPressed: _pickMediaImage,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), textStyle: const TextStyle(fontSize: 15)),
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
        postToEdit: widget.postToEdit,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Post' : (widget.routineToShare != null ? 'Share Routine' : 'Create Post')),
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

                            if (_selectedPostType == PostType.recordClaim && !_isEditing) {
                              if (_selectedExerciseForRecord == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an exercise.'), backgroundColor: Colors.red)); return;
                              }
                              recordDetails = { 'exerciseId': _selectedExerciseForRecord!.id, 'exerciseName': _selectedExerciseForRecord!.name, 'weightKg': double.parse(_recordWeightController.text), 'reps': int.parse(_recordRepsController.text), if (_recordVideoUrlController.text.isNotEmpty) 'videoUrl': _recordVideoUrlController.text };
                            } else if (_selectedPostType == PostType.routineShare && !_isEditing) {
                               if (_selectedRoutine == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a routine.'), backgroundColor: Colors.red)); return;
                              }
                              routineSnapshot = _selectedRoutine!.toMap();
                              relatedRoutineId = _selectedRoutine!.id;
                            }
                            
                            context.read<CreatePostCubit>().submitPost(
                                  textContent: _textController.text,
                                  mediaImageFile: _selectedMediaImage,
                                  removeExistingMedia: _removeExistingMedia,
                                  type: _selectedPostType, 
                                  isCommentsEnabled: _areCommentsEnabled,
                                  relatedRoutineId: _isEditing ? widget.postToEdit?.relatedRoutineId : relatedRoutineId,
                                  routineSnapshot: _isEditing ? widget.postToEdit?.routineSnapshot : routineSnapshot,
                                  recordDetails: _isEditing ? widget.postToEdit?.recordDetails : recordDetails,
                                );
                          }
                        },
                  child: state is CreatePostLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEditing ? 'Save Changes' : 'Publish', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state is CreatePostSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Post ${state.isUpdate ? "updated" : "published"} successfully!'), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop(true);
            } else if (state is CreatePostFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            bool showLoadingOverlay = state is CreatePostLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostTypeSelector(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _textController,
                          decoration: const InputDecoration(hintText: 'What\'s on your mind?', border: OutlineInputBorder()),
                          maxLines: 8,
                          maxLength: 500,
                           validator: (value) {
                            if (_isEditing && widget.postToEdit?.type == PostType.standard) { // При редагуванні стандартного поста, текст може бути пустим, якщо є медіа
                                if ((value == null || value.trim().isEmpty) && _selectedMediaImage == null && (_existingMediaUrl == null || _removeExistingMedia)) {
                                    return 'Post content or image is required.';
                                }
                                return null;
                            }
                            // Для нових постів
                            if (value == null || value.trim().isEmpty) {
                              if (_selectedPostType == PostType.standard && _selectedMediaImage == null) {
                                return 'Post content or image is required.';
                              }
                              if (_selectedPostType != PostType.standard) return null; // Для routine/record текст не обов'язковий
                            }
                            return null;
                          },
                        ),
                        if (_selectedPostType == PostType.standard || (_isEditing && widget.postToEdit?.type == PostType.standard))
                          _buildMediaPicker(),
                        const SizedBox(height: 16),
                        if (!_isEditing || (_isEditing && widget.postToEdit?.type == PostType.standard))
                          SwitchListTile(
                            title: const Text('Enable Comments'),
                            subtitle: Text(_areCommentsEnabled ? 'Users can comment on this post' : 'Comments are disabled'),
                            value: _areCommentsEnabled,
                            onChanged: (bool value) => setState(() => _areCommentsEnabled = value),
                            activeColor: Theme.of(context).colorScheme.primary,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        if (_selectedPostType == PostType.routineShare)
                          _buildRoutineShareFields(),
                        if (_selectedPostType == PostType.recordClaim)
                          _buildRecordClaimFields(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (showLoadingOverlay)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          if (state is CreatePostLoading && state.loadingMessage != null)
                            Text(state.loadingMessage!, style: const TextStyle(color: Colors.white, backgroundColor: Colors.black54)),
                        ],
                      )
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class _DummyDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  @override
  final String id;

  _DummyDocumentSnapshot(this._data, this.id);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;
  
  @override
  dynamic get(Object field) => _data[field];

  @override
  dynamic operator [](Object field) => _data[field as String]; // ВИПРАВЛЕНО ТУТ

  @override
  SnapshotMetadata get metadata => throw UnimplementedError('metadata not implemented for _DummyDocumentSnapshot');

  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError('reference not implemented for _DummyDocumentSnapshot');
}