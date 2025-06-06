import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Muscle UP!'**
  String get appTitle;

  /// Label for the sign in button on the login page
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginPageSignInButton;

  /// Title text on the login page when in sign-in mode
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginPageTitleSignIn;

  /// Title text on the login page when in sign-up mode
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginPageTitleSignUp;

  /// Hint text for the email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginPageEmailHint;

  /// Hint text for the password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPagePasswordHint;

  /// Validation error if email is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get loginPageErrorEnterEmail;

  /// Validation error if email format is incorrect
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get loginPageErrorValidEmail;

  /// Validation error if password is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPageErrorEnterPassword;

  /// Validation error if password is too short during sign up
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPageErrorPasswordLength;

  /// Label for the create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginPageButtonCreateAccount;

  /// Label for the Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginPageButtonSignInWithGoogle;

  /// Text to toggle to the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get loginPageToggleSignUp;

  /// Text to toggle to the sign-in form
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get loginPageToggleSignIn;

  /// Default authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error occurred.'**
  String get loginPageErrorAuthDefault;

  /// Default unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred: {errorDetails}'**
  String loginPageErrorUnknownDefault(String errorDetails);

  /// Default Google Sign-In error message
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In error.'**
  String get loginPageErrorGoogleSignInDefault;

  /// Default unknown Google Sign-In error message
  ///
  /// In en, this message translates to:
  /// **'Unknown Google Sign-In error: {errorDetails}'**
  String loginPageErrorUnknownGoogleDefault(String errorDetails);

  /// Snackbar message for internal form error
  ///
  /// In en, this message translates to:
  /// **'Internal form error. Please try again.'**
  String get loginPageErrorInternalForm;

  /// App bar title when editing profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileSetupAppBarTitleEdit;

  /// App bar title when creating a new profile
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profileSetupAppBarTitleCreate;

  /// Label for username input field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileSetupUsernameLabel;

  /// Validation error if username is empty
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get profileSetupUsernameErrorRequired;

  /// Label for display name input field
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileSetupDisplayNameLabel;

  /// Label for gender selection
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileSetupGenderLabel;

  /// Gender option: Male
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileSetupGenderMale;

  /// Gender option: Female
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileSetupGenderFemale;

  /// Gender option: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileSetupGenderOther;

  /// Gender option: Prefer not to say
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get profileSetupGenderPreferNotToSay;

  /// Label for date of birth selection
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileSetupDobLabel;

  /// Help text for date of birth picker
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get profileSetupDobDatePickerHelpText;

  /// Label for height input field
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profileSetupHeightLabel;

  /// Validation error for height input
  ///
  /// In en, this message translates to:
  /// **'Invalid height (1-300 cm)'**
  String get profileSetupHeightErrorInvalid;

  /// Label for weight input field
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get profileSetupWeightLabel;

  /// Validation error for weight input
  ///
  /// In en, this message translates to:
  /// **'Invalid weight (1-500 kg)'**
  String get profileSetupWeightErrorInvalid;

  /// Label for fitness goal selection
  ///
  /// In en, this message translates to:
  /// **'Primary Fitness Goal'**
  String get profileSetupFitnessGoalLabel;

  /// Fitness goal option: Lose Weight
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get profileSetupFitnessGoalLoseWeight;

  /// Fitness goal option: Gain Muscle
  ///
  /// In en, this message translates to:
  /// **'Gain Muscle'**
  String get profileSetupFitnessGoalGainMuscle;

  /// Fitness goal option: Improve Stamina
  ///
  /// In en, this message translates to:
  /// **'Improve Stamina'**
  String get profileSetupFitnessGoalImproveStamina;

  /// Fitness goal option: General Fitness
  ///
  /// In en, this message translates to:
  /// **'General Fitness'**
  String get profileSetupFitnessGoalGeneralFitness;

  /// Fitness goal option: Improve Strength
  ///
  /// In en, this message translates to:
  /// **'Improve Strength'**
  String get profileSetupFitnessGoalImproveStrength;

  /// Label for activity level selection
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get profileSetupActivityLevelLabel;

  /// Activity level option: Sedentary
  ///
  /// In en, this message translates to:
  /// **'Sedentary (little or no exercise)'**
  String get profileSetupActivityLevelSedentary;

  /// Activity level option: Light
  ///
  /// In en, this message translates to:
  /// **'Light (exercise 1-3 days/week)'**
  String get profileSetupActivityLevelLight;

  /// Activity level option: Moderate
  ///
  /// In en, this message translates to:
  /// **'Moderate (exercise 3-5 days/week)'**
  String get profileSetupActivityLevelModerate;

  /// Activity level option: Active
  ///
  /// In en, this message translates to:
  /// **'Active (exercise 6-7 days/week)'**
  String get profileSetupActivityLevelActive;

  /// Activity level option: Very Active
  ///
  /// In en, this message translates to:
  /// **'Very Active (hard exercise or physical job)'**
  String get profileSetupActivityLevelVeryActive;

  /// Button text to save changes when editing profile
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSetupButtonSaveChanges;

  /// Button text to complete profile when creating new
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get profileSetupButtonCompleteProfile;

  /// Error message if user is not logged in
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get profileSetupErrorUserNotLoggedIn;

  /// Error message if username is empty on save attempt
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty.'**
  String get profileSetupErrorUsernameEmpty;

  /// Error message if profile to edit is not found
  ///
  /// In en, this message translates to:
  /// **'Profile to edit not found. Please try again.'**
  String get profileSetupErrorProfileNotFoundEdit;

  /// Error message when failing to load profile data
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile data: {errorDetails}'**
  String profileSetupErrorFailedToLoad(String errorDetails);

  /// Error message when avatar upload fails
  ///
  /// In en, this message translates to:
  /// **'Failed to upload avatar image. Profile not saved.'**
  String get profileSetupErrorFailedAvatarUpload;

  /// Generic error message on save failure
  ///
  /// In en, this message translates to:
  /// **'Error: {errorDetails}'**
  String profileSetupErrorFailedToSave(String errorDetails);

  /// Success message after saving/updating profile
  ///
  /// In en, this message translates to:
  /// **'Profile {status} successfully!'**
  String profileSetupSuccessMessage(String status);

  /// Status part of success message: saved
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get profileSetupStatusSaved;

  /// Status part of success message: updated
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get profileSetupStatusUpdated;

  /// Snackbar message when form validation fails
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form.'**
  String get profileSetupCorrectFormErrorsSnackbar;

  /// Suffix for optional field labels
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get profileSetupOptionalFieldSuffix;

  /// Message shown in AuthGate while waiting for profile sync
  ///
  /// In en, this message translates to:
  /// **'Finalizing account setup...'**
  String get authGateFinalizingAccountSetup;

  /// Greeting text on the dashboard, part 1. Name will be appended.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get dashboardGreetingWelcome;

  /// Section title for user stats on the dashboard
  ///
  /// In en, this message translates to:
  /// **'STATS'**
  String get dashboardSectionStats;

  /// Label for the weight stat on the dashboard
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get dashboardStatsWeightLabel;

  /// Label for the workout streak stat on the dashboard
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get dashboardStatsStreakLabel;

  /// Label for the workout adherence percentage on the dashboard
  ///
  /// In en, this message translates to:
  /// **'ADHERENCE'**
  String get dashboardStatsAdherenceLabel;

  /// Section title for notifications on the dashboard
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get dashboardSectionNotifications;

  /// Button text to mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'READ ALL'**
  String get dashboardNotificationsReadAll;

  /// Message shown when there are no notifications
  ///
  /// In en, this message translates to:
  /// **'No new notifications.'**
  String get dashboardNotificationsEmpty;

  /// Error message when notifications fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications: {message}'**
  String dashboardNotificationsError(String message);

  /// Loading message for notifications
  ///
  /// In en, this message translates to:
  /// **'Loading notifications...'**
  String get dashboardNotificationsLoading;

  /// Snackbar message after marking all notifications as read
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read!'**
  String get dashboardSnackbarAllNotificationsRead;

  /// Title for the upcoming schedule widget on the dashboard
  ///
  /// In en, this message translates to:
  /// **'UPCOMING SCHEDULE (NEXT 7 DAYS)'**
  String get upcomingScheduleTitle;

  /// Text displayed for a day with no scheduled workouts
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get upcomingScheduleRestDay;

  /// Error message in the upcoming schedule widget
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String upcomingScheduleError(String message);

  /// Message when no workouts are scheduled in the upcoming schedule widget
  ///
  /// In en, this message translates to:
  /// **'No workouts scheduled for the next 7 days.'**
  String get upcomingScheduleEmpty;

  /// Message when no workout data for volume trend chart
  ///
  /// In en, this message translates to:
  /// **'Log workouts to see your volume trend.'**
  String get volumeTrendChartLogWorkouts;

  /// Message when only one workout is logged for volume trend
  ///
  /// In en, this message translates to:
  /// **'Log at least two workouts to see the trend.'**
  String get volumeTrendChartLogMoreWorkouts;

  /// Message displaying single workout volume and need for more data
  ///
  /// In en, this message translates to:
  /// **'Last workout volume: {volume} k kg.\nMore workouts needed for trend.'**
  String volumeTrendChartSingleWorkoutVolume(String volume);

  /// Fallback loading message for volume chart
  ///
  /// In en, this message translates to:
  /// **'Loading volume data...'**
  String get volumeTrendChartLoading;

  /// Error message for volume chart loading failure
  ///
  /// In en, this message translates to:
  /// **'Error loading volume: {message}'**
  String volumeTrendChartError(String message);

  /// Text for the main floating action button to start a workout
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get startWorkoutButton;

  /// Error message if user tries to start workout without being logged in.
  ///
  /// In en, this message translates to:
  /// **'Please log in to start a workout.'**
  String get startWorkoutFabErrorLogin;

  /// Error message when checking for an active workout session fails for FAB.
  ///
  /// In en, this message translates to:
  /// **'Error checking active session: {errorDetails}'**
  String startWorkoutFabErrorActiveSession(String errorDetails);

  /// Error message when fetching routines fails for FAB logic.
  ///
  /// In en, this message translates to:
  /// **'Could not load routines. Please try again. Error: {errorDetails}'**
  String startWorkoutFabErrorLoadRoutines(String errorDetails);

  /// Snackbar message after a new routine is created via the FAB flow.
  ///
  /// In en, this message translates to:
  /// **'New routine created! Select it from the list to start.'**
  String get startWorkoutFabNewRoutineCreatedSnackbar;

  /// Label for the Routines tab in the BottomNavigationBar
  ///
  /// In en, this message translates to:
  /// **'ROUTINES'**
  String get dashboardTabRoutines;

  /// Label for the Explore (social feed) tab in the BottomNavigationBar
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get dashboardTabExplore;

  /// Label for the Progress tab in the BottomNavigationBar
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get dashboardTabProgress;

  /// Label for the Profile tab in the BottomNavigationBar
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get dashboardTabProfile;

  /// App bar title for the user's routines list screen when in selection mode
  ///
  /// In en, this message translates to:
  /// **'My Routines'**
  String get userRoutinesScreenTitle;

  /// Error message when routines fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading routines: {message}'**
  String userRoutinesErrorLoad(String message);

  /// Title text when the user has no routines
  ///
  /// In en, this message translates to:
  /// **'You have no routines yet.'**
  String get userRoutinesEmptyTitle;

  /// Subtitle text encouraging user to create a routine
  ///
  /// In en, this message translates to:
  /// **'Create a routine to start organizing your workouts!'**
  String get userRoutinesEmptySubtitle;

  /// Button text to create the first routine when the list is empty
  ///
  /// In en, this message translates to:
  /// **'Create Your First Routine'**
  String get userRoutinesButtonCreateFirst;

  /// Floating action button text to create a new routine
  ///
  /// In en, this message translates to:
  /// **'NEW ROUTINE'**
  String get userRoutinesFabNewRoutine;

  /// Menu option to start a workout from a routine
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get routineListItemMenuStartWorkout;

  /// Menu option to edit a routine
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get routineListItemMenuEditRoutine;

  /// Menu option to share a routine
  ///
  /// In en, this message translates to:
  /// **'Share Routine'**
  String get routineListItemMenuShareRoutine;

  /// Menu option to delete a routine
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get routineListItemMenuDeleteRoutine;

  /// Title of the confirm delete dialog for a routine
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get routineListItemDeleteConfirmTitle;

  /// Confirmation message for deleting a routine
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{routineName}\"? This action cannot be undone.'**
  String routineListItemDeleteConfirmMessage(String routineName);

  /// Cancel button in delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get routineListItemDeleteConfirmButtonCancel;

  /// Delete button in delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get routineListItemDeleteConfirmButtonDelete;

  /// Snackbar message after a routine is deleted
  ///
  /// In en, this message translates to:
  /// **'Routine \"{routineName}\" deleted.'**
  String routineListItemSnackbarDeleted(String routineName);

  /// Snackbar message on error deleting a routine
  ///
  /// In en, this message translates to:
  /// **'Error deleting routine: {errorDetails}'**
  String routineListItemSnackbarErrorDelete(String errorDetails);

  /// App bar title for editing a routine
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get createEditRoutineScreenTitleEdit;

  /// App bar title for creating a new routine
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get createEditRoutineScreenTitleCreate;

  /// Tooltip for the delete routine button
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get createEditRoutineTooltipDelete;

  /// Snackbar message if form validation fails
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form.'**
  String get createEditRoutineSnackbarFormErrors;

  /// General success message for routine operations
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String createEditRoutineSuccessMessage(String message);

  /// General error message for routine operations
  ///
  /// In en, this message translates to:
  /// **'Error: {errorDetails}'**
  String createEditRoutineErrorMessage(String errorDetails);

  /// Part of success message: routine updated
  ///
  /// In en, this message translates to:
  /// **'Routine updated successfully!'**
  String get createEditRoutineStatusUpdated;

  /// Part of success message: routine created
  ///
  /// In en, this message translates to:
  /// **'Routine created successfully!'**
  String get createEditRoutineStatusCreated;

  /// Part of success message: routine deleted
  ///
  /// In en, this message translates to:
  /// **'Routine deleted successfully!'**
  String get createEditRoutineStatusDeleted;

  /// Error message if routine name is empty
  ///
  /// In en, this message translates to:
  /// **'Routine name cannot be empty.'**
  String get createEditRoutineErrorNameEmpty;

  /// Error message if routine has no exercises
  ///
  /// In en, this message translates to:
  /// **'Routine must have at least one exercise.'**
  String get createEditRoutineErrorNoExercises;

  /// Error message when trying to delete an unsaved routine
  ///
  /// In en, this message translates to:
  /// **'Cannot delete a new or unsaved routine.'**
  String get createEditRoutineErrorDeleteNew;

  /// Loading message when saving a routine
  ///
  /// In en, this message translates to:
  /// **'Saving routine...'**
  String get createEditRoutineLoadingMessageSaving;

  /// Loading message when deleting a routine
  ///
  /// In en, this message translates to:
  /// **'Deleting routine...'**
  String get createEditRoutineLoadingMessageDeleting;

  /// Label for routine name input field
  ///
  /// In en, this message translates to:
  /// **'Routine Name*'**
  String get createEditRoutineNameLabel;

  /// Validation error for empty routine name
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get createEditRoutineNameErrorEmpty;

  /// Label for routine description input field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get createEditRoutineDescriptionLabel;

  /// Label for scheduled days selection
  ///
  /// In en, this message translates to:
  /// **'Scheduled Days:'**
  String get createEditRoutineScheduledDaysLabel;

  /// Label for exercises list, shows count of exercises
  ///
  /// In en, this message translates to:
  /// **'Exercises ({count}):'**
  String createEditRoutineExercisesLabel(int count);

  /// Button text to add an exercise to the routine
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get createEditRoutineButtonAddExercise;

  /// Placeholder text when no exercises are added to a routine
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet. Tap \"Add\" to begin.'**
  String get createEditRoutineNoExercisesPlaceholder;

  /// Button text to save changes when editing a routine
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get createEditRoutineButtonSaveChanges;

  /// Button text to create a new routine
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get createEditRoutineButtonCreateRoutine;

  /// Title for the dialog to add an exercise to a routine
  ///
  /// In en, this message translates to:
  /// **'Add \"{exerciseName}\"'**
  String addExerciseDialogTitle(String exerciseName);

  /// Label for number of sets input field in add exercise dialog
  ///
  /// In en, this message translates to:
  /// **'Number of Sets'**
  String get addExerciseDialogSetsLabel;

  /// Validation error for empty sets count
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get addExerciseDialogSetsErrorEmpty;

  /// Validation error for invalid sets count
  ///
  /// In en, this message translates to:
  /// **'Must be a positive number'**
  String get addExerciseDialogSetsErrorInvalid;

  /// Label for notes input field in add exercise dialog
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get addExerciseDialogNotesLabel;

  /// Hint text for notes input field in add exercise dialog
  ///
  /// In en, this message translates to:
  /// **'E.g., focus on form, pyramid sets'**
  String get addExerciseDialogNotesHint;

  /// Cancel button in add exercise dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addExerciseDialogButtonCancel;

  /// Add button in add exercise dialog
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExerciseDialogButtonAdd;

  /// Title for editing an exercise within a routine
  ///
  /// In en, this message translates to:
  /// **'Edit \"{exerciseName}\"'**
  String editExerciseDialogTitle(String exerciseName);

  /// Update button in edit exercise dialog
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get editExerciseDialogButtonUpdate;

  /// App bar title for exercise explorer when in selection mode
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get exerciseExplorerScreenTitleSelect;

  /// App bar title for exercise explorer when browsing
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseExplorerScreenTitleLibrary;

  /// Error message when exercises fail to load in explorer
  ///
  /// In en, this message translates to:
  /// **'Error loading exercises: {message}'**
  String exerciseExplorerErrorLoad(String message);

  /// Message shown when exercise library is empty
  ///
  /// In en, this message translates to:
  /// **'No exercises found in the library yet. Content is being added!'**
  String get exerciseExplorerEmpty;

  /// Button to retry fetching exercises
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get exerciseExplorerButtonTryAgain;

  /// Message shown while loading exercises
  ///
  /// In en, this message translates to:
  /// **'Loading exercises...'**
  String get exerciseExplorerLoading;

  /// Button on dashboard to send test notifications
  ///
  /// In en, this message translates to:
  /// **'Send Test Notifications'**
  String get dashboardButtonSendTestNotifications;

  /// Tooltip for the back button on the league screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get leagueScreenButtonBackTooltip;

  /// Title for the leaderboard section on the league screen
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get leagueScreenLeaderboardTitle;

  /// Error message when loading league data fails
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String leagueScreenErrorLoad(String errorMessage);

  /// Message shown when a league has no players
  ///
  /// In en, this message translates to:
  /// **'No players in this league yet.'**
  String get leagueScreenNoPlayers;

  /// Button text to retry loading league data
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get leagueScreenButtonTryAgain;

  /// Title for the related information section in notification details
  ///
  /// In en, this message translates to:
  /// **'Related Information:'**
  String get notificationDetailRelatedInfoTitle;

  /// Label for related entity type in notification details
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get notificationDetailRelatedInfoTypeLabel;

  /// Label for related entity ID in notification details
  ///
  /// In en, this message translates to:
  /// **'ID:'**
  String get notificationDetailRelatedInfoIdLabel;

  /// Status indicating a notification has been read
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationDetailStatusRead;

  /// Snackbar message after a notification is removed
  ///
  /// In en, this message translates to:
  /// **'{notificationTitle} removed.'**
  String notificationListItemSnackbarRemoved(String notificationTitle);

  /// Action text to undo a notification removal
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get notificationListItemSnackbarUndo;

  /// Text shown on dismissible background for deleting notification
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notificationListItemDismissDelete;

  /// Title for the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get profileScreenLogoutConfirmTitle;

  /// Message in the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileScreenLogoutConfirmMessage;

  /// Cancel button in the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileScreenLogoutConfirmButtonCancel;

  /// Log out button in the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileScreenLogoutConfirmButtonLogOut;

  /// Snackbar message if logging out fails
  ///
  /// In en, this message translates to:
  /// **'Error logging out: {errorDetails}'**
  String profileScreenLogoutErrorSnackbar(String errorDetails);

  /// Fallback name if user's display name or username is not set
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileScreenNameFallbackUser;

  /// Label for followers count on profile screen
  ///
  /// In en, this message translates to:
  /// **'FOLLOWERS'**
  String get profileScreenStatLabelFollowers;

  /// Label for following count on profile screen
  ///
  /// In en, this message translates to:
  /// **'FOLLOWING'**
  String get profileScreenStatLabelFollowing;

  /// Label for best streak on profile screen
  ///
  /// In en, this message translates to:
  /// **'BEST STREAK'**
  String get profileScreenStatLabelBestStreak;

  /// Label for weight on profile screen
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get profileScreenStatLabelWeight;

  /// Unit for kilograms
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get profileScreenUnitKg;

  /// Prefix for fitness goal on profile screen
  ///
  /// In en, this message translates to:
  /// **'GOAL: '**
  String get profileScreenGoalLabel;

  /// Prefix for last training date on profile screen
  ///
  /// In en, this message translates to:
  /// **'LAST TRAINING: '**
  String get profileScreenLastTrainingLabel;

  /// Title for rewards section on profile screen
  ///
  /// In en, this message translates to:
  /// **'REWARDS'**
  String get profileScreenRewardsTitle;

  /// Message when user has no rewards
  ///
  /// In en, this message translates to:
  /// **'No rewards unlocked yet. Keep training!'**
  String get profileScreenNoRewards;

  /// Title for user's posts section on profile screen
  ///
  /// In en, this message translates to:
  /// **'MY POSTS'**
  String get profileScreenMyPostsTitle;

  /// Message when user has no posts
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any posts yet.'**
  String get profileScreenNoPosts;

  /// Button text to edit profile
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get profileScreenButtonEditProfile;

  /// Button text to log out
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get profileScreenButtonLogOut;

  /// Error message when profile loading fails on profile screen
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {errorMessage}'**
  String profileScreenErrorLoadProfile(String errorMessage);

  /// Generic error message for profile screen
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred loading your profile.'**
  String get profileScreenErrorUnexpected;

  /// Label showing the post type when editing
  ///
  /// In en, this message translates to:
  /// **'Post Type: {postType}'**
  String createPostScreenLabelPostType(String postType);

  /// Segmented button option for standard post type
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get createPostSegmentStandard;

  /// Segmented button option for routine share post type
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get createPostSegmentRoutine;

  /// Segmented button option for record claim post type
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get createPostSegmentRecord;

  /// Label for shared routine section when editing
  ///
  /// In en, this message translates to:
  /// **'Shared Routine:'**
  String get createPostLabelSharedRoutine;

  /// Error text if routine details are not available for shared routine
  ///
  /// In en, this message translates to:
  /// **'Routine details unavailable'**
  String get createPostErrorRoutineUnavailable;

  /// Suffix for exercise count in shared routine display
  ///
  /// In en, this message translates to:
  /// **' exercises'**
  String get createPostRoutineExerciseCountSuffix;

  /// Label for read-only record details when editing
  ///
  /// In en, this message translates to:
  /// **'Record Details (Read-only):'**
  String get createPostLabelRecordDetailsReadOnly;

  /// Prefix for exercise name in record details
  ///
  /// In en, this message translates to:
  /// **'Exercise: '**
  String get createPostLabelRecordExercise;

  /// Prefix for weight in record details
  ///
  /// In en, this message translates to:
  /// **'Weight: '**
  String get createPostLabelRecordWeight;

  /// Suffix for kilograms unit
  ///
  /// In en, this message translates to:
  /// **' kg'**
  String get createPostUnitKgSuffix;

  /// Prefix for repetitions in record details
  ///
  /// In en, this message translates to:
  /// **'Reps: '**
  String get createPostLabelRecordReps;

  /// Prefix for video URL in record details
  ///
  /// In en, this message translates to:
  /// **'Video: '**
  String get createPostLabelRecordVideo;

  /// Label for record details section when creating a new record claim
  ///
  /// In en, this message translates to:
  /// **'Record Details:'**
  String get createPostLabelRecordDetails;

  /// Hint text for exercise selection in record claim
  ///
  /// In en, this message translates to:
  /// **'Select Exercise*'**
  String get createPostHintSelectExercise;

  /// Hint text for weight input in record claim
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)*'**
  String get createPostHintRecordWeight;

  /// Validation error for weight in record claim
  ///
  /// In en, this message translates to:
  /// **'Invalid weight'**
  String get createPostErrorRecordWeightInvalid;

  /// Hint text for repetitions input in record claim
  ///
  /// In en, this message translates to:
  /// **'Repetitions*'**
  String get createPostHintRecordReps;

  /// Validation error for repetitions in record claim
  ///
  /// In en, this message translates to:
  /// **'Invalid repetitions'**
  String get createPostErrorRecordRepsInvalid;

  /// Hint text for video URL input in record claim
  ///
  /// In en, this message translates to:
  /// **'Video URL (optional)'**
  String get createPostHintRecordVideoUrl;

  /// Validation error for video URL in record claim
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get createPostErrorRecordVideoUrlInvalid;

  /// Label for image attachment when editing and an image exists
  ///
  /// In en, this message translates to:
  /// **'Attach Image (Optional - Replaces Existing)'**
  String get createPostLabelAttachImageOptionalReplace;

  /// Label for image attachment when creating new or no existing image
  ///
  /// In en, this message translates to:
  /// **'Attach Image (Optional)'**
  String get createPostLabelAttachImageOptional;

  /// Button text to add an image to the post
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get createPostButtonAddImage;

  /// Tooltip for removing a newly selected image
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get createPostTooltipRemoveImage;

  /// Tooltip for removing an existing image when editing
  ///
  /// In en, this message translates to:
  /// **'Remove Existing Image'**
  String get createPostTooltipRemoveExistingImage;

  /// Toggle switch label to enable/disable comments
  ///
  /// In en, this message translates to:
  /// **'Enable Comments'**
  String get createPostToggleEnableComments;

  /// Subtitle when comments are enabled
  ///
  /// In en, this message translates to:
  /// **'Users can comment on this post'**
  String get createPostCommentsEnabledSubtitle;

  /// Subtitle when comments are disabled
  ///
  /// In en, this message translates to:
  /// **'Comments are disabled'**
  String get createPostCommentsDisabledSubtitle;

  /// Hint text for the main post content field
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get createPostHintTextContent;

  /// Validation error if standard post has no content and no image
  ///
  /// In en, this message translates to:
  /// **'Post content or image is required.'**
  String get createPostErrorContentOrImageRequired;

  /// App bar title when editing a post
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get createPostAppBarTitleEdit;

  /// App bar title when sharing a routine as a post
  ///
  /// In en, this message translates to:
  /// **'Share Routine'**
  String get createPostAppBarTitleShareRoutine;

  /// App bar title when creating a new post
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPostAppBarTitleCreate;

  /// Button text to save changes when editing a post
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get createPostButtonSaveChanges;

  /// Button text to publish a new post
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get createPostButtonPublish;

  /// Snackbar message on successful post creation/update
  ///
  /// In en, this message translates to:
  /// **'Post {status} successfully!'**
  String createPostSnackbarSuccess(String status);

  /// Snackbar message on post creation/update failure
  ///
  /// In en, this message translates to:
  /// **'Error: {errorDetails}'**
  String createPostSnackbarError(String errorDetails);

  /// Status text for successful post update
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get createPostStatusUpdated;

  /// Status text for successful post creation
  ///
  /// In en, this message translates to:
  /// **'published'**
  String get createPostStatusPublished;

  /// Loading message when updating a post
  ///
  /// In en, this message translates to:
  /// **'Updating post...'**
  String get createPostLoadingUpdating;

  /// Loading message when publishing a new post
  ///
  /// In en, this message translates to:
  /// **'Publishing post...'**
  String get createPostLoadingPublishing;

  /// Error message if user is not logged in during post creation
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get createPostErrorUserNotLoggedIn;

  /// Error message if content and media are empty for standard post
  ///
  /// In en, this message translates to:
  /// **'Post content cannot be empty for a standard post without media.'**
  String get createPostErrorContentEmptyStandard;

  /// Error message if user profile fetch fails during post creation
  ///
  /// In en, this message translates to:
  /// **'Could not fetch user profile.'**
  String get createPostErrorFetchProfile;

  /// Error message if media upload fails during post creation
  ///
  /// In en, this message translates to:
  /// **'Failed to upload media.'**
  String get createPostErrorUploadMedia;

  /// Title text when the explore feed is empty
  ///
  /// In en, this message translates to:
  /// **'Nothing to explore yet.'**
  String get exploreScreenEmptyTitle;

  /// Subtitle text encouraging users to post when explore feed is empty
  ///
  /// In en, this message translates to:
  /// **'Be the first to share something!'**
  String get exploreScreenEmptySubtitle;

  /// Error message when loading posts for explore feed fails
  ///
  /// In en, this message translates to:
  /// **'Error loading posts: {message}'**
  String exploreScreenErrorLoad(String message);

  /// Button text to retry loading posts for explore feed
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get exploreScreenButtonTryAgain;

  /// Tooltip for the floating action button to create a new post
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get exploreScreenFabTooltipCreatePost;

  /// App bar title for the followers list screen
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followListScreenTitleFollowers;

  /// App bar title for the following list screen
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followListScreenTitleFollowing;

  /// Error message when loading follow list fails
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String followListScreenErrorLoad(String message);

  /// Message shown when the followers list is empty
  ///
  /// In en, this message translates to:
  /// **'This user has no followers yet.'**
  String get followListScreenEmptyFollowers;

  /// Message shown when the following list is empty
  ///
  /// In en, this message translates to:
  /// **'This user is not following anyone yet.'**
  String get followListScreenEmptyFollowing;

  /// Button text to retry loading follow list
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get followListScreenButtonTryAgain;

  /// Generic error message for follow list screen
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get followListScreenErrorUnexpected;

  /// Fallback app bar title for post detail screen
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postDetailScreenAppBarTitleFallback;

  /// Menu option to edit a post
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get postDetailMenuEditPost;

  /// Menu option to disable comments on a post
  ///
  /// In en, this message translates to:
  /// **'Disable Comments'**
  String get postDetailMenuDisableComments;

  /// Menu option to enable comments on a post
  ///
  /// In en, this message translates to:
  /// **'Enable Comments'**
  String get postDetailMenuEnableComments;

  /// Menu option to delete a post
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get postDetailMenuDeletePost;

  /// Title of the confirm delete dialog for a post
  ///
  /// In en, this message translates to:
  /// **'Delete Post?'**
  String get postDetailDeleteConfirmTitle;

  /// Confirmation message for deleting a post
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post? This action cannot be undone and will remove all associated comments and media.'**
  String get postDetailDeleteConfirmMessage;

  /// Cancel button in delete post confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get postDetailDeleteConfirmButtonCancel;

  /// Delete button in delete post confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get postDetailDeleteConfirmButtonDelete;

  /// Generic error snackbar message for post detail screen
  ///
  /// In en, this message translates to:
  /// **'Error: {errorDetails}'**
  String postDetailSnackbarErrorGeneric(String errorDetails);

  /// Snackbar message after a post is successfully deleted
  ///
  /// In en, this message translates to:
  /// **'Post \"{postId}\" has been deleted.'**
  String postDetailSnackbarPostDeleted(String postId);

  /// Error message when post detail cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Post not found or could not be loaded.'**
  String get postDetailErrorPostNotFound;

  /// Message shown while loading post details
  ///
  /// In en, this message translates to:
  /// **'Loading post details...'**
  String get postDetailLoading;

  /// Suffix for singular like count
  ///
  /// In en, this message translates to:
  /// **' Like'**
  String get postDetailLikesSuffixSingular;

  /// Suffix for plural like count
  ///
  /// In en, this message translates to:
  /// **' Likes'**
  String get postDetailLikesSuffixPlural;

  /// Suffix for singular comment count
  ///
  /// In en, this message translates to:
  /// **' Comment'**
  String get postDetailCommentsSuffixSingular;

  /// Suffix for plural comment count
  ///
  /// In en, this message translates to:
  /// **' Comments'**
  String get postDetailCommentsSuffixPlural;

  /// Title for the comments section in post detail
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get postDetailCommentsSectionTitle;

  /// Message shown when comments are disabled for a post
  ///
  /// In en, this message translates to:
  /// **'Comments are disabled for this post.'**
  String get postDetailCommentsDisabledMessage;

  /// Message shown when a post has no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get postDetailCommentsEmptyMessage;

  /// Hint text for the comment input field
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get postDetailCommentInputHint;

  /// Button text to validate a record claim
  ///
  /// In en, this message translates to:
  /// **'VALIDATE'**
  String get postDetailButtonValidate;

  /// Button text to dispute a record claim
  ///
  /// In en, this message translates to:
  /// **'DISPUTE'**
  String get postDetailButtonDispute;

  /// Record claim status: Verified
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get recordStatusVerified;

  /// Record claim status: Rejected
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get recordStatusRejected;

  /// Record claim status: Expired
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get recordStatusExpired;

  /// Record claim status: Pending
  ///
  /// In en, this message translates to:
  /// **'AWAITS VOTING'**
  String get recordStatusPending;

  /// Record claim status: Contested
  ///
  /// In en, this message translates to:
  /// **'CONTESTED'**
  String get recordStatusContested;

  /// Record claim status: Unknown
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get recordStatusUnknown;

  /// Button text to watch proof video for a record claim
  ///
  /// In en, this message translates to:
  /// **'Watch Proof'**
  String get postDetailButtonWatchProof;

  /// Fallback app bar title for viewing another user's profile
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get viewUserProfileAppBarTitleFallback;

  /// Error message if current user is not authenticated when viewing a profile
  ///
  /// In en, this message translates to:
  /// **'User not authenticated.'**
  String get viewUserProfileErrorNotAuth;

  /// Error message when failing to load the target user's profile
  ///
  /// In en, this message translates to:
  /// **'Could not load profile: {message}'**
  String viewUserProfileErrorLoadProfile(String message);

  /// Error message during initialization of view user profile screen
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize: {message}'**
  String viewUserProfileErrorInit(String message);

  /// Error message for invalid follow/unfollow operation (e.g., self-follow)
  ///
  /// In en, this message translates to:
  /// **'Cannot follow/unfollow: Invalid operation.'**
  String get viewUserProfileErrorFollowInvalidOp;

  /// Generic error message for follow/unfollow failure
  ///
  /// In en, this message translates to:
  /// **'Failed to {action}: {errorDetails}'**
  String viewUserProfileErrorFollowGeneric(String action, String errorDetails);

  /// Action part of follow/unfollow error: follow
  ///
  /// In en, this message translates to:
  /// **'follow'**
  String get viewUserProfileErrorFollowActionFollow;

  /// Action part of follow/unfollow error: unfollow
  ///
  /// In en, this message translates to:
  /// **'unfollow'**
  String get viewUserProfileErrorFollowActionUnfollow;

  /// Error message if trying to follow/unfollow from an invalid state
  ///
  /// In en, this message translates to:
  /// **'Cannot process follow/unfollow in current state: {currentState}'**
  String viewUserProfileErrorInvalidStateFollow(String currentState);

  /// Label for level stat on view user profile screen
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get viewUserProfileStatLabelLevel;

  /// Button text to unfollow a user
  ///
  /// In en, this message translates to:
  /// **'UNFOLLOW'**
  String get viewUserProfileButtonUnfollow;

  /// Button text to follow a user
  ///
  /// In en, this message translates to:
  /// **'FOLLOW'**
  String get viewUserProfileButtonFollow;

  /// Title for the posts section on view user profile screen
  ///
  /// In en, this message translates to:
  /// **'User\'s Posts'**
  String get viewUserProfilePostsTitle;

  /// Message shown when the viewed user has no posts
  ///
  /// In en, this message translates to:
  /// **'Posts by @{username} will appear here.'**
  String viewUserProfileNoPosts(String username);

  /// Error message when viewed user's profile is not available
  ///
  /// In en, this message translates to:
  /// **'Profile not available.'**
  String get viewUserProfileErrorProfileNotAvailable;

  /// Title for the edit comment dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get commentListItemEditDialogTitle;

  /// Title for the delete comment confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Comment?'**
  String get commentListItemDeleteDialogTitle;

  /// Hint text for the comment input field in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Your comment...'**
  String get commentListItemEditDialogHint;

  /// Confirmation message for deleting a comment
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment? This action cannot be undone.'**
  String get commentListItemDeleteDialogMessage;

  /// Cancel button in comment dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commentListItemDialogButtonCancel;

  /// Save button in edit comment dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commentListItemDialogButtonSave;

  /// Delete button in delete comment dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentListItemDialogButtonDelete;

  /// Snackbar message after a comment is deleted
  ///
  /// In en, this message translates to:
  /// **'Comment deleted.'**
  String get commentListItemSnackbarDeleted;

  /// Menu option to edit a comment
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commentListItemMenuEdit;

  /// Menu option to delete a comment
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentListItemMenuDelete;

  /// Fallback app bar title for active workout screen
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkoutAppBarTitleFallback;

  /// Title for cancel workout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel Workout?'**
  String get activeWorkoutDialogCancelTitle;

  /// Title for complete workout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Complete Workout?'**
  String get activeWorkoutDialogCompleteTitle;

  /// Message for cancel workout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this workout? Progress will not be saved.'**
  String get activeWorkoutDialogCancelMessage;

  /// Message for complete workout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish and save this workout?'**
  String get activeWorkoutDialogCompleteMessage;

  /// No button in cancel workout dialog
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get activeWorkoutDialogButtonNo;

  /// Confirm cancel button in cancel workout dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get activeWorkoutDialogButtonYesCancel;

  /// No/Continue button in complete workout dialog
  ///
  /// In en, this message translates to:
  /// **'No, Continue'**
  String get activeWorkoutDialogButtonNoContinue;

  /// Confirm complete button in complete workout dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Complete'**
  String get activeWorkoutDialogButtonYesComplete;

  /// Generic loading message for active workout screen
  ///
  /// In en, this message translates to:
  /// **'Loading Workout...'**
  String get activeWorkoutLoading;

  /// Loading message when starting a new workout
  ///
  /// In en, this message translates to:
  /// **'Starting new workout...'**
  String get activeWorkoutLoadingStartingNew;

  /// Message when no active workout is found
  ///
  /// In en, this message translates to:
  /// **'No active workout found.'**
  String get activeWorkoutNoneMessage;

  /// Button text to navigate back if no active workout
  ///
  /// In en, this message translates to:
  /// **'Back to Routines'**
  String get activeWorkoutButtonBackToRoutines;

  /// Error message if an active workout has no exercises
  ///
  /// In en, this message translates to:
  /// **'This workout has no exercises.'**
  String get activeWorkoutErrorNoExercises;

  /// Button text to add first exercise to an empty workout
  ///
  /// In en, this message translates to:
  /// **'Add First Exercise'**
  String get activeWorkoutButtonAddFirstExercise;

  /// Button text to finish an empty workout
  ///
  /// In en, this message translates to:
  /// **'Finish Empty Workout'**
  String get activeWorkoutButtonFinishEmpty;

  /// Error message if a specific exercise has no sets during workout
  ///
  /// In en, this message translates to:
  /// **'Error: Exercise \'\'{exerciseName}\'\' has no sets.'**
  String activeWorkoutErrorExerciseNoSets(String exerciseName);

  /// Help text for error when exercise has no sets
  ///
  /// In en, this message translates to:
  /// **'Please edit the routine or contact support.'**
  String get activeWorkoutErrorExerciseNoSetsHelp;

  /// Button text to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get activeWorkoutButtonGoBack;

  /// Generic unexpected error message for active workout screen
  ///
  /// In en, this message translates to:
  /// **'An unexpected state occurred. Please restart.'**
  String get activeWorkoutErrorUnexpected;

  /// Title on workout complete screen if user leveled up
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get workoutCompleteTitleLevelUp;

  /// Default title on workout complete screen
  ///
  /// In en, this message translates to:
  /// **'Workout Complete!'**
  String get workoutCompleteTitleDefault;

  /// Subtitle on workout complete screen if user leveled up
  ///
  /// In en, this message translates to:
  /// **'You reached Level {level}!'**
  String workoutCompleteSubtitleLevelUp(int level);

  /// Workout duration stat on complete screen
  ///
  /// In en, this message translates to:
  /// **'Duration: {durationMinutes} min'**
  String workoutCompleteStatDuration(int durationMinutes);

  /// Workout total volume stat on complete screen
  ///
  /// In en, this message translates to:
  /// **'Total Volume: {volume} KG'**
  String workoutCompleteStatVolume(String volume);

  /// XP gained stat on workout complete screen
  ///
  /// In en, this message translates to:
  /// **'+{xpGained} XP GAINED'**
  String workoutCompleteStatXpGained(int xpGained);

  /// Label for level in XP bar on workout complete screen
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String workoutCompleteXpBarLabelLevel(int level);

  /// XP progress text in XP bar on workout complete screen
  ///
  /// In en, this message translates to:
  /// **'{currentXp}/{totalXp} XP'**
  String workoutCompleteXpBarText(String currentXp, String totalXp);

  /// Button text on workout complete screen to dismiss
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get workoutCompleteButtonAwesome;

  /// Title for dialog to set weight for a set
  ///
  /// In en, this message translates to:
  /// **'Set Weight (KG)'**
  String get currentSetDisplayWeightDialogTitle;

  /// Hint text for weight input in set weight dialog
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get currentSetDisplayWeightDialogHint;

  /// Cancel button in set weight dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get currentSetDisplayWeightDialogButtonCancel;

  /// Set button in set weight dialog
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get currentSetDisplayWeightDialogButtonSet;

  /// Prefix for set number display
  ///
  /// In en, this message translates to:
  /// **'SET '**
  String get currentSetDisplaySetLabelPrefix;

  /// Prefix for weight display
  ///
  /// In en, this message translates to:
  /// **'WEIGHT: '**
  String get currentSetDisplayWeightLabelPrefix;

  /// Suffix for kilograms unit
  ///
  /// In en, this message translates to:
  /// **' KG'**
  String get currentSetDisplayUnitKgSuffix;

  /// Suffix for repetitions display
  ///
  /// In en, this message translates to:
  /// **' REPETITIONS'**
  String get currentSetDisplayRepsLabelSuffix;

  /// Help text for RPE sliders
  ///
  /// In en, this message translates to:
  /// **'Describe how hard it was to make a repetition\non a 0-10 scale.'**
  String get currentSetDisplayRpeHelpText;

  /// Placeholder text when no reps are set for RPE sliders
  ///
  /// In en, this message translates to:
  /// **'Add reps'**
  String get currentSetDisplayNoRepsPlaceholder;

  /// Button text to navigate to previous set
  ///
  /// In en, this message translates to:
  /// **'< PREV. SET'**
  String get currentSetDisplayButtonPrevSet;

  /// Button text to finish workout when on the last set
  ///
  /// In en, this message translates to:
  /// **'FINISH WORKOUT'**
  String get currentSetDisplayButtonFinishWorkout;

  /// Button text to navigate to next exercise
  ///
  /// In en, this message translates to:
  /// **'NEXT EXERCISE >'**
  String get currentSetDisplayButtonNextExercise;

  /// Button text to navigate to next set
  ///
  /// In en, this message translates to:
  /// **'NEXT SET >'**
  String get currentSetDisplayButtonNextSet;

  /// Message shown when progress screen data is initially loading
  ///
  /// In en, this message translates to:
  /// **'Loading progress data...'**
  String get progressScreenLoadingData;

  /// Message shown when progress screen data is being refreshed
  ///
  /// In en, this message translates to:
  /// **'Refreshing progress data...'**
  String get progressScreenRefreshingData;

  /// Error message if user is not authenticated during refresh
  ///
  /// In en, this message translates to:
  /// **'User not authenticated. Cannot refresh.'**
  String get progressScreenErrorNotAuthRefresh;

  /// Error message if user profile is not found during refresh
  ///
  /// In en, this message translates to:
  /// **'User profile not found during refresh.'**
  String get progressScreenErrorProfileNotFoundRefresh;

  /// Error message when data refresh fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh data: {errorMessage}'**
  String progressScreenErrorFailedRefresh(String errorMessage);

  /// Message when loading workout stats specifically
  ///
  /// In en, this message translates to:
  /// **'Loading workout stats...'**
  String get progressScreenLoadingWorkoutStats;

  /// Message when refreshing workout stats specifically
  ///
  /// In en, this message translates to:
  /// **'Refreshing workout stats...'**
  String get progressScreenRefreshingWorkoutStats;

  /// Error message when processing workout data fails
  ///
  /// In en, this message translates to:
  /// **'Failed to process workout data: {errorMessage}'**
  String progressScreenErrorFailedProcessWorkoutData(String errorMessage);

  /// Text indicating XP needed for next level
  ///
  /// In en, this message translates to:
  /// **'{xp} XP TO NEXT LEVEL!'**
  String progressScreenXpToNextLevel(int xp);

  /// Title for the muscle map volume section
  ///
  /// In en, this message translates to:
  /// **'VOLUME (LAST 7 DAYS - SETS)'**
  String get progressScreenVolumeTitle;

  /// Message when no volume data is available for muscle map
  ///
  /// In en, this message translates to:
  /// **'No workout data for the last 7 days to display on muscle map.'**
  String get progressScreenNoVolumeData;

  /// Title for RPE trend section
  ///
  /// In en, this message translates to:
  /// **'EXERTION (RPE TREND - LAST {maxWorkouts} WORKOUTS)'**
  String progressScreenRpeTrendTitle(int maxWorkouts);

  /// Message when no RPE data is available
  ///
  /// In en, this message translates to:
  /// **'No RPE data logged recently for any exercise.'**
  String get progressScreenNoRpeData;

  /// Label prefix for average RPE value
  ///
  /// In en, this message translates to:
  /// **'AVG. RPE - '**
  String get progressScreenAvgRpeLabel;

  /// Title for strength (weight) trend section
  ///
  /// In en, this message translates to:
  /// **'STRENGTH (WEIGHT TREND - LAST {maxWorkouts} WORKOUTS)'**
  String progressScreenStrengthTrendTitle(int maxWorkouts);

  /// Message when no weight data is available for trend
  ///
  /// In en, this message translates to:
  /// **'No weight data logged recently for any exercise.'**
  String get progressScreenNoWeightData;

  /// Label prefix for average weight value
  ///
  /// In en, this message translates to:
  /// **'AVG. WEIGHT - '**
  String get progressScreenAvgWeightLabel;

  /// Title for the advice section
  ///
  /// In en, this message translates to:
  /// **'ADVICE'**
  String get progressScreenAdviceTitle;

  /// Message when no advice notifications are available
  ///
  /// In en, this message translates to:
  /// **'No new advice at the moment. Keep up the great work!'**
  String get progressScreenNoAdvice;

  /// Error message when loading advice fails
  ///
  /// In en, this message translates to:
  /// **'Error loading advice: {message}'**
  String progressScreenErrorLoadAdvice(String message);

  /// Message shown while loading advice
  ///
  /// In en, this message translates to:
  /// **'Loading advice...'**
  String get progressScreenLoadingAdvice;

  /// Button text to send test advice notifications
  ///
  /// In en, this message translates to:
  /// **'Send Test Advice'**
  String get progressScreenButtonSendTestAdvice;

  /// Button text to retry loading data on error
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get progressScreenButtonTryAgain;

  /// Error message when profile loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {errorMessage}'**
  String progressScreenErrorLoadingProfile(String errorMessage);

  /// Message when no progress data is available
  ///
  /// In en, this message translates to:
  /// **'No progress data available yet. Start working out!'**
  String get progressScreenNoData;

  /// Label for level, e.g., LVL 5
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String progressScreenLevelLabel(int level);

  /// Text showing XP progress, e.g., 150/200 XP
  ///
  /// In en, this message translates to:
  /// **'{currentXp}/{totalXp} XP'**
  String progressScreenXpProgressText(String currentXp, String totalXp);

  /// Placeholder for exercise name if not found, e.g., EXERCISE ABCDE...
  ///
  /// In en, this message translates to:
  /// **'EXERCISE {placeholder}'**
  String progressScreenExercisePlaceholder(String placeholder);

  /// Unit for kilograms, short form
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get progressScreenKgUnit;

  /// Title overlay for a shared routine post card
  ///
  /// In en, this message translates to:
  /// **'SHARED ROUTINE'**
  String get postCardRoutineShareTitle;

  /// Author prefix for shared routine post card
  ///
  /// In en, this message translates to:
  /// **'by @{authorUsername}'**
  String postCardRoutineAuthorPrefix(String authorUsername);

  /// Label for exercises count in shared routine card (singular)
  ///
  /// In en, this message translates to:
  /// **'EXERCISE'**
  String get postCardRoutineExercisesLabel;

  /// Label for exercises count in shared routine card (plural)
  ///
  /// In en, this message translates to:
  /// **'EXERCISES'**
  String get postCardRoutineExercisesLabelPlural;

  /// Text when a shared routine has no scheduled days
  ///
  /// In en, this message translates to:
  /// **'NO SCHEDULE'**
  String get postCardRoutineNoSchedule;

  /// Label for scheduled days in shared routine card
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED DAYS'**
  String get postCardRoutineScheduledDaysLabel;

  /// Button text to add a shared routine to user's list
  ///
  /// In en, this message translates to:
  /// **'ADD TO MY LIST'**
  String get postCardRoutineButtonAddToList;

  /// Snackbar message if user tries to add routine without login
  ///
  /// In en, this message translates to:
  /// **'Please log in to add routines.'**
  String get postCardRoutineSnackbarLoginToAdd;

  /// Snackbar message if user tries to add their own routine
  ///
  /// In en, this message translates to:
  /// **'This is your routine already!'**
  String get postCardRoutineSnackbarAlreadyOwn;

  /// Snackbar message on successful routine addition
  ///
  /// In en, this message translates to:
  /// **'Routine added to your list!'**
  String get postCardRoutineSnackbarAdded;

  /// Snackbar message on error adding routine
  ///
  /// In en, this message translates to:
  /// **'Failed to add routine: {errorDetails}'**
  String postCardRoutineSnackbarErrorAdd(String errorDetails);

  /// Message indicating the shared routine belongs to the current user
  ///
  /// In en, this message translates to:
  /// **'This is your shared routine.'**
  String get postCardRoutineIsYours;

  /// Message prompting login to add a shared routine
  ///
  /// In en, this message translates to:
  /// **'Log in to add this routine.'**
  String get postCardRoutineLoginToAdd;

  /// Title for a record claim post card
  ///
  /// In en, this message translates to:
  /// **'RECORD CLAIM'**
  String get postCardRecordClaimTitle;

  /// Fallback exercise name for record claim if not specified
  ///
  /// In en, this message translates to:
  /// **'EXERCISE RECORD'**
  String get postCardRecordExerciseNameFallback;

  /// Format for displaying reps and weight in record claim
  ///
  /// In en, this message translates to:
  /// **'{reps} REPS / {weight} KG'**
  String postCardRecordRepsKgFormat(String reps, String weight);

  /// Fallback for reps if not available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get postCardRecordRepsFallback;

  /// Fallback for weight if not available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get postCardRecordWeightFallback;

  /// No description provided for @achievementEarlyBirdName.
  ///
  /// In en, this message translates to:
  /// **'EARLY BIRD'**
  String get achievementEarlyBirdName;

  /// No description provided for @achievementEarlyBirdDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the club! Thanks for joining MuscleUP.'**
  String get achievementEarlyBirdDescription;

  /// No description provided for @achievementFirstWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'FIRST STEP'**
  String get achievementFirstWorkoutName;

  /// No description provided for @achievementFirstWorkoutDescription.
  ///
  /// In en, this message translates to:
  /// **'You completed your first workout! Keep it up!'**
  String get achievementFirstWorkoutDescription;

  /// No description provided for @achievementConsistentKing10Name.
  ///
  /// In en, this message translates to:
  /// **'STREAK STAR (10)'**
  String get achievementConsistentKing10Name;

  /// No description provided for @achievementConsistentKing10Description.
  ///
  /// In en, this message translates to:
  /// **'10-day workout streak! You are on fire!'**
  String get achievementConsistentKing10Description;

  /// No description provided for @achievementConsistentKing30Name.
  ///
  /// In en, this message translates to:
  /// **'CONSISTENT KING (30)'**
  String get achievementConsistentKing30Name;

  /// No description provided for @achievementConsistentKing30Description.
  ///
  /// In en, this message translates to:
  /// **'30-day workout streak! Unstoppable!'**
  String get achievementConsistentKing30Description;

  /// No description provided for @achievementVolumeStarterName.
  ///
  /// In en, this message translates to:
  /// **'VOLUME STARTER'**
  String get achievementVolumeStarterName;

  /// No description provided for @achievementVolumeStarterDescription.
  ///
  /// In en, this message translates to:
  /// **'Lifted over 10,000 KG in total volume!'**
  String get achievementVolumeStarterDescription;

  /// No description provided for @achievementVolumeProName.
  ///
  /// In en, this message translates to:
  /// **'VOLUME PRO'**
  String get achievementVolumeProName;

  /// No description provided for @achievementVolumeProDescription.
  ///
  /// In en, this message translates to:
  /// **'Lifted over 100,000 KG in total volume! Incredible strength!'**
  String get achievementVolumeProDescription;

  /// No description provided for @achievementLevel5ReachedName.
  ///
  /// In en, this message translates to:
  /// **'LEVEL 5 REACHED'**
  String get achievementLevel5ReachedName;

  /// No description provided for @achievementLevel5ReachedDescription.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on reaching level 5!'**
  String get achievementLevel5ReachedDescription;

  /// No description provided for @achievementLevel10ReachedName.
  ///
  /// In en, this message translates to:
  /// **'LEVEL 10 REACHED'**
  String get achievementLevel10ReachedName;

  /// No description provided for @achievementLevel10ReachedDescription.
  ///
  /// In en, this message translates to:
  /// **'Wow! Level 10! You\'re a true MuscleUP enthusiast!'**
  String get achievementLevel10ReachedDescription;

  /// No description provided for @achievementPersonalRecordSetName.
  ///
  /// In en, this message translates to:
  /// **'NEW RECORD: {detail}!'**
  String achievementPersonalRecordSetName(String detail);

  /// No description provided for @achievementPersonalRecordSetDescription.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on setting a new personal record for {detail}!'**
  String achievementPersonalRecordSetDescription(String detail);

  /// No description provided for @achievementConditionStreak.
  ///
  /// In en, this message translates to:
  /// **'Current best streak: {currentStreak}/{targetStreak} days.'**
  String achievementConditionStreak(int currentStreak, int targetStreak);

  /// No description provided for @achievementConditionVolume.
  ///
  /// In en, this message translates to:
  /// **'Requires total volume tracking in profile.'**
  String get achievementConditionVolume;

  /// No description provided for @achievementConditionLevel.
  ///
  /// In en, this message translates to:
  /// **'Current level: {currentLevel}/{targetLevel}.'**
  String achievementConditionLevel(int currentLevel, int targetLevel);

  /// Placeholder text for muscle groups while exercise data is loading
  ///
  /// In en, this message translates to:
  /// **'Loading muscle groups...'**
  String get currentSetDisplayMuscleGroupsLoading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
