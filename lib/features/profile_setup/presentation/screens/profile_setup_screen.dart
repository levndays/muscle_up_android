// lib/features/profile_setup/presentation/screens/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/profile_setup_cubit.dart';
import '../../../../home_page.dart'; 
import '../../../profile/presentation/cubit/user_profile_cubit.dart' as global_user_profile_cubit;


class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? userProfileToEdit; // Новий параметр для редагування

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
  bool _isEditingMode = false; // Прапорець для режиму редагування

  @override
  void initState() {
    super.initState();
    developer.log("ProfileSetupScreen initState. Editing: ${widget.userProfileToEdit != null}", name: "ProfileSetupScreen");
    _isEditingMode = widget.userProfileToEdit != null;

    _profileSetupCubit = ProfileSetupCubit(
      RepositoryProvider.of<UserProfileRepository>(context),
      RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
      // Передаємо initialProfile, якщо він є (для редагування)
      initialProfile: widget.userProfileToEdit, 
    );
    
    // Ініціалізуємо поля, якщо це режим редагування
    if (_isEditingMode && widget.userProfileToEdit != null) {
      final profile = widget.userProfileToEdit!;
      _usernameController.text = profile.username ?? '';
      _displayNameController.text = profile.displayName ?? '';
      _heightController.text = profile.heightCm?.toStringAsFixed(0) ?? '';
      _weightController.text = profile.weightKg?.toStringAsFixed(1) ?? '';
      _selectedGender = profile.gender;
      _selectedDateOfBirth = profile.dateOfBirth?.toDate();
      _selectedFitnessGoal = profile.fitnessGoal;
      _selectedActivityLevel = profile.activityLevel;
    } else {
      // Для нового профілю можемо спробувати заповнити displayName з FirebaseAuth
      final currentUser = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser;
      if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
        _displayNameController.text = currentUser.displayName!;
      } else if (currentUser?.email != null && currentUser!.email!.contains('@')) {
         _displayNameController.text = currentUser.email!.split('@').first;
      }
    }

    // Слухачі для оновлення кубіта при зміні тексту
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
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

  void _handleSaveProfile() {
    developer.log("Save Profile button pressed. IsEditing: $_isEditingMode", name: "ProfileSetupScreen");
    if (_formKey.currentState?.validate() ?? false) {
      developer.log("Form is valid, calling cubit.saveProfile()", name: "ProfileSetupScreen");
      // Переконуємося, що всі дані з форми передані в кубіт перед збереженням
      _profileSetupCubit.updateField(
        username: _usernameController.text.trim(), // username завжди передаємо, бо він обов'язковий
        displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null,
        heightCm: double.tryParse(_heightController.text),
        weightKg: double.tryParse(_weightController.text),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth != null ? Timestamp.fromDate(_selectedDateOfBirth!) : null,
        fitnessGoal: _selectedFitnessGoal,
        activityLevel: _selectedActivityLevel,
      );
      _profileSetupCubit.saveProfile();
    } else {
      developer.log("Form is NOT valid", name: "ProfileSetupScreen");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.'), backgroundColor: Colors.orangeAccent),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isOptional = false,
    // onChanged більше не потрібен тут, бо ми використовуємо listeners для контролерів
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (Optional)' : '$label*',
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
    required void Function(T?)? onChangedCallback, // Перейменовано для ясності
    String? Function(T?)? validator,
    bool isOptional = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (Optional)' : '$label*',
      ),
      items: items,
      onChanged: (newValue) {
        setState(() { // Оновлюємо локальний стан для UI
          if (label.toLowerCase().contains('gender')) _selectedGender = newValue as String?;
          if (label.toLowerCase().contains('goal')) _selectedFitnessGoal = newValue as String?;
          if (label.toLowerCase().contains('activity')) _selectedActivityLevel = newValue as String?;
        });
        onChangedCallback?.call(newValue); // Викликаємо колбек для кубіта
      },
      validator: validator,
      isExpanded: true,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileSetupCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditingMode ? 'Edit Profile' : 'Complete Your Profile'),
          centerTitle: true,
        ),
        body: BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
          listener: (context, state) {
            developer.log("ProfileSetupCubit state changed: $state", name: "ProfileSetupScreen.Listener");
            if (state is ProfileSetupSuccess) {
              developer.log("ProfileSetupSuccess: Navigating...", name: "ProfileSetupScreen.Listener");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile ${_isEditingMode ? "updated" : "saved"} successfully!'), backgroundColor: Colors.green),
              );
              
              try {
                context.read<global_user_profile_cubit.UserProfileCubit>().updateUserProfileState(state.updatedProfile);
                developer.log("Global UserProfileCubit updated after profile setup/edit.", name: "ProfileSetupScreen.Listener");
              } catch (e) {
                developer.log("Could not find or update global UserProfileCubit: $e", name: "ProfileSetupScreen.Listener");
              }

              if (_isEditingMode) {
                Navigator.of(context).pop(true); // Повертаємо true, щоб ProfileScreen знав про оновлення
              } else {
                 Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()), // Або AuthGate, якщо HomePage вимагає UserProfileCubit
                  (Route<dynamic> route) => false,
                );
              }
            } else if (state is ProfileSetupFailure) {
              developer.log("ProfileSetupFailure: ${state.error}", name: "ProfileSetupScreen.Listener");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          buildWhen: (previous, current) => current is ProfileSetupInitial || current is ProfileSetupDataLoaded || current is ProfileSetupLoading || current is ProfileSetupFailure,
          builder: (context, state) {
            developer.log("ProfileSetupScreen rebuilding UI with state: $state", name: "ProfileSetupScreen.Builder");
            
            // Використовуємо дані з `widget.userProfileToEdit` для початкового заповнення,
            // а потім оновлюємо з `state` якщо він ProfileSetupDataLoaded.
            // Це допомагає уникнути перезапису полів, які користувач щойно змінив.
            if (state is ProfileSetupDataLoaded && !_isEditingMode) {
              // Якщо це НЕ режим редагування і кубіт завантажив дані (наприклад, після невдалої спроби збереження)
              // оновлюємо контролери з даних кубіта
              final profileFromCubit = state.userProfile;
              _usernameController.text = profileFromCubit.username ?? _usernameController.text;
              _displayNameController.text = profileFromCubit.displayName ?? _displayNameController.text;
              _heightController.text = profileFromCubit.heightCm?.toStringAsFixed(0) ?? _heightController.text;
              _weightController.text = profileFromCubit.weightKg?.toStringAsFixed(1) ?? _weightController.text;
              // Dropdowns оновлюються через setState в onChanged, тому тут не потрібно
            }


            if (state is ProfileSetupLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Username is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      isOptional: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      value: _selectedGender,
                      label: 'Gender',
                      isOptional: true,
                      items: ['Male', 'Female', 'Other', 'Prefer not to say']
                          .map((label) => DropdownMenuItem(value: label.toLowerCase().replaceAll(' ', '_'), child: Text(label)))
                          .toList(),
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
                            ? 'Date of Birth (Optional)'
                            : DateFormat('dd MMMM yyyy').format(_selectedDateOfBirth!),
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
                      label: 'Height (cm)',
                      isOptional: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false), // Зроблено цілочисельним
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = int.tryParse(value); // Парсимо як int
                        if (n == null || n <= 0 || n > 300) return 'Invalid height (1-300 cm)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      isOptional: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                       validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = double.tryParse(value);
                        if (n == null || n <= 0 || n > 500) return 'Invalid weight (1-500 kg)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      value: _selectedFitnessGoal,
                      label: 'Primary Fitness Goal',
                      isOptional: true,
                      items: ['Lose Weight', 'Gain Muscle', 'Improve Stamina', 'General Fitness', 'Improve Strength']
                          .map((label) => DropdownMenuItem(value: label.toLowerCase().replaceAll(' ', '_'), child: Text(label)))
                          .toList(),
                      onChangedCallback: (value) => _profileSetupCubit.updateField(fitnessGoal: value),
                    ),
                    const SizedBox(height: 16),
                     _buildDropdownField<String>(
                      value: _selectedActivityLevel,
                      label: 'Activity Level',
                      isOptional: true,
                      items: ['Sedentary (little or no exercise)', 'Light (exercise 1-3 days/week)', 'Moderate (exercise 3-5 days/week)', 'Active (exercise 6-7 days/week)', 'Very Active (hard exercise or physical job)']
                          .map((label) {
                            final value = label.split(' ').first.toLowerCase();
                            return DropdownMenuItem(value: value, child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1,));
                          })
                          .toList(),
                       onChangedCallback: (value) => _profileSetupCubit.updateField(activityLevel: value),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: (state is ProfileSetupLoading) ? null : _handleSaveProfile,
                      child: (state is ProfileSetupLoading)
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                          : Text(_isEditingMode ? 'Save Changes' : 'Complete Profile'),
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