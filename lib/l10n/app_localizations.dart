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
