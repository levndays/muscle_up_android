// lib/features/profile_setup/presentation/screens/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart'; // NEW: Added missing import
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'dart:io'; 

import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/profile_setup_cubit.dart';
import '../../../../home_page.dart'; 
import '../../../profile/presentation/cubit/user_profile_cubit.dart' as global_user_profile_cubit;
import '../../../../core/services/image_picker_service.dart'; 
import 'package:muscle_up/l10n/app_localizations.dart'; 
import '../../../../widgets/fullscreen_image_viewer.dart';

const String _genderKeyMale = 'male';
const String _genderKeyFemale = 'female';
const String _genderKeyOther = 'other';
const String _genderKeyPreferNotToSay = 'prefer_not_to_say';


class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? userProfileToEdit; 

  const ProfileSetupScreen({super.key, this.userProfileToEdit});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  String? _selectedFitnessGoal;
  String? _selectedActivityLevel;

  late ProfileSetupCubit _profileSetupCubit;
  bool _isEditingMode = false; 
  File? _selectedAvatarImage; 
  String? _currentAvatarUrl; 

  @override
  void initState() {
    super.initState();
    developer.log("ProfileSetupScreen initState. Editing: ${widget.userProfileToEdit != null}", name: "ProfileSetupScreen");
    _isEditingMode = widget.userProfileToEdit != null;

    _profileSetupCubit = ProfileSetupCubit(
      RepositoryProvider.of<UserProfileRepository>(context),
      RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
      initialProfile: widget.userProfileToEdit, 
    );
    
    if (_isEditingMode && widget.userProfileToEdit != null) {
      final profile = widget.userProfileToEdit!;
      _usernameController.text = profile.username ?? '';
      _displayNameController.text = profile.displayName ?? '';
      _heightController.text = profile.heightCm?.toStringAsFixed(0) ?? '';
      _weightController.text = profile.weightKg?.toStringAsFixed(1) ?? '';
      _selectedGender = _isValidGenderKey(profile.gender) ? profile.gender : null;
      _selectedDateOfBirth = profile.dateOfBirth?.toDate();
      _selectedFitnessGoal = profile.fitnessGoal;
      _selectedActivityLevel = profile.activityLevel;
      _currentAvatarUrl = profile.profilePictureUrl; 
    } else {
      final currentUser = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser;
      if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
        _displayNameController.text = currentUser.displayName!;
      } else if (currentUser?.email != null && currentUser!.email!.contains('@')) {
         _displayNameController.text = currentUser.email!.split('@').first;
      }
       _currentAvatarUrl = currentUser?.photoURL; 
    }

    _usernameController.addListener(() {
      _profileSetupCubit.updateField(username: _usernameController.text.trim());
    });
    _displayNameController.addListener(() {
      _profileSetupCubit.updateField(displayName: _displayNameController.text.trim());
    });
     _heightController.addListener(() {
      _profileSetupCubit.updateField(heightCm: double.tryParse(_heightController.text));
    });
    _weightController.addListener(() {
      _profileSetupCubit.updateField(weightKg: double.tryParse(_weightController.text));
    });
  }

  bool _isValidGenderKey(String? key) {
    if (key == null) return false;
    return [_genderKeyMale, _genderKeyFemale, _genderKeyOther, _genderKeyPreferNotToSay].contains(key);
  }

  @override
  void dispose() {
    developer.log("ProfileSetupScreen dispose", name: "ProfileSetupScreen");
    _usernameController.dispose();
    _displayNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _profileSetupCubit.close();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: loc.profileSetupDobDatePickerHelpText,
      builder: (context, child) { 
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary, 
                  onPrimary: Colors.white, 
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, 
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      developer.log("Date selected: $picked", name: "ProfileSetupScreen");
      setState(() {
        _selectedDateOfBirth = picked;
      });
      _profileSetupCubit.updateField(dateOfBirth: Timestamp.fromDate(picked));
    }
  }

  Future<void> _pickAvatarImage() async {
    final ImagePickerService imagePickerService = ImagePickerService();
    final File? image = await imagePickerService.pickAndCropImage(
      source: ImageSource.gallery,
      cropStyle: CropStyle.circle,
    );
    if (image != null) {
      setState(() {
        _selectedAvatarImage = image;
      });
    }
  }

  void _handleSaveProfile() {
    final loc = AppLocalizations.of(context)!;
    developer.log("Save Profile button pressed. IsEditing: $_isEditingMode", name: "ProfileSetupScreen");
    if (_formKey.currentState?.validate() ?? false) {
      developer.log("Form is valid, calling cubit.saveProfile()", name: "ProfileSetupScreen");
      _profileSetupCubit.updateField(
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null,
        heightCm: double.tryParse(_heightController.text),
        weightKg: double.tryParse(_weightController.text),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth != null ? Timestamp.fromDate(_selectedDateOfBirth!) : null,
        fitnessGoal: _selectedFitnessGoal,
        activityLevel: _selectedActivityLevel,
      );
      _profileSetupCubit.saveProfile(avatarImageFile: _selectedAvatarImage);
    } else {
      developer.log("Form is NOT valid", name: "ProfileSetupScreen");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.profileSetupCorrectFormErrorsSnackbar), backgroundColor: Colors.orangeAccent),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isOptional = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isOptional ? '$label ${loc.profileSetupOptionalFieldSuffix}' : '$label*',
      ),
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChangedCallback,
    String? Function(T?)? validator,
    bool isOptional = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isOptional ? '$label ${loc.profileSetupOptionalFieldSuffix}' : '$label*',
      ),
      items: items,
      onChanged: (newValue) {
        setState(() {
          if (label == loc.profileSetupGenderLabel) _selectedGender = newValue as String?;
          if (label == loc.profileSetupFitnessGoalLabel) _selectedFitnessGoal = newValue as String?;
          if (label == loc.profileSetupActivityLevelLabel) _selectedActivityLevel = newValue as String?;
        });
        onChangedCallback?.call(newValue);
      },
      validator: validator,
      isExpanded: true,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<DropdownMenuItem<String>> genderItems = [
      DropdownMenuItem(value: _genderKeyMale, child: Text(loc.profileSetupGenderMale)),
      DropdownMenuItem(value: _genderKeyFemale, child: Text(loc.profileSetupGenderFemale)),
      DropdownMenuItem(value: _genderKeyOther, child: Text(loc.profileSetupGenderOther)),
      DropdownMenuItem(value: _genderKeyPreferNotToSay, child: Text(loc.profileSetupGenderPreferNotToSay)),
    ];
    if (_selectedGender != null && !genderItems.any((item) => item.value == _selectedGender)) {
      _selectedGender = null;
    }

    final List<DropdownMenuItem<String>> fitnessGoalItems = [
      MapEntry('lose_weight', loc.profileSetupFitnessGoalLoseWeight),
      MapEntry('gain_muscle', loc.profileSetupFitnessGoalGainMuscle),
      MapEntry('improve_stamina', loc.profileSetupFitnessGoalImproveStamina),
      MapEntry('general_fitness', loc.profileSetupFitnessGoalGeneralFitness),
      MapEntry('improve_strength', loc.profileSetupFitnessGoalImproveStrength),
    ].map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList();
     if (_selectedFitnessGoal != null && !fitnessGoalItems.any((item) => item.value == _selectedFitnessGoal)) {
      _selectedFitnessGoal = null;
    }

    final List<DropdownMenuItem<String>> activityLevelItems = [
      MapEntry('sedentary', loc.profileSetupActivityLevelSedentary),
      MapEntry('light', loc.profileSetupActivityLevelLight),
      MapEntry('moderate', loc.profileSetupActivityLevelModerate),
      MapEntry('active', loc.profileSetupActivityLevelActive),
      MapEntry('very_active', loc.profileSetupActivityLevelVeryActive),
    ].map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis))).toList();
     if (_selectedActivityLevel != null && !activityLevelItems.any((item) => item.value == _selectedActivityLevel)) {
      _selectedActivityLevel = null;
    }


    return BlocProvider.value(
      value: _profileSetupCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditingMode ? loc.profileSetupAppBarTitleEdit : loc.profileSetupAppBarTitleCreate),
          centerTitle: true,
        ),
        body: BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
          listener: (context, state) {
            developer.log("ProfileSetupCubit state changed: $state", name: "ProfileSetupScreen.Listener");
            if (state is ProfileSetupSuccess) {
              developer.log("ProfileSetupSuccess: Navigating...", name: "ProfileSetupScreen.Listener");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.profileSetupSuccessMessage(_isEditingMode ? loc.profileSetupStatusUpdated : loc.profileSetupStatusSaved)), backgroundColor: Colors.green),
              );
              
              try {
                context.read<global_user_profile_cubit.UserProfileCubit>().updateUserProfileState(state.updatedProfile);
                developer.log("Global UserProfileCubit updated after profile setup/edit.", name: "ProfileSetupScreen.Listener");
              } catch (e) {
                developer.log("Could not find or update global UserProfileCubit: $e", name: "ProfileSetupScreen.Listener");
              }

              if (_isEditingMode) {
                Navigator.of(context).pop(true); 
              } else {
                 Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()), 
                  (Route<dynamic> route) => false,
                );
              }
            } else if (state is ProfileSetupFailure) {
              developer.log("ProfileSetupFailure: ${state.error}", name: "ProfileSetupScreen.Listener");
               String errorMessage = state.error;
                if (state.error == "User not logged in.") errorMessage = loc.profileSetupErrorUserNotLoggedIn;
                else if (state.error == "Username cannot be empty.") errorMessage = loc.profileSetupErrorUsernameEmpty;
                else if (state.error == "Profile to edit not found. Please try again.") errorMessage = loc.profileSetupErrorProfileNotFoundEdit;
                else if (state.error.startsWith("Failed to load profile data: ")) errorMessage = loc.profileSetupErrorFailedToLoad(state.error.replaceFirst("Failed to load profile data: ", ""));
                else if (state.error == "Failed to upload avatar image. Profile not saved.") errorMessage = loc.profileSetupErrorFailedAvatarUpload;
                else if (state.error.startsWith("Failed to save profile data: ")) errorMessage = loc.profileSetupErrorFailedToSave(state.error.replaceFirst("Failed to save profile data: ", ""));


              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
              );
            }
          },
          buildWhen: (previous, current) => current is ProfileSetupInitial || current is ProfileSetupDataLoaded || current is ProfileSetupLoading || current is ProfileSetupFailure,
          builder: (context, state) {
            developer.log("ProfileSetupScreen rebuilding UI with state: $state", name: "ProfileSetupScreen.Builder");
            
            if (state is ProfileSetupDataLoaded && !_isEditingMode) {
              final profileFromCubit = state.userProfile;
              _usernameController.text = profileFromCubit.username ?? _usernameController.text;
              _displayNameController.text = profileFromCubit.displayName ?? _displayNameController.text;
              _heightController.text = profileFromCubit.heightCm?.toStringAsFixed(0) ?? _heightController.text;
              _weightController.text = profileFromCubit.weightKg?.toStringAsFixed(1) ?? _weightController.text;
              _currentAvatarUrl = profileFromCubit.profilePictureUrl ?? _currentAvatarUrl;
              if (_isValidGenderKey(profileFromCubit.gender) && _selectedGender == null) _selectedGender = profileFromCubit.gender;
              if (profileFromCubit.fitnessGoal != null && _selectedFitnessGoal == null) _selectedFitnessGoal = profileFromCubit.fitnessGoal;
              if (profileFromCubit.activityLevel != null && _selectedActivityLevel == null) _selectedActivityLevel = profileFromCubit.activityLevel;

            } else if (state is ProfileSetupDataLoaded && _isEditingMode) {
              _currentAvatarUrl = state.userProfile.profilePictureUrl ?? _currentAvatarUrl;
               if (_isValidGenderKey(state.userProfile.gender)) _selectedGender = state.userProfile.gender;
               if (state.userProfile.fitnessGoal != null) _selectedFitnessGoal = state.userProfile.fitnessGoal;
               if (state.userProfile.activityLevel != null) _selectedActivityLevel = state.userProfile.activityLevel;

            }


            if (state is ProfileSetupLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            ImageProvider? avatarImageProvider;
            if (_selectedAvatarImage != null) {
              avatarImageProvider = FileImage(_selectedAvatarImage!);
            } else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
              avatarImageProvider = NetworkImage(_currentAvatarUrl!);
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: avatarImageProvider != null ? () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: avatarImageProvider!)));
                            } : null,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: avatarImageProvider,
                              child: avatarImageProvider == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.white70)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material( 
                              color: Theme.of(context).colorScheme.secondary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: _pickAvatarImage,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _usernameController,
                      label: loc.profileSetupUsernameLabel,
                      validator: (value) => (value == null || value.trim().isEmpty) ? loc.profileSetupUsernameErrorRequired : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _displayNameController,
                      label: loc.profileSetupDisplayNameLabel,
                      isOptional: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      value: _selectedGender,
                      label: loc.profileSetupGenderLabel,
                      isOptional: true,
                      items: genderItems,
                      onChangedCallback: (value) => _profileSetupCubit.updateField(gender: value),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey.shade400, width: 1.0),
                      ),
                      tileColor: Theme.of(context).inputDecorationTheme.fillColor,
                      title: Text(
                        _selectedDateOfBirth == null
                            ? '${loc.profileSetupDobLabel} ${loc.profileSetupOptionalFieldSuffix}'
                            : DateFormat('dd MMMM yyyy', loc.localeName).format(_selectedDateOfBirth!),
                        style: _selectedDateOfBirth == null
                            ? Theme.of(context).inputDecorationTheme.hintStyle
                            : Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                     _buildTextField(
                      controller: _heightController,
                      label: loc.profileSetupHeightLabel,
                      isOptional: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = int.tryParse(value);
                        if (n == null || n <= 0 || n > 300) return loc.profileSetupHeightErrorInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _weightController,
                      label: loc.profileSetupWeightLabel,
                      isOptional: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                       validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = double.tryParse(value);
                        if (n == null || n <= 0 || n > 500) return loc.profileSetupWeightErrorInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      value: _selectedFitnessGoal,
                      label: loc.profileSetupFitnessGoalLabel,
                      isOptional: true,
                      items: fitnessGoalItems,
                      onChangedCallback: (value) => _profileSetupCubit.updateField(fitnessGoal: value),
                    ),
                    const SizedBox(height: 16),
                     _buildDropdownField<String>(
                      value: _selectedActivityLevel,
                      label: loc.profileSetupActivityLevelLabel,
                      isOptional: true,
                      items: activityLevelItems,
                       onChangedCallback: (value) => _profileSetupCubit.updateField(activityLevel: value),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: (state is ProfileSetupLoading) ? null : _handleSaveProfile,
                      child: (state is ProfileSetupLoading)
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                          : Text(_isEditingMode ? loc.profileSetupButtonSaveChanges : loc.profileSetupButtonCompleteProfile),
                    ),
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