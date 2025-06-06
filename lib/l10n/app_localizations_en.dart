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
  String get authGateFinalizingAccountSetup => 'Finalizing account setup...';

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

  @override
  String get userRoutinesScreenTitle => 'My Routines';

  @override
  String userRoutinesErrorLoad(String message) {
    return 'Error loading routines: $message';
  }

  @override
  String get userRoutinesEmptyTitle => 'You have no routines yet.';

  @override
  String get userRoutinesEmptySubtitle =>
      'Create a routine to start organizing your workouts!';

  @override
  String get userRoutinesButtonCreateFirst => 'Create Your First Routine';

  @override
  String get userRoutinesFabNewRoutine => 'NEW ROUTINE';

  @override
  String get routineListItemMenuStartWorkout => 'Start Workout';

  @override
  String get routineListItemMenuEditRoutine => 'Edit Routine';

  @override
  String get routineListItemMenuShareRoutine => 'Share Routine';

  @override
  String get routineListItemMenuDeleteRoutine => 'Delete Routine';

  @override
  String get routineListItemDeleteConfirmTitle => 'Confirm Delete';

  @override
  String routineListItemDeleteConfirmMessage(String routineName) {
    return 'Are you sure you want to delete \"$routineName\"? This action cannot be undone.';
  }

  @override
  String get routineListItemDeleteConfirmButtonCancel => 'Cancel';

  @override
  String get routineListItemDeleteConfirmButtonDelete => 'Delete';

  @override
  String routineListItemSnackbarDeleted(String routineName) {
    return 'Routine \"$routineName\" deleted.';
  }

  @override
  String routineListItemSnackbarErrorDelete(String errorDetails) {
    return 'Error deleting routine: $errorDetails';
  }

  @override
  String get createEditRoutineScreenTitleEdit => 'Edit Routine';

  @override
  String get createEditRoutineScreenTitleCreate => 'Create Routine';

  @override
  String get createEditRoutineTooltipDelete => 'Delete Routine';

  @override
  String get createEditRoutineSnackbarFormErrors =>
      'Please correct the errors in the form.';

  @override
  String createEditRoutineSuccessMessage(String message) {
    return '$message';
  }

  @override
  String createEditRoutineErrorMessage(String errorDetails) {
    return 'Error: $errorDetails';
  }

  @override
  String get createEditRoutineStatusUpdated => 'Routine updated successfully!';

  @override
  String get createEditRoutineStatusCreated => 'Routine created successfully!';

  @override
  String get createEditRoutineStatusDeleted => 'Routine deleted successfully!';

  @override
  String get createEditRoutineErrorNameEmpty => 'Routine name cannot be empty.';

  @override
  String get createEditRoutineErrorNoExercises =>
      'Routine must have at least one exercise.';

  @override
  String get createEditRoutineErrorDeleteNew =>
      'Cannot delete a new or unsaved routine.';

  @override
  String get createEditRoutineLoadingMessageSaving => 'Saving routine...';

  @override
  String get createEditRoutineLoadingMessageDeleting => 'Deleting routine...';

  @override
  String get createEditRoutineNameLabel => 'Routine Name*';

  @override
  String get createEditRoutineNameErrorEmpty => 'Name cannot be empty';

  @override
  String get createEditRoutineDescriptionLabel => 'Description (optional)';

  @override
  String get createEditRoutineScheduledDaysLabel => 'Scheduled Days:';

  @override
  String createEditRoutineExercisesLabel(int count) {
    return 'Exercises ($count):';
  }

  @override
  String get createEditRoutineButtonAddExercise => 'Add';

  @override
  String get createEditRoutineNoExercisesPlaceholder =>
      'No exercises added yet. Tap \"Add\" to begin.';

  @override
  String get createEditRoutineButtonSaveChanges => 'Save Changes';

  @override
  String get createEditRoutineButtonCreateRoutine => 'Create Routine';

  @override
  String addExerciseDialogTitle(String exerciseName) {
    return 'Add \"$exerciseName\"';
  }

  @override
  String get addExerciseDialogSetsLabel => 'Number of Sets';

  @override
  String get addExerciseDialogSetsErrorEmpty => 'Cannot be empty';

  @override
  String get addExerciseDialogSetsErrorInvalid => 'Must be a positive number';

  @override
  String get addExerciseDialogNotesLabel => 'Notes (optional)';

  @override
  String get addExerciseDialogNotesHint => 'E.g., focus on form, pyramid sets';

  @override
  String get addExerciseDialogButtonCancel => 'Cancel';

  @override
  String get addExerciseDialogButtonAdd => 'Add Exercise';

  @override
  String editExerciseDialogTitle(String exerciseName) {
    return 'Edit \"$exerciseName\"';
  }

  @override
  String get editExerciseDialogButtonUpdate => 'Update';

  @override
  String get exerciseExplorerScreenTitleSelect => 'Select Exercise';

  @override
  String get exerciseExplorerScreenTitleLibrary => 'Exercise Library';

  @override
  String exerciseExplorerErrorLoad(String message) {
    return 'Error loading exercises: $message';
  }

  @override
  String get exerciseExplorerEmpty =>
      'No exercises found in the library yet. Content is being added!';

  @override
  String get exerciseExplorerButtonTryAgain => 'Try Again';

  @override
  String get exerciseExplorerLoading => 'Loading exercises...';

  @override
  String get dashboardButtonSendTestNotifications => 'Send Test Notifications';

  @override
  String get leagueScreenButtonBackTooltip => 'Back';

  @override
  String get leagueScreenLeaderboardTitle => 'LEADERBOARD';

  @override
  String leagueScreenErrorLoad(String errorMessage) {
    return 'Error: $errorMessage';
  }

  @override
  String get leagueScreenNoPlayers => 'No players in this league yet.';

  @override
  String get leagueScreenButtonTryAgain => 'Try Again';

  @override
  String get notificationDetailRelatedInfoTitle => 'Related Information:';

  @override
  String get notificationDetailRelatedInfoTypeLabel => 'Type:';

  @override
  String get notificationDetailRelatedInfoIdLabel => 'ID:';

  @override
  String get notificationDetailStatusRead => 'Read';

  @override
  String notificationListItemSnackbarRemoved(String notificationTitle) {
    return '$notificationTitle removed.';
  }

  @override
  String get notificationListItemSnackbarUndo => 'UNDO';

  @override
  String get notificationListItemDismissDelete => 'Delete';

  @override
  String get profileScreenLogoutConfirmTitle => 'Confirm Logout';

  @override
  String get profileScreenLogoutConfirmMessage =>
      'Are you sure you want to log out?';

  @override
  String get profileScreenLogoutConfirmButtonCancel => 'Cancel';

  @override
  String get profileScreenLogoutConfirmButtonLogOut => 'Log Out';

  @override
  String profileScreenLogoutErrorSnackbar(String errorDetails) {
    return 'Error logging out: $errorDetails';
  }

  @override
  String get profileScreenNameFallbackUser => 'User';

  @override
  String get profileScreenStatLabelFollowers => 'FOLLOWERS';

  @override
  String get profileScreenStatLabelFollowing => 'FOLLOWING';

  @override
  String get profileScreenStatLabelBestStreak => 'BEST STREAK';

  @override
  String get profileScreenStatLabelWeight => 'WEIGHT';

  @override
  String get profileScreenUnitKg => 'KG';

  @override
  String get profileScreenGoalLabel => 'GOAL: ';

  @override
  String get profileScreenLastTrainingLabel => 'LAST TRAINING: ';

  @override
  String get profileScreenRewardsTitle => 'REWARDS';

  @override
  String get profileScreenNoRewards =>
      'No rewards unlocked yet. Keep training!';

  @override
  String get profileScreenMyPostsTitle => 'MY POSTS';

  @override
  String get profileScreenNoPosts => 'You haven\'t made any posts yet.';

  @override
  String get profileScreenButtonEditProfile => 'EDIT PROFILE';

  @override
  String get profileScreenButtonLogOut => 'LOG OUT';

  @override
  String profileScreenErrorLoadProfile(String errorMessage) {
    return 'Error loading profile: $errorMessage';
  }

  @override
  String get profileScreenErrorUnexpected =>
      'An unexpected error occurred loading your profile.';

  @override
  String createPostScreenLabelPostType(String postType) {
    return 'Post Type: $postType';
  }

  @override
  String get createPostSegmentStandard => 'Standard';

  @override
  String get createPostSegmentRoutine => 'Routine';

  @override
  String get createPostSegmentRecord => 'Record';

  @override
  String get createPostLabelSharedRoutine => 'Shared Routine:';

  @override
  String get createPostErrorRoutineUnavailable => 'Routine details unavailable';

  @override
  String get createPostRoutineExerciseCountSuffix => ' exercises';

  @override
  String get createPostLabelRecordDetailsReadOnly =>
      'Record Details (Read-only):';

  @override
  String get createPostLabelRecordExercise => 'Exercise: ';

  @override
  String get createPostLabelRecordWeight => 'Weight: ';

  @override
  String get createPostUnitKgSuffix => ' kg';

  @override
  String get createPostLabelRecordReps => 'Reps: ';

  @override
  String get createPostLabelRecordVideo => 'Video: ';

  @override
  String get createPostLabelRecordDetails => 'Record Details:';

  @override
  String get createPostHintSelectExercise => 'Select Exercise*';

  @override
  String get createPostHintRecordWeight => 'Weight (kg)*';

  @override
  String get createPostErrorRecordWeightInvalid => 'Invalid weight';

  @override
  String get createPostHintRecordReps => 'Repetitions*';

  @override
  String get createPostErrorRecordRepsInvalid => 'Invalid repetitions';

  @override
  String get createPostHintRecordVideoUrl => 'Video URL (optional)';

  @override
  String get createPostErrorRecordVideoUrlInvalid => 'Enter a valid URL';

  @override
  String get createPostLabelAttachImageOptionalReplace =>
      'Attach Image (Optional - Replaces Existing)';

  @override
  String get createPostLabelAttachImageOptional => 'Attach Image (Optional)';

  @override
  String get createPostButtonAddImage => 'Add Image';

  @override
  String get createPostTooltipRemoveImage => 'Remove Image';

  @override
  String get createPostTooltipRemoveExistingImage => 'Remove Existing Image';

  @override
  String get createPostToggleEnableComments => 'Enable Comments';

  @override
  String get createPostCommentsEnabledSubtitle =>
      'Users can comment on this post';

  @override
  String get createPostCommentsDisabledSubtitle => 'Comments are disabled';

  @override
  String get createPostHintTextContent => 'What\'s on your mind?';

  @override
  String get createPostErrorContentOrImageRequired =>
      'Post content or image is required.';

  @override
  String get createPostAppBarTitleEdit => 'Edit Post';

  @override
  String get createPostAppBarTitleShareRoutine => 'Share Routine';

  @override
  String get createPostAppBarTitleCreate => 'Create Post';

  @override
  String get createPostButtonSaveChanges => 'Save Changes';

  @override
  String get createPostButtonPublish => 'Publish';

  @override
  String createPostSnackbarSuccess(String status) {
    return 'Post $status successfully!';
  }

  @override
  String createPostSnackbarError(String errorDetails) {
    return 'Error: $errorDetails';
  }

  @override
  String get createPostStatusUpdated => 'updated';

  @override
  String get createPostStatusPublished => 'published';

  @override
  String get createPostLoadingUpdating => 'Updating post...';

  @override
  String get createPostLoadingPublishing => 'Publishing post...';

  @override
  String get createPostErrorUserNotLoggedIn => 'User not logged in.';

  @override
  String get createPostErrorContentEmptyStandard =>
      'Post content cannot be empty for a standard post without media.';

  @override
  String get createPostErrorFetchProfile => 'Could not fetch user profile.';

  @override
  String get createPostErrorUploadMedia => 'Failed to upload media.';

  @override
  String get exploreScreenEmptyTitle => 'Nothing to explore yet.';

  @override
  String get exploreScreenEmptySubtitle => 'Be the first to share something!';

  @override
  String exploreScreenErrorLoad(String message) {
    return 'Error loading posts: $message';
  }

  @override
  String get exploreScreenButtonTryAgain => 'Try Again';

  @override
  String get exploreScreenFabTooltipCreatePost => 'Create Post';

  @override
  String get followListScreenTitleFollowers => 'Followers';

  @override
  String get followListScreenTitleFollowing => 'Following';

  @override
  String followListScreenErrorLoad(String message) {
    return 'Error: $message';
  }

  @override
  String get followListScreenEmptyFollowers =>
      'This user has no followers yet.';

  @override
  String get followListScreenEmptyFollowing =>
      'This user is not following anyone yet.';

  @override
  String get followListScreenButtonTryAgain => 'Try Again';

  @override
  String get followListScreenErrorUnexpected => 'Something went wrong.';

  @override
  String get postDetailScreenAppBarTitleFallback => 'Post';

  @override
  String get postDetailMenuEditPost => 'Edit Post';

  @override
  String get postDetailMenuDisableComments => 'Disable Comments';

  @override
  String get postDetailMenuEnableComments => 'Enable Comments';

  @override
  String get postDetailMenuDeletePost => 'Delete Post';

  @override
  String get postDetailDeleteConfirmTitle => 'Delete Post?';

  @override
  String get postDetailDeleteConfirmMessage =>
      'Are you sure you want to delete this post? This action cannot be undone and will remove all associated comments and media.';

  @override
  String get postDetailDeleteConfirmButtonCancel => 'Cancel';

  @override
  String get postDetailDeleteConfirmButtonDelete => 'Delete';

  @override
  String postDetailSnackbarErrorGeneric(String errorDetails) {
    return 'Error: $errorDetails';
  }

  @override
  String postDetailSnackbarPostDeleted(String postId) {
    return 'Post \"$postId\" has been deleted.';
  }

  @override
  String get postDetailErrorPostNotFound =>
      'Post not found or could not be loaded.';

  @override
  String get postDetailLoading => 'Loading post details...';

  @override
  String get postDetailLikesSuffixSingular => ' Like';

  @override
  String get postDetailLikesSuffixPlural => ' Likes';

  @override
  String get postDetailCommentsSuffixSingular => ' Comment';

  @override
  String get postDetailCommentsSuffixPlural => ' Comments';

  @override
  String get postDetailCommentsSectionTitle => 'Comments';

  @override
  String get postDetailCommentsDisabledMessage =>
      'Comments are disabled for this post.';

  @override
  String get postDetailCommentsEmptyMessage => 'No comments yet. Be the first!';

  @override
  String get postDetailCommentInputHint => 'Write a comment...';

  @override
  String get postDetailButtonValidate => 'VALIDATE';

  @override
  String get postDetailButtonDispute => 'DISPUTE';

  @override
  String get recordStatusVerified => 'VERIFIED';

  @override
  String get recordStatusRejected => 'REJECTED';

  @override
  String get recordStatusExpired => 'EXPIRED';

  @override
  String get recordStatusPending => 'AWAITS VOTING';

  @override
  String get recordStatusContested => 'CONTESTED';

  @override
  String get recordStatusUnknown => 'UNKNOWN';

  @override
  String get postDetailButtonWatchProof => 'Watch Proof';

  @override
  String get viewUserProfileAppBarTitleFallback => 'User Profile';

  @override
  String get viewUserProfileErrorNotAuth => 'User not authenticated.';

  @override
  String viewUserProfileErrorLoadProfile(String message) {
    return 'Could not load profile: $message';
  }

  @override
  String viewUserProfileErrorInit(String message) {
    return 'Failed to initialize: $message';
  }

  @override
  String get viewUserProfileErrorFollowInvalidOp =>
      'Cannot follow/unfollow: Invalid operation.';

  @override
  String viewUserProfileErrorFollowGeneric(String action, String errorDetails) {
    return 'Failed to $action: $errorDetails';
  }

  @override
  String get viewUserProfileErrorFollowActionFollow => 'follow';

  @override
  String get viewUserProfileErrorFollowActionUnfollow => 'unfollow';

  @override
  String viewUserProfileErrorInvalidStateFollow(String currentState) {
    return 'Cannot process follow/unfollow in current state: $currentState';
  }

  @override
  String get viewUserProfileStatLabelLevel => 'Level';

  @override
  String get viewUserProfileButtonUnfollow => 'UNFOLLOW';

  @override
  String get viewUserProfileButtonFollow => 'FOLLOW';

  @override
  String get viewUserProfilePostsTitle => 'User\'s Posts';

  @override
  String viewUserProfileNoPosts(String username) {
    return 'Posts by @$username will appear here.';
  }

  @override
  String get viewUserProfileErrorProfileNotAvailable =>
      'Profile not available.';

  @override
  String get commentListItemEditDialogTitle => 'Edit Comment';

  @override
  String get commentListItemDeleteDialogTitle => 'Delete Comment?';

  @override
  String get commentListItemEditDialogHint => 'Your comment...';

  @override
  String get commentListItemDeleteDialogMessage =>
      'Are you sure you want to delete this comment? This action cannot be undone.';

  @override
  String get commentListItemDialogButtonCancel => 'Cancel';

  @override
  String get commentListItemDialogButtonSave => 'Save';

  @override
  String get commentListItemDialogButtonDelete => 'Delete';

  @override
  String get commentListItemSnackbarDeleted => 'Comment deleted.';

  @override
  String get commentListItemMenuEdit => 'Edit';

  @override
  String get commentListItemMenuDelete => 'Delete';

  @override
  String get activeWorkoutAppBarTitleFallback => 'Active Workout';

  @override
  String get activeWorkoutDialogCancelTitle => 'Cancel Workout?';

  @override
  String get activeWorkoutDialogCompleteTitle => 'Complete Workout?';

  @override
  String get activeWorkoutDialogCancelMessage =>
      'Are you sure you want to cancel this workout? Progress will not be saved.';

  @override
  String get activeWorkoutDialogCompleteMessage =>
      'Are you sure you want to finish and save this workout?';

  @override
  String get activeWorkoutDialogButtonNo => 'No';

  @override
  String get activeWorkoutDialogButtonYesCancel => 'Yes, Cancel';

  @override
  String get activeWorkoutDialogButtonNoContinue => 'No, Continue';

  @override
  String get activeWorkoutDialogButtonYesComplete => 'Yes, Complete';

  @override
  String get activeWorkoutLoading => 'Loading Workout...';

  @override
  String get activeWorkoutLoadingStartingNew => 'Starting new workout...';

  @override
  String get activeWorkoutNoneMessage => 'No active workout found.';

  @override
  String get activeWorkoutButtonBackToRoutines => 'Back to Routines';

  @override
  String get activeWorkoutErrorNoExercises => 'This workout has no exercises.';

  @override
  String get activeWorkoutButtonAddFirstExercise => 'Add First Exercise';

  @override
  String get activeWorkoutButtonFinishEmpty => 'Finish Empty Workout';

  @override
  String activeWorkoutErrorExerciseNoSets(String exerciseName) {
    return 'Error: Exercise \'\'$exerciseName\'\' has no sets.';
  }

  @override
  String get activeWorkoutErrorExerciseNoSetsHelp =>
      'Please edit the routine or contact support.';

  @override
  String get activeWorkoutButtonGoBack => 'Go Back';

  @override
  String get activeWorkoutErrorUnexpected =>
      'An unexpected state occurred. Please restart.';

  @override
  String get workoutCompleteTitleLevelUp => 'LEVEL UP!';

  @override
  String get workoutCompleteTitleDefault => 'Workout Complete!';

  @override
  String workoutCompleteSubtitleLevelUp(int level) {
    return 'You reached Level $level!';
  }

  @override
  String workoutCompleteStatDuration(int durationMinutes) {
    return 'Duration: $durationMinutes min';
  }

  @override
  String workoutCompleteStatVolume(String volume) {
    return 'Total Volume: $volume KG';
  }

  @override
  String workoutCompleteStatXpGained(int xpGained) {
    return '+$xpGained XP GAINED';
  }

  @override
  String workoutCompleteXpBarLabelLevel(int level) {
    return 'LVL $level';
  }

  @override
  String workoutCompleteXpBarText(String currentXp, String totalXp) {
    return '$currentXp/$totalXp XP';
  }

  @override
  String get workoutCompleteButtonAwesome => 'Awesome!';

  @override
  String get currentSetDisplayWeightDialogTitle => 'Set Weight (KG)';

  @override
  String get currentSetDisplayWeightDialogHint => 'Enter weight';

  @override
  String get currentSetDisplayWeightDialogButtonCancel => 'Cancel';

  @override
  String get currentSetDisplayWeightDialogButtonSet => 'Set';

  @override
  String get currentSetDisplaySetLabelPrefix => 'SET ';

  @override
  String get currentSetDisplayWeightLabelPrefix => 'WEIGHT: ';

  @override
  String get currentSetDisplayUnitKgSuffix => ' KG';

  @override
  String get currentSetDisplayRepsLabelSuffix => ' REPETITIONS';

  @override
  String get currentSetDisplayRpeHelpText =>
      'Describe how hard it was to make a repetition\non a 0-10 scale.';

  @override
  String get currentSetDisplayNoRepsPlaceholder => 'Add reps';

  @override
  String get currentSetDisplayButtonPrevSet => '< PREV. SET';

  @override
  String get currentSetDisplayButtonFinishWorkout => 'FINISH WORKOUT';

  @override
  String get currentSetDisplayButtonNextExercise => 'NEXT EXERCISE >';

  @override
  String get currentSetDisplayButtonNextSet => 'NEXT SET >';

  @override
  String get progressScreenLoadingData => 'Loading progress data...';

  @override
  String get progressScreenRefreshingData => 'Refreshing progress data...';

  @override
  String get progressScreenErrorNotAuthRefresh =>
      'User not authenticated. Cannot refresh.';

  @override
  String get progressScreenErrorProfileNotFoundRefresh =>
      'User profile not found during refresh.';

  @override
  String progressScreenErrorFailedRefresh(String errorMessage) {
    return 'Failed to refresh data: $errorMessage';
  }

  @override
  String get progressScreenLoadingWorkoutStats => 'Loading workout stats...';

  @override
  String get progressScreenRefreshingWorkoutStats =>
      'Refreshing workout stats...';

  @override
  String progressScreenErrorFailedProcessWorkoutData(String errorMessage) {
    return 'Failed to process workout data: $errorMessage';
  }

  @override
  String get progressScreenXpToNextLevel => 'XP TO NEXT LEVEL!';

  @override
  String get progressScreenVolumeTitle => 'VOLUME (LAST 7 DAYS - SETS)';

  @override
  String get progressScreenNoVolumeData =>
      'No workout data for the last 7 days to display on muscle map.';

  @override
  String progressScreenRpeTrendTitle(int maxWorkouts) {
    return 'EXERTION (RPE TREND - LAST $maxWorkouts WORKOUTS)';
  }

  @override
  String get progressScreenNoRpeData =>
      'No RPE data logged recently for any exercise.';

  @override
  String get progressScreenAvgRpeLabel => 'AVG. RPE - ';

  @override
  String progressScreenStrengthTrendTitle(int maxWorkouts) {
    return 'STRENGTH (WEIGHT TREND - LAST $maxWorkouts WORKOUTS)';
  }

  @override
  String get progressScreenNoWeightData =>
      'No weight data logged recently for any exercise.';

  @override
  String get progressScreenAvgWeightLabel => 'AVG. WEIGHT - ';

  @override
  String get progressScreenAdviceTitle => 'ADVICE';

  @override
  String get progressScreenNoAdvice =>
      'No new advice at the moment. Keep up the great work!';

  @override
  String progressScreenErrorLoadAdvice(String message) {
    return 'Error loading advice: $message';
  }

  @override
  String get progressScreenLoadingAdvice => 'Loading advice...';

  @override
  String get progressScreenButtonSendTestAdvice => 'Send Test Advice';

  @override
  String get progressScreenButtonTryAgain => 'Try Again';

  @override
  String progressScreenErrorLoadingProfile(String errorMessage) {
    return 'Error loading profile: $errorMessage';
  }

  @override
  String get progressScreenNoData =>
      'No progress data available yet. Start working out!';

  @override
  String progressScreenLevelLabel(int level) {
    return 'LVL $level';
  }

  @override
  String progressScreenXpProgressText(String currentXp, String totalXp) {
    return '$currentXp/$totalXp XP';
  }

  @override
  String progressScreenExercisePlaceholder(String placeholder) {
    return 'EXERCISE $placeholder';
  }

  @override
  String get progressScreenKgUnit => 'KG';

  @override
  String get postCardRoutineShareTitle => 'SHARED ROUTINE';

  @override
  String postCardRoutineAuthorPrefix(String authorUsername) {
    return 'by @$authorUsername';
  }

  @override
  String get postCardRoutineExercisesLabel => 'EXERCISE';

  @override
  String get postCardRoutineExercisesLabelPlural => 'EXERCISES';

  @override
  String get postCardRoutineNoSchedule => 'NO SCHEDULE';

  @override
  String get postCardRoutineScheduledDaysLabel => 'SCHEDULED DAYS';

  @override
  String get postCardRoutineButtonAddToList => 'ADD TO MY LIST';

  @override
  String get postCardRoutineSnackbarLoginToAdd =>
      'Please log in to add routines.';

  @override
  String get postCardRoutineSnackbarAlreadyOwn =>
      'This is your routine already!';

  @override
  String get postCardRoutineSnackbarAdded => 'Routine added to your list!';

  @override
  String postCardRoutineSnackbarErrorAdd(String errorDetails) {
    return 'Failed to add routine: $errorDetails';
  }

  @override
  String get postCardRoutineIsYours => 'This is your shared routine.';

  @override
  String get postCardRoutineLoginToAdd => 'Log in to add this routine.';

  @override
  String get postCardRecordClaimTitle => 'RECORD CLAIM';

  @override
  String get postCardRecordExerciseNameFallback => 'EXERCISE RECORD';

  @override
  String postCardRecordRepsKgFormat(String reps, String weight) {
    return '$reps REPS / $weight KG';
  }

  @override
  String get postCardRecordRepsFallback => 'N/A';

  @override
  String get postCardRecordWeightFallback => 'N/A';
}
