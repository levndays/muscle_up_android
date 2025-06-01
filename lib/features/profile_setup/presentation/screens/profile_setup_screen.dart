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
import '../../../../home_page.dart'; // Для навігації
// Імпорт UserProfileCubit, який використовується HomePage, може знадобитися для оновлення стану
import '../../../profile/presentation/cubit/user_profile_cubit.dart' as global_user_profile_cubit;


class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    developer.log("ProfileSetupScreen initState", name: "ProfileSetupScreen");
    _profileSetupCubit = ProfileSetupCubit(
      RepositoryProvider.of<UserProfileRepository>(context),
      RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
    ); // _loadInitialData викликається в конструкторі кубіта
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
      builder: (context, child) { // Опціонально: для стилізації DatePicker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary, // Колір хедера
                  onPrimary: Colors.white, // Колір тексту на хедері
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Колір кнопок
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
    developer.log("Save Profile button pressed", name: "ProfileSetupScreen");
    if (_formKey.currentState?.validate() ?? false) {
      developer.log("Form is valid, calling cubit.saveProfile()", name: "ProfileSetupScreen");
      // Переконуємося, що останні дані з контролерів передані (якщо вони не оновлюються onchanged)
      // Це вже робиться через onChanged, але для безпеки можна додати тут:
      _profileSetupCubit.updateField(
        username: _usernameController.text.trim().isNotEmpty ? _usernameController.text.trim() : null,
        displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null,
        heightCm: double.tryParse(_heightController.text),
        weightKg: double.tryParse(_weightController.text),
        // gender, dateOfBirth, fitnessGoal, activityLevel вже оновлюються через setState
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
    void Function(String)? onChanged,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (Optional)' : '$label*',
        // contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Зменшено
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    bool isOptional = false,

  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (Optional)' : '$label*',
        // contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0), // Зменшено
      ),
      items: items,
      onChanged: onChanged,
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
          title: const Text('Complete Your Profile'),
          centerTitle: true,
        ),
        body: BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
          listener: (context, state) {
            developer.log("ProfileSetupCubit state changed: $state", name: "ProfileSetupScreen.Listener");
            if (state is ProfileSetupSuccess) {
              developer.log("ProfileSetupSuccess: Navigating to HomePage", name: "ProfileSetupScreen.Listener");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
              );
              // Оновлюємо глобальний UserProfileCubit, якщо він існує
              try {
                // `read` - це безпечний спосіб отримати кубіт, якщо він наданий у контексті.
                // Якщо він не наданий, це викличе помилку, яку ми тут ловимо.
                context.read<global_user_profile_cubit.UserProfileCubit>().updateUserProfileState(state.updatedProfile);
                 developer.log("Global UserProfileCubit updated", name: "ProfileSetupScreen.Listener");
              } catch (e) {
                developer.log("Could not find or update global UserProfileCubit: $e", name: "ProfileSetupScreen.Listener");
              }

              // Переходимо на AuthGate, щоб він зробив остаточну перевірку
              // profileSetupComplete і перенаправив на HomePage.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            } else if (state is ProfileSetupFailure) {
              developer.log("ProfileSetupFailure: ${state.error}", name: "ProfileSetupScreen.Listener");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          // Перебудовуємо UI тільки при певних змінах стану
          buildWhen: (previous, current) => current is ProfileSetupInitial || current is ProfileSetupDataLoaded || current is ProfileSetupLoading || current is ProfileSetupFailure,
          builder: (context, state) {
            developer.log("ProfileSetupScreen rebuilding UI with state: $state", name: "ProfileSetupScreen.Builder");
            UserProfile currentProfileUI;

            if (state is ProfileSetupInitial) {
              currentProfileUI = state.userProfile;
            } else if (state is ProfileSetupDataLoaded) {
              currentProfileUI = state.userProfile;
            } else if (state is ProfileSetupLoading && _profileSetupCubit.currentProfileSnapshot.uid.isNotEmpty) {
              // Якщо завантаження, але є попередні дані, використовуємо їх, щоб UI не був порожнім
              currentProfileUI = _profileSetupCubit.currentProfileSnapshot;
            }
             else {
              // Початковий стан або стан помилки без даних профілю (малоймовірно, але для безпеки)
              currentProfileUI = UserProfile(
                uid: RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid ?? '',
                email: RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.email,
                displayName: RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.displayName,
                xp: 0, level: 1, profileSetupComplete: false,
                createdAt: Timestamp.now(), updatedAt: Timestamp.now(),
              );
            }

            // Оновлюємо контролери та локальні змінні, якщо вони порожні,
            // а в currentProfileUI є дані. Це відбувається після побудови фрейму,
            // щоб уникнути викликів setState під час build.
             WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) { // Перевіряємо, чи віджет все ще в дереві
                // Заповнюємо TextControllers
                if (_usernameController.text.isEmpty && currentProfileUI.username != null) {
                  _usernameController.text = currentProfileUI.username!;
                }
                if (_displayNameController.text.isEmpty && (currentProfileUI.displayName != null || currentProfileUI.email != null)) {
                  _displayNameController.text = currentProfileUI.displayName ?? currentProfileUI.email?.split('@').first ?? '';
                }
                 if (_heightController.text.isEmpty && currentProfileUI.heightCm != null) {
                  _heightController.text = currentProfileUI.heightCm!.toStringAsFixed(0); // Без десяткових для зросту
                }
                if (_weightController.text.isEmpty && currentProfileUI.weightKg != null) {
                  _weightController.text = currentProfileUI.weightKg!.toStringAsFixed(1);
                }
                // Для Dropdown та DatePicker, setState викликається при зміні користувачем.
                // Але якщо вони null, а в currentProfileUI є значення, оновлюємо їх.
                // Важливо: перевіряти, чи значення *поточних локальних змінних* є null,
                // перш ніж оновлювати їх з `currentProfileUI`.
                if (_selectedGender == null && currentProfileUI.gender != null) {
                  setState(() => _selectedGender = currentProfileUI.gender);
                }
                if (_selectedDateOfBirth == null && currentProfileUI.dateOfBirth != null) {
                   setState(() => _selectedDateOfBirth = currentProfileUI.dateOfBirth!.toDate());
                }
                if (_selectedFitnessGoal == null && currentProfileUI.fitnessGoal != null) {
                   setState(() => _selectedFitnessGoal = currentProfileUI.fitnessGoal);
                }
                if (_selectedActivityLevel == null && currentProfileUI.activityLevel != null) {
                   setState(() => _selectedActivityLevel = currentProfileUI.activityLevel);
                }
              }
            });


            if (state is ProfileSetupLoading && currentProfileUI.uid.isEmpty) { // Тільки якщо немає жодних даних для відображення
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
                      onChanged: (value) => _profileSetupCubit.updateField(username: value.trim()),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      isOptional: true,
                      onChanged: (value) => _profileSetupCubit.updateField(displayName: value.trim().isNotEmpty ? value.trim() : null),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      value: _selectedGender,
                      label: 'Gender',
                      isOptional: true,
                      items: ['Male', 'Female', 'Other', 'Prefer not to say']
                          .map((label) => DropdownMenuItem(value: label.toLowerCase().replaceAll(' ', '_'), child: Text(label)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                        _profileSetupCubit.updateField(gender: value);
                      },
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null; // Опціонально
                        final n = double.tryParse(value);
                        if (n == null || n <= 0 || n > 300) return 'Invalid height';
                        return null;
                      },
                      onChanged: (value) => _profileSetupCubit.updateField(heightCm: double.tryParse(value)),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      isOptional: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                       validator: (value) {
                        if (value == null || value.isEmpty) return null; // Опціонально
                        final n = double.tryParse(value);
                        if (n == null || n <= 0 || n > 500) return 'Invalid weight';
                        return null;
                      },
                      onChanged: (value) => _profileSetupCubit.updateField(weightKg: double.tryParse(value)),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField<String>(
                      value: _selectedFitnessGoal,
                      label: 'Primary Fitness Goal',
                      isOptional: true,
                      items: ['Lose Weight', 'Gain Muscle', 'Improve Stamina', 'General Fitness', 'Improve Strength']
                          .map((label) => DropdownMenuItem(value: label.toLowerCase().replaceAll(' ', '_'), child: Text(label)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedFitnessGoal = value);
                         _profileSetupCubit.updateField(fitnessGoal: value);
                      },
                    ),
                    const SizedBox(height: 16),
                     _buildDropdownField<String>(
                      value: _selectedActivityLevel,
                      label: 'Activity Level',
                      isOptional: true,
                      items: ['Sedentary (little or no exercise)', 'Light (exercise 1-3 days/week)', 'Moderate (exercise 3-5 days/week)', 'Active (exercise 6-7 days/week)', 'Very Active (hard exercise or physical job)']
                          .map((label) {
                            final value = label.split(' ').first.toLowerCase();
                            return DropdownMenuItem(value: value, child: Text(label, overflow: TextOverflow.ellipsis));
                          })
                          .toList(),
                       onChanged: (value) {
                        setState(() => _selectedActivityLevel = value);
                         _profileSetupCubit.updateField(activityLevel: value);
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: (state is ProfileSetupLoading) ? null : _handleSaveProfile,
                      child: (state is ProfileSetupLoading)
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                          : const Text('Save and Continue'),
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