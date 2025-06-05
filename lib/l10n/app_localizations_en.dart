// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muscle UP!';

  @override
  String get loginPageSignInButton => 'Sign In';

  @override
  String get loginPageTitleSignIn => 'Sign In';

  @override
  String get loginPageTitleSignUp => 'Sign Up';

  @override
  String get loginPageEmailHint => 'Email';

  @override
  String get loginPagePasswordHint => 'Password';

  @override
  String get loginPageErrorEnterEmail => 'Please enter your email';

  @override
  String get loginPageErrorValidEmail => 'Please enter a valid email';

  @override
  String get loginPageErrorEnterPassword => 'Please enter your password';

  @override
  String get loginPageErrorPasswordLength =>
      'Password must be at least 6 characters';

  @override
  String get loginPageButtonCreateAccount => 'Create Account';

  @override
  String get loginPageButtonSignInWithGoogle => 'Sign in with Google';

  @override
  String get loginPageToggleSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get loginPageToggleSignIn => 'Already have an account? Sign In';

  @override
  String get loginPageErrorAuthDefault => 'Authentication error occurred.';

  @override
  String loginPageErrorUnknownDefault(String errorDetails) {
    return 'An unknown error occurred: $errorDetails';
  }

  @override
  String get loginPageErrorGoogleSignInDefault => 'Google Sign-In error.';

  @override
  String loginPageErrorUnknownGoogleDefault(String errorDetails) {
    return 'Unknown Google Sign-In error: $errorDetails';
  }

  @override
  String get loginPageErrorInternalForm =>
      'Internal form error. Please try again.';

  @override
  String get profileSetupAppBarTitleEdit => 'Edit Profile';

  @override
  String get profileSetupAppBarTitleCreate => 'Complete Your Profile';

  @override
  String get profileSetupUsernameLabel => 'Username';

  @override
  String get profileSetupUsernameErrorRequired => 'Username is required';

  @override
  String get profileSetupDisplayNameLabel => 'Display Name';

  @override
  String get profileSetupGenderLabel => 'Gender';

  @override
  String get profileSetupGenderMale => 'Male';

  @override
  String get profileSetupGenderFemale => 'Female';

  @override
  String get profileSetupGenderOther => 'Other';

  @override
  String get profileSetupGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get profileSetupDobLabel => 'Date of Birth';

  @override
  String get profileSetupDobDatePickerHelpText => 'Select your date of birth';

  @override
  String get profileSetupHeightLabel => 'Height (cm)';

  @override
  String get profileSetupHeightErrorInvalid => 'Invalid height (1-300 cm)';

  @override
  String get profileSetupWeightLabel => 'Weight (kg)';

  @override
  String get profileSetupWeightErrorInvalid => 'Invalid weight (1-500 kg)';

  @override
  String get profileSetupFitnessGoalLabel => 'Primary Fitness Goal';

  @override
  String get profileSetupFitnessGoalLoseWeight => 'Lose Weight';

  @override
  String get profileSetupFitnessGoalGainMuscle => 'Gain Muscle';

  @override
  String get profileSetupFitnessGoalImproveStamina => 'Improve Stamina';

  @override
  String get profileSetupFitnessGoalGeneralFitness => 'General Fitness';

  @override
  String get profileSetupFitnessGoalImproveStrength => 'Improve Strength';

  @override
  String get profileSetupActivityLevelLabel => 'Activity Level';

  @override
  String get profileSetupActivityLevelSedentary =>
      'Sedentary (little or no exercise)';

  @override
  String get profileSetupActivityLevelLight => 'Light (exercise 1-3 days/week)';

  @override
  String get profileSetupActivityLevelModerate =>
      'Moderate (exercise 3-5 days/week)';

  @override
  String get profileSetupActivityLevelActive =>
      'Active (exercise 6-7 days/week)';

  @override
  String get profileSetupActivityLevelVeryActive =>
      'Very Active (hard exercise or physical job)';

  @override
  String get profileSetupButtonSaveChanges => 'Save Changes';

  @override
  String get profileSetupButtonCompleteProfile => 'Complete Profile';

  @override
  String get profileSetupErrorUserNotLoggedIn => 'User not logged in.';

  @override
  String get profileSetupErrorUsernameEmpty => 'Username cannot be empty.';

  @override
  String get profileSetupErrorProfileNotFoundEdit =>
      'Profile to edit not found. Please try again.';

  @override
  String profileSetupErrorFailedToLoad(String errorDetails) {
    return 'Failed to load profile data: $errorDetails';
  }

  @override
  String get profileSetupErrorFailedAvatarUpload =>
      'Failed to upload avatar image. Profile not saved.';

  @override
  String profileSetupErrorFailedToSave(String errorDetails) {
    return 'Error: $errorDetails';
  }

  @override
  String profileSetupSuccessMessage(String status) {
    return 'Profile $status successfully!';
  }

  @override
  String get profileSetupStatusSaved => 'saved';

  @override
  String get profileSetupStatusUpdated => 'updated';

  @override
  String get profileSetupCorrectFormErrorsSnackbar =>
      'Please correct the errors in the form.';

  @override
  String get profileSetupOptionalFieldSuffix => '(Optional)';

  @override
  String get dashboardGreetingWelcome => 'Welcome,';

  @override
  String get dashboardSectionStats => 'STATS';

  @override
  String get dashboardStatsWeightLabel => 'WEIGHT';

  @override
  String get dashboardStatsStreakLabel => 'STREAK';

  @override
  String get dashboardStatsAdherenceLabel => 'ADHERENCE';

  @override
  String get dashboardSectionNotifications => 'NOTIFICATIONS';

  @override
  String get dashboardNotificationsReadAll => 'READ ALL';

  @override
  String get dashboardNotificationsEmpty => 'No new notifications.';

  @override
  String dashboardNotificationsError(String message) {
    return 'Error loading notifications: $message';
  }

  @override
  String get dashboardNotificationsLoading => 'Loading notifications...';

  @override
  String get dashboardSnackbarAllNotificationsRead =>
      'All notifications marked as read!';

  @override
  String get upcomingScheduleTitle => 'UPCOMING SCHEDULE (NEXT 7 DAYS)';

  @override
  String get upcomingScheduleRestDay => 'Rest Day';

  @override
  String upcomingScheduleError(String message) {
    return 'Error: $message';
  }

  @override
  String get upcomingScheduleEmpty =>
      'No workouts scheduled for the next 7 days.';

  @override
  String get volumeTrendChartLogWorkouts =>
      'Log workouts to see your volume trend.';

  @override
  String get volumeTrendChartLogMoreWorkouts =>
      'Log at least two workouts to see the trend.';

  @override
  String volumeTrendChartSingleWorkoutVolume(String volume) {
    return 'Last workout volume: $volume k kg.\nMore workouts needed for trend.';
  }

  @override
  String get volumeTrendChartLoading => 'Loading volume data...';

  @override
  String volumeTrendChartError(String message) {
    return 'Error loading volume: $message';
  }

  @override
  String get startWorkoutButton => 'START WORKOUT';

  @override
  String get startWorkoutFabErrorLogin => 'Please log in to start a workout.';

  @override
  String startWorkoutFabErrorActiveSession(String errorDetails) {
    return 'Error checking active session: $errorDetails';
  }

  @override
  String startWorkoutFabErrorLoadRoutines(String errorDetails) {
    return 'Could not load routines. Please try again. Error: $errorDetails';
  }

  @override
  String get startWorkoutFabNewRoutineCreatedSnackbar =>
      'New routine created! Select it from the list to start.';

  @override
  String get dashboardTabRoutines => 'ROUTINES';

  @override
  String get dashboardTabExplore => 'EXPLORE';

  @override
  String get dashboardTabProgress => 'PROGRESS';

  @override
  String get dashboardTabProfile => 'PROFILE';
}
