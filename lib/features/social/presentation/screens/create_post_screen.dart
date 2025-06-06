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
import 'package:muscle_up/l10n/app_localizations.dart';

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
        _recordVideoUrlController.text = post.recordDetails!['videoUrl'] as String? ?? ''; // Cast
         if (post.recordDetails!['exerciseId'] != null && post.recordDetails!['exerciseName'] != null) {
            // Reconstruct the localized maps for PredefinedExercise
            Map<String, String> nameMap = {'en': post.recordDetails!['exerciseName'] as String? ?? 'Unknown'};
            if(post.recordDetails!['localizedExerciseNames'] is Map) {
              nameMap = Map<String, String>.from(post.recordDetails!['localizedExerciseNames']);
            }

            _selectedExerciseForRecord = PredefinedExercise(
                id: post.recordDetails!['exerciseId'] as String,
                name: nameMap,
                normalizedName: (post.recordDetails!['exerciseName'] as String? ?? 'unknown').toLowerCase(),
                primaryMuscleGroup: {'en': post.recordDetails!['primaryMuscleGroup'] as String? ?? ''}, // Defaulting to 'en' map
                secondaryMuscleGroups: {'en': List<String>.from(post.recordDetails!['secondaryMuscleGroups'] as List<dynamic>? ?? [])},
                equipmentNeeded: {'en': List<String>.from(post.recordDetails!['equipmentNeeded'] as List<dynamic>? ?? [])},
                description: {'en': post.recordDetails!['description'] as String? ?? ''}, // Assuming description was stored as string
                difficultyLevel: post.recordDetails!['difficultyLevel'] as String? ?? '',
                tags: List<String>.from(post.recordDetails!['tags'] as List<dynamic>? ?? []));
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
    final loc = AppLocalizations.of(context)!;
    if (_isEditing) {
      String postTypeName;
      switch(_selectedPostType){
        case PostType.standard: postTypeName = loc.createPostSegmentStandard; break;
        case PostType.routineShare: postTypeName = loc.createPostSegmentRoutine; break;
        case PostType.recordClaim: postTypeName = loc.createPostSegmentRecord; break;
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(loc.createPostScreenLabelPostType(postTypeName.toUpperCase()), style: Theme.of(context).textTheme.titleMedium),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton<PostType>(
        segments: <ButtonSegment<PostType>>[
          ButtonSegment<PostType>(value: PostType.standard, label: Text(loc.createPostSegmentStandard), icon: const Icon(Icons.note_outlined)),
          ButtonSegment<PostType>(value: PostType.routineShare, label: Text(loc.createPostSegmentRoutine), icon: const Icon(Icons.share_outlined)),
          ButtonSegment<PostType>(value: PostType.recordClaim, label: Text(loc.createPostSegmentRecord), icon: const Icon(Icons.emoji_events_outlined)),
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
    final loc = AppLocalizations.of(context)!;
    if (_isEditing && _selectedPostType == PostType.routineShare) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(loc.createPostLabelSharedRoutine, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            title: Text(_selectedRoutine?.name ?? loc.createPostErrorRoutineUnavailable),
            subtitle: _selectedRoutine != null ? Text('${_selectedRoutine!.exercises.length}${loc.createPostRoutineExerciseCountSuffix}') : null,
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
        Text(loc.createPostLabelSharedRoutine, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(_selectedRoutine?.name ?? '${loc.createPostSegmentRoutine}*', style: _selectedRoutine == null ? Theme.of(context).inputDecorationTheme.hintStyle : Theme.of(context).textTheme.bodyLarge),
          subtitle: _selectedRoutine != null ? Text('${_selectedRoutine!.exercises.length}${loc.createPostRoutineExerciseCountSuffix}') : null,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            final UserRoutine? selectedRoutineFromList = await Navigator.of(context).push<UserRoutine?>(UserRoutinesScreen.route(isSelectionMode: true));
            if (selectedRoutineFromList != null) {
              setState(() {
                _selectedRoutine = selectedRoutineFromList;
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
     final loc = AppLocalizations.of(context)!;
     if (_isEditing && _selectedPostType == PostType.recordClaim) {
        return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const SizedBox(height: 16),
           Text(loc.createPostLabelRecordDetailsReadOnly, style: Theme.of(context).textTheme.titleMedium),
           const SizedBox(height: 8),
           ListTile(title: Text('${loc.createPostLabelRecordExercise}${_selectedExerciseForRecord?.getLocalizedName(context) ?? 'N/A'}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           const SizedBox(height: 8),
           ListTile(title: Text('${loc.createPostLabelRecordWeight}${_recordWeightController.text}${loc.createPostUnitKgSuffix}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           const SizedBox(height: 8),
           ListTile(title: Text('${loc.createPostLabelRecordReps}${_recordRepsController.text}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           if (_recordVideoUrlController.text.isNotEmpty) ...[
             const SizedBox(height: 8),
             ListTile(title: Text('${loc.createPostLabelRecordVideo}${_recordVideoUrlController.text}'), tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
           ]
         ],
        );
     }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(loc.createPostLabelRecordDetails, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(_selectedExerciseForRecord?.getLocalizedName(context) ?? loc.createPostHintSelectExercise, style: _selectedExerciseForRecord == null ? Theme.of(context).inputDecorationTheme.hintStyle : Theme.of(context).textTheme.bodyLarge),
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
        TextFormField(controller: _recordWeightController, decoration: InputDecoration(labelText: loc.createPostHintRecordWeight), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false), validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) ? loc.createPostErrorRecordWeightInvalid : null),
        const SizedBox(height: 16),
        TextFormField(controller: _recordRepsController, decoration: InputDecoration(labelText: loc.createPostHintRecordReps), keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false), validator: (v) => (v == null || v.trim().isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? loc.createPostErrorRecordRepsInvalid : null),
        const SizedBox(height: 16),
        TextFormField(controller: _recordVideoUrlController, decoration: InputDecoration(labelText: loc.createPostHintRecordVideoUrl), keyboardType: TextInputType.url, validator: (v) => (v != null && v.isNotEmpty && (Uri.tryParse(v) == null || !Uri.tryParse(v)!.hasAbsolutePath)) ? loc.createPostErrorRecordVideoUrlInvalid : null),
      ],
    );
  }

 Widget _buildMediaPicker() {
    final loc = AppLocalizations.of(context)!;
    if (_selectedPostType != PostType.standard && _isEditing) {
      if (_existingMediaUrl != null && _existingMediaUrl!.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.createPostLabelAttachImageOptionalReplace, style: Theme.of(context).textTheme.titleMedium), // Read-only indication is removed, action is via close button
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
        Text(_isEditing && _existingMediaUrl != null ? loc.createPostLabelAttachImageOptionalReplace : loc.createPostLabelAttachImageOptional, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_selectedMediaImage != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedMediaImage!, height: 180, width: double.infinity, fit: BoxFit.cover)),
              IconButton(icon: CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)), onPressed: () => setState(() { _selectedMediaImage = null; _removeExistingMedia = _existingMediaUrl != null; }), tooltip: loc.createPostTooltipRemoveImage),
            ],
          )
        else if (_existingMediaUrl != null && !_removeExistingMedia)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_existingMediaUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)),
              IconButton(icon: CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)), onPressed: () => setState(() { _removeExistingMedia = true; }), tooltip: loc.createPostTooltipRemoveExistingImage),
            ],
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(loc.createPostButtonAddImage),
            onPressed: _pickMediaImage,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), textStyle: const TextStyle(fontSize: 15)),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CreatePostCubit(
        RepositoryProvider.of<PostRepository>(context),
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
        postToEdit: widget.postToEdit,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? loc.createPostAppBarTitleEdit : (widget.routineToShare != null ? loc.createPostAppBarTitleShareRoutine : loc.createPostAppBarTitleCreate)),
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
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.createPostErrorRecordWeightInvalid), backgroundColor: Colors.red)); return; // Placeholder for actual error
                              }
                              recordDetails = {
                                'exerciseId': _selectedExerciseForRecord!.id,
                                'exerciseName': _selectedExerciseForRecord!.nameFallback, // Storing English/fallback name
                                'localizedExerciseNames': _selectedExerciseForRecord!.name, // Storing the map
                                'weightKg': double.parse(_recordWeightController.text),
                                'reps': int.parse(_recordRepsController.text),
                                if (_recordVideoUrlController.text.isNotEmpty) 'videoUrl': _recordVideoUrlController.text,
                                // Include other non-localized fields from PredefinedExercise if needed by functions
                                'primaryMuscleGroup': _selectedExerciseForRecord!.primaryMuscleGroup['en'], // Example
                                'secondaryMuscleGroups': _selectedExerciseForRecord!.secondaryMuscleGroups['en'], // Example
                                'equipmentNeeded': _selectedExerciseForRecord!.equipmentNeeded['en'], // Example
                              };
                            } else if (_selectedPostType == PostType.routineShare && !_isEditing) {
                               if (_selectedRoutine == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a routine.'), backgroundColor: Colors.red)); return;
                              }
                              routineSnapshot = _selectedRoutine!.toMap(); // This already contains localized exerciseNameSnapshot
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
                      : Text(_isEditing ? loc.createPostButtonSaveChanges : loc.createPostButtonPublish, style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state is CreatePostSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.createPostSnackbarSuccess(state.isUpdate ? loc.createPostStatusUpdated : loc.createPostStatusPublished)), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop(true);
            } else if (state is CreatePostFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.createPostSnackbarError(state.error)), backgroundColor: Colors.red),
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
                          decoration: InputDecoration(hintText: loc.createPostHintTextContent, border: const OutlineInputBorder()),
                          maxLines: 8,
                          maxLength: 500,
                           validator: (value) {
                            if (_isEditing && widget.postToEdit?.type == PostType.standard) { 
                                if ((value == null || value.trim().isEmpty) && _selectedMediaImage == null && (_existingMediaUrl == null || _removeExistingMedia)) {
                                    return loc.createPostErrorContentOrImageRequired;
                                }
                                return null;
                            }
                            if (value == null || value.trim().isEmpty) {
                              if (_selectedPostType == PostType.standard && _selectedMediaImage == null) {
                                return loc.createPostErrorContentOrImageRequired;
                              }
                              if (_selectedPostType != PostType.standard) return null;
                            }
                            return null;
                          },
                        ),
                        if (_selectedPostType == PostType.standard || (_isEditing && widget.postToEdit?.type == PostType.standard))
                          _buildMediaPicker(),
                        const SizedBox(height: 16),
                        if (!_isEditing || (_isEditing && widget.postToEdit?.type == PostType.standard))
                          SwitchListTile(
                            title: Text(loc.createPostToggleEnableComments),
                            subtitle: Text(_areCommentsEnabled ? loc.createPostCommentsEnabledSubtitle : loc.createPostCommentsDisabledSubtitle),
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
  dynamic operator [](Object field) => _data[field as String]; 

  @override
  SnapshotMetadata get metadata => throw UnimplementedError('metadata not implemented for _DummyDocumentSnapshot');

  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError('reference not implemented for _DummyDocumentSnapshot');
}