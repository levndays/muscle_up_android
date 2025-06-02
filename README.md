MuscleUP: Next-Gen Fitness Application

Motto: Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

1. Introduction

MuscleUP is an innovative mobile fitness application designed to revolutionize your approach to training. Our mission is to create a highly motivating, socially interactive, and gamified environment that not only helps users achieve their fitness goals but also makes the process enjoyable, fostering long-term engagement. MuscleUP enables detailed workout tracking, personalized goal setting, progress analysis through unique metrics (like RPE for each repetition), and community support by sharing achievements.

This document provides a comprehensive overview of the MuscleUP project, including its current features, core business logic, software architecture, backend design with Firebase, and detailed functionality of its components. It emphasizes modularity, scalability, and maintainability.

2. Current Project Status (Version 0.3.x - Progress Tracking Update)

MuscleUP has evolved significantly, incorporating a robust set of core features and recently introducing a comprehensive Progress Tracking module.

Key Implemented Features:

Authentication & User Profile:

Secure Email/Password and Google Sign-In.

Automated initial profile creation in Cloud Firestore (profileSetupComplete: false).

Dedicated ProfileSetupScreen for detailed user information (username, gender, DOB, height, weight, goals, activity level).

Real-time user profile updates via UserProfileCubit.

Automatic "Early Bird" achievement награда upon profile setup completion.

Main Navigation & Dashboard (HomePage & DashboardScreen):

Central AppBar with dynamic titles ("MuscleUP | Screen Name").

BottomNavigationBar for navigation: Routines, Explore, Progress, Profile.

"START WORKOUT" FloatingActionButton on the Dashboard to begin new or resume active workouts.

Dashboard: Personalized greeting, workout streak, basic stats, and an interactive Notifications Section with unread count, swipe-to-delete, detail view, and "Read All" functionality.

Exercise Library (ExerciseExplorerScreen):

Browse standardized exercises from Firestore.

Selection mode for adding exercises to routines.

Powered by ExerciseExplorerCubit.

Workout Routine Management (features/routines):

UserRoutinesScreen: View, create, edit, and delete custom routines.

CreateEditRoutineScreen: Define routine name, description, schedule, and exercises.

Add exercises via AddExerciseToRoutineDialog, configure sets/notes per exercise.

State managed by UserRoutinesCubit and ManageRoutineCubit.

Workout Tracking (ActiveWorkoutScreen):

Start workouts from routines or as empty sessions.

Auto-resume incomplete sessions.

CurrentSetDisplay: Log weight, reps, and a unique RPE (Rate of Perceived Exertion) slider for each repetition.

Navigate sets/exercises, confirm finish/cancel actions.

Managed by ActiveWorkoutCubit.

Workout Completion (WorkoutCompleteScreen):

Celebratory screen with Lottie trophy animation and confetti.

Displays workout summary (routine name, duration, total volume).

XP & Level Up System: Calculates and animates XP earned and progress to the next level. Displays level-up notifications.

Automatic "First Workout" achievement.

NEW: Progress Tracking Screen (ProgressScreen):

League System: Displays the user's current fitness league (e.g., Beginner, Bronze, Gold) based on their level, with custom gradient visuals per league. Fetches LeagueInfo from Firestore.

XP & Level Progress: Visualizes XP progression with an animated XPProgressBarWidget.

Muscle Map Visualization:

Uses MuscleMapWidget with flutter_svg to display front and back body SVGs (male_front.svg, female_front.svg, etc.).

Dynamically colors muscle groups based on workout volume (number of sets per muscle group) over the last 7 days. Color intensity (from base to mid to max color) indicates higher volume.

Training Statistics:

Average RPE per exercise over the last 30 days.

Average working weights per exercise over the last 90 days.

Data fetched and processed by ProgressCubit using WorkoutLogRepository and PredefinedExerciseRepository.

Includes RefreshIndicator for manual data refresh.

Notification System (features/notifications):

AppNotification model and NotificationType enum.

NotificationRepository for Firestore interaction (users/{userId}/notifications).

NotificationsCubit manages notification state and real-time updates, including an achievementAlertController for immediate UI alerts (e.g., SnackBars for new achievements).

Firebase Cloud Functions (TypeScript, Node.js v20):

createUserProfile (Auth v1 Trigger): Creates Firestore user profile document on new Firebase Auth user.

calculateAndAwardXpAndStreak (Firestore v2 Trigger): Processes completed workouts, awards XP (base + volume + duration, capped at 200 XP), updates level, streak, and "First Workout" achievement.

checkProfileSetupCompletionAchievements (Firestore v2 Trigger): Awards "Early Bird" achievement on profile setup completion.

seedPredefinedExercises (HTTPS v2 Trigger): Populates the predefinedExercises collection (optionally key-protected).

Achievements System:

AchievementId enum and Achievement entity.

Achievements like "Early Bird" and "First Workout" are awarded by Firebase Functions and displayed in the user's profile.

3. Core Architectural Principles

The project adheres to modern software development best practices:

Modularity (Feature-First): Functionality is organized into self-contained feature modules within lib/features/, promoting separation of concerns and easier maintenance.

Clean Architecture (Layered Approach): Each feature, and the app глобально, attempts to follow a layered structure (Presentation, Domain, Data) to decouple business logic from UI and data sources.

State Management (BLoC/Cubit): flutter_bloc is extensively used for managing UI state and business logic, ensuring predictability, testability, and a clear flow of data.

Dependency Injection: RepositoryProvider and BlocProvider from flutter_bloc are used to provide dependencies (repositories, cubits) down the widget tree.

Data Abstraction (Repositories): Repository pattern abstracts data sources (primarily Firebase Firestore), providing a clean API to the domain and presentation layers.

Scalability: The architecture is designed for future expansion, allowing new features to be added with minimal impact on existing code.

Testability: Separation of logic facilitates unit testing for business logic (Cubits, repositories) and widget testing for UI components.

4. Technology Stack

Frontend:

Framework: Flutter (^3.8.0 Dart SDK)

Programming Language: Dart

State Management: flutter_bloc: ^9.1.1, bloc: ^9.0.0

Object Equality: equatable: ^2.0.5 (for BLoC states/events and entities)

Date/Time Formatting: intl: ^0.19.0

SVG Rendering: flutter_svg: ^2.0.10+1 (for muscle maps)

Animations & UI Effects:

animated_background: ^2.0.0 (for LavaLampBackground on LoginPage)

confetti: ^0.7.0 (for WorkoutCompleteScreen)

lottie: ^3.1.2 (for trophy animation on WorkoutCompleteScreen)

Navigation: Standard Flutter Navigation (MaterialPageRoute, Navigator.push/pop/pushAndRemoveUntil).

Backend (Firebase):

Core: firebase_core: ^3.13.1

Authentication: firebase_auth: ^5.5.4 (Email/Password, Google Sign-In)

Google Sign-In Helper: google_sign_in: ^6.2.1

Database: cloud_firestore: ^5.6.8 (NoSQL database for user profiles, routines, exercises, notifications, workout logs, leagues)

Serverless Logic: Firebase Cloud Functions (TypeScript, Node.js v20, firebase-functions: ^6.0.1, firebase-admin: ^12.6.0)

Development Tools:

Linting: flutter_lints: ^5.0.0

App Icon Generation: flutter_launcher_icons: ^0.13.1

Project Snapshots: Custom Python script (create_snapshot.py)

5. Project Structure

The project follows a "feature-first" directory structure:

muscle_up/
├── android/                  # Android-specific platform code
├── assets/                   # Application assets
│   ├── animations/
│   │   └── trophy_animation.json # Lottie animation for WorkoutCompleteScreen
│   ├── fonts/                # Custom fonts (Inter, IBMPlexMono)
│   └── images/               # Image assets (logos, icons, muscle maps)
│       ├── app_icon.png
│       ├── google_logo.png
│       ├── male_front.svg
│       ├── male_back.svg
│       ├── female_front.svg  # NEW
│       └── female_back.svg   # NEW
├── functions/                # Firebase Cloud Functions (TypeScript)
│   ├── src/
│   │   └── index.ts          # Main Cloud Functions logic
│   ├── package.json          # Dependencies for Cloud Functions
│   ├── tsconfig.json         # TypeScript configuration
│   └── .eslintrc.js          # ESLint configuration for Functions
├── ios/                      # iOS-specific platform code
├── lib/                      # Main Dart application code
│   ├── auth_gate.dart        # Handles auth state and profile setup redirection
│   ├── firebase_options.dart # Firebase configuration (generated by FlutterFire)
│   ├── home_page.dart        # Main screen with BottomNav, AppBar, FAB
│   ├── login_page.dart       # Login/Registration screen with animated background
│   ├── main.dart             # App entry point, MaterialApp, RepositoryProviders, Theme
│   │
│   ├── core/                 # Shared core logic, entities, repository interfaces
│   │   └── domain/
│   │       ├── entities/     # Plain Dart Objects (data models)
│   │       │   ├── achievement.dart
│   │       │   ├── app_notification.dart
│   │       │   ├── league_info.dart    # NEW
│   │       │   ├── logged_exercise.dart
│   │       │   ├── logged_set.dart
│   │       │   ├── predefined_exercise.dart
│   │       │   ├── routine.dart
│   │       │   ├── user_profile.dart
│   │       │   └── workout_session.dart
│   │       └── repositories/ # Abstract repository interfaces
│   │           ├── league_repository.dart          # NEW
│   │           ├── notification_repository.dart
│   │           ├── predefined_exercise_repository.dart
│   │           ├── routine_repository.dart
│   │           ├── user_profile_repository.dart
│   │           └── workout_log_repository.dart
│   │
│   ├── features/             # Feature-specific modules
│   │   ├── dashboard/
│   │   │   └── presentation/screens/dashboard_screen.dart
│   │   ├── exercise_explorer/
│   │   │   ├── data/repositories/predefined_exercise_repository_impl.dart
│   │   │   └── presentation/ (cubit, screens, widgets)
│   │   ├── notifications/
│   │   │   ├── data/repositories/notification_repository_impl.dart
│   │   │   └── presentation/ (cubit, screens, widgets)
│   │   ├── profile/
│   │   │   └── presentation/ (cubit, screens)
│   │   ├── profile_setup/
│   │   │   ├── data/repositories/user_profile_repository_impl.dart
│   │   │   └── presentation/ (cubit, screens)
│   │   ├── progress/           # NEW: Progress tracking feature
│   │   │   ├── data/repositories/league_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── progress_cubit.dart
│   │   │       │   └── progress_state.dart
│   │   │       ├── screens/progress_screen.dart
│   │   │       └── widgets/
│   │   │           ├── league_title_widget.dart
│   │   │           ├── muscle_map_widget.dart
│   │   │           └── xp_progress_bar_widget.dart
│   │   ├── routines/
│   │   │   ├── data/repositories/routine_repository_impl.dart
│   │   │   └── presentation/ (cubits, screens, widgets)
│   │   └── workout_tracking/
│   │       ├── data/repositories/workout_log_repository_impl.dart
│   │       └── presentation/ (cubit, screens, widgets)
│   │
│   ├── utils/                # Utility functions
│   │   └── duration_formatter.dart
│   │
│   └── widgets/              # Common reusable widgets
│       └── lava_lamp_background.dart
│
├── pubspec.yaml              # Project configuration, dependencies, assets
├── README.md                 # This file
└── ...                       # Other config files (.firebaserc, firebase.json, .gitignore)

6. Deep Dive into Key Components & UX
6.1. Authentication & Profile Setup

LoginPage: Initial screen with an engaging LavaLampBackground. Provides Email/Password and Google Sign-In options.

AuthGate: Central widget listening to Firebase Auth state.

If authenticated, it streams UserProfile data.

If profileSetupComplete is false, navigates to ProfileSetupScreen.

If true, navigates to HomePage.

Handles cases where the Firestore profile document might not be immediately available after Firebase Auth user creation (due to Firebase Function createUserProfile latency) by showing a loading indicator.

Firebase Function createUserProfile (Auth v1 Trigger): Automatically creates a user document in users collection in Firestore upon new user registration, initializing fields like xp: 0, level: 1, profileSetupComplete: false.

ProfileSetupScreen: A form for users to input username (unique), display name, gender, DOB, height, weight, fitness goals, and activity level. Uses ProfileSetupCubit.

Firebase Function checkProfileSetupCompletionAchievements (Firestore v2 Trigger): Awards the "Early Bird" achievement (AchievementId.EARLY_BIRD) and sends a notification when profileSetupComplete transitions from false to true.

UserProfileCubit: Globally available Cubit in HomePage providing real-time UserProfile data.

6.2. Main Navigation: HomePage & DashboardScreen

HomePage: The app's main hub post-login.

AppBar: Dynamically displays "MuscleUP" (clickable to navigate to Dashboard) and the current screen's title (e.g., "MuscleUP | My Routines").

BottomNavigationBar: Tabs for "ROUTINES" (UserRoutinesScreen), "EXPLORE" (ExerciseExplorerScreen), "PROGRESS" (ProgressScreen), and "PROFILE" (ProfileScreen).

FloatingActionButton ("START WORKOUT"): Checks for active WorkoutSession. If found, resumes it on ActiveWorkoutScreen. Otherwise, offers to start a new workout (from routine or empty).

Provides NotificationsCubit to its descendants.

DashboardScreen: The content for the main "MuscleUP" tab.

Personalized greeting, workout streak icon (clickable to go to Progress screen).

"STATS" section (placeholder for "Total Volume" graph, cards for "WEIGHT", "STREAK", "ADHERENCE" using data from UserProfileCubit).

"NOTIFICATIONS" section: Displays recent notifications, unread count, and "READ ALL" button, powered by NotificationsCubit.

6.3. Notification System

AppNotification Model: Defines notification structure (ID, type, title, message, timestamp, read status, related entity, icon). NotificationType enum includes achievementUnlocked, workoutReminder, etc.

NotificationRepositoryImpl: Handles CRUD operations for notifications in users/{userId}/notifications subcollection.

NotificationsCubit: Manages the list of notifications, listens to Firestore changes, and updates the UI. Includes achievementAlertController for immediate SnackBar alerts for new achievements.

NotificationListItem & NotificationDetailScreen: Widgets for displaying individual notifications and their details. Supports swipe-to-delete on list items.

6.4. Exercise Library

PredefinedExercise Model: Standardized exercise data (name, muscle groups, equipment, description, video URL, difficulty).

PredefinedExerciseRepositoryImpl: Fetches exercises from the predefinedExercises Firestore collection.

Firebase Function seedPredefinedExercises (HTTPS v2 Trigger): An admin function to populate the predefinedExercises collection with initial data.

ExerciseExplorerCubit & ExerciseExplorerScreen: Load and display the list of exercises. Supports a selection mode for adding exercises to routines.

6.5. Workout Routine Management

UserRoutine & RoutineExercise Models: Define user-created routines and the exercises within them (sets, notes, exercise snapshot).

RoutineRepositoryImpl: CRUD operations for routines in userRoutines collection (user-specific).

UserRoutinesCubit: Fetches and displays the list of a user's routines.

ManageRoutineCubit: Manages state for creating or editing a routine.

UserRoutinesScreen & CreateEditRoutineScreen: UI for listing, creating, and editing routines. AddExerciseToRoutineDialog facilitates adding exercises from the library.

6.6. Workout Tracking

Entities: WorkoutSession, LoggedExercise, LoggedSet.

WorkoutSession: Core entity for a training session (ID, user ID, routine ID/name, start/end times, duration, completed exercises, notes, status, total volume).

LoggedExercise: An exercise performed within a session.

LoggedSet: A single set performed (weight, reps, RPE data, completion status).

WorkoutLogRepositoryImpl: Manages workout sessions in users/{userId}/workoutLogs.

ActiveWorkoutCubit:

Manages the state of an active workout.

startNewWorkout: Creates a new WorkoutSession, optionally populating from a UserRoutine.

updateLoggedSet: Updates set data (weight, reps, RPE) locally and syncs to Firestore.

completeWorkout/cancelWorkout: Finalizes or cancels the session.

Manages an in-app timer for workout duration.

Firebase Function calculateAndAwardXpAndStreak (Firestore v2 Trigger):

Triggers when a WorkoutSession status becomes completed.

Calculates XP based on duration and volume (base 50 + volume/100 + duration/300, max 200).

Updates user's currentStreak, longestStreak, lastWorkoutTimestamp, total xp, and level.

Awards "First Workout" (AchievementId.FIRST_WORKOUT) achievement and sends a notification if it's the user's first completed workout.

ActiveWorkoutScreen:

UI for an ongoing workout. Displays routine/workout name, timer.

Features CurrentSetDisplay for logging sets.

Navigation buttons ("PREV. SET", "NEXT SET", "NEXT EXERCISE", "FINISH WORKOUT").

CurrentSetDisplay Widget:

Displays current exercise name, set number.

Input fields for weight and reps (+/- buttons).

Unique RPE (Rate of Perceived Exertion) Sliders: For each rep performed, a vertical slider (0-10) allows the user to rate its difficulty. RPE data is saved as "RPE_DATA:val1,val2,..." in the LoggedSet notes.

WorkoutCompleteScreen:

Shown after successful workout completion.

Features Lottie trophy animation and confetti.

Displays workout summary and XP earned.

Animates XP progress towards the next level.

Shows level-up information if applicable, using UserProfile data passed to it.

6.7. Progress Tracking (ProgressScreen & ProgressCubit)

The Progress screen provides users with a visual and statistical overview of their fitness journey.

Purpose: To offer insightful feedback on training achievements, workload distribution, and strength progression, motivating users and helping them understand their training patterns.

ProgressCubit: Orchestrates data fetching from multiple repositories (UserProfileRepository, LeagueRepository, WorkoutLogRepository, PredefinedExerciseRepository) and processes it for the UI. It subscribes to UserProfile updates for real-time data.

League System:

LeagueInfo entities (stored in Firestore leagues collection) define different fitness leagues (e.g., Beginner, Bronze, Gold) based on minLevel, maxLevel, and minXp.

LeagueTitleWidget displays the user's current league name with a custom gradient and their current level.

XP & Leveling:

XPProgressBarWidget provides an animated visualization of the user's XP progress within their current level, showing XP earned and XP remaining to the next level.

Level calculation logic is primarily handled by the calculateAndAwardXpAndStreak Firebase Function.

Muscle Map Visualization (MuscleMapWidget):

Utilizes flutter_svg to render male or female body SVGs (e.g., assets/images/female_front.svg).

The ProgressCubit calculates volumePerMuscleGroup7Days by counting the number of completed sets per muscle group (defined by SVG IDs like 'chest', 'biceps', 'quads') from workout logs over the last 7 days.

The MuscleMapWidget dynamically colors these SVG muscle group paths. The color intensity (interpolated between baseColor, midColor, and maxColor) reflects the training volume, with higher volume resulting in a "hotter" color.

Training Statistics:

Average RPE per Exercise (Last 30 Days): Calculated by ProgressCubit from RPE data stored in LoggedSet notes. Displays the average perceived exertion for each exercise.

Average Working Weights per Exercise (Last 90 Days): Calculated by ProgressCubit. Shows the average weight lifted for each exercise, providing a trend indicator for strength.

Data Refresh: Includes a RefreshIndicator for users to manually pull and refresh all progress data.

6.8. Achievements System

AchievementId Enum & Achievement Entity: Define available achievements (e.g., EARLY_BIRD, FIRST_WORKOUT, CONSISTENT_KING_10). Each achievement has a name, description, icon, and an optional condition checker.

Awarding Logic: Achievements are primarily awarded by Firebase Cloud Functions (checkProfileSetupCompletionAchievements, calculateAndAwardXpAndStreak) based on specific user actions or milestones.

Storage: Awarded achievement IDs are stored in the achievedRewardIds list within the user's UserProfile document.

Display: Achieved rewards are visualized on the ProfileScreen.

6.9. Quality of Life & UX Details

Animated Background: LavaLampBackground on LoginPage for a captivating first impression.

Custom Theming: Detailed Material 3 theme in main.dart using custom fonts (Inter, IBMPlexMono) for a consistent and modern look.

Intuitive Navigation: Clear set/exercise navigation in ActiveWorkoutScreen.

Confirmation Dialogs: For critical actions like deleting routines or canceling workouts.

Visual Feedback: SnackBars for save/error/success operations.

Loading Indicators: CircularProgressIndicator used during data fetching.

Celebratory Animations: Confetti and Lottie animations on WorkoutCompleteScreen enhance gamification.

Automatic UI Updates: Leveraging Flutter BLoC/Cubit and Firestore streams for real-time updates to profile, notifications, and active workouts.

7. Backend: Firebase Cloud Firestore Structure

The Firestore database is organized as follows:

users/{userId}: User-specific data.

Fields: uid, email, displayName, profilePictureUrl, username, gender, dateOfBirth, heightCm, weightKg, fitnessGoal, activityLevel, xp, level, currentStreak, longestStreak, lastWorkoutTimestamp, followersCount, followingCount, achievedRewardIds (List<String>), profileSetupComplete, createdAt, updatedAt.

Subcollection notifications/{notificationId}: User notifications (AppNotification model).

Subcollection workoutLogs/{sessionId}: Workout session data (WorkoutSession model).

completedExercises (List of LoggedExercise objects).

Each LoggedExercise contains completedSets (List of LoggedSet objects with RPE data in notes).

predefinedExercises/{exerciseId}: Standardized exercise library (PredefinedExercise model).

userRoutines/{routineId}: User-created workout routines (UserRoutine model).

exercises (List of RoutineExercise objects).

leagues/{leagueId}: Information about fitness leagues (LeagueInfo model).

Fields: name, minLevel, maxLevel, minXp, maxXp, gradientColors (List<String> hex), description.

8. Firebase Cloud Functions Logic (functions/src/index.ts)

Server-side logic is handled by Firebase Cloud Functions written in TypeScript (Node.js v20 environment, default region us-central1):

createUserProfile (Auth v1 Trigger - onCreate):

Triggered when a new user signs up via Firebase Authentication.

Creates a corresponding user document in users/{userId} with initial profile data (xp: 0, level: 1, profileSetupComplete: false, etc.).

calculateAndAwardXpAndStreak (Firestore v2 Trigger - onDocumentUpdated on users/{userId}/workoutLogs/{sessionId}):

Triggers when a workoutLogs document's status changes to completed.

Calculates XP: base (50) + (totalVolume / 100) + (durationSeconds / 300), capped at 200 XP.

Updates user's xp, level (based on xpPerLevelBase = 200 and an increment of 50 XP per additional level requirement).

Updates currentStreak, longestStreak, and lastWorkoutTimestamp.

Awards AchievementId.FIRST_WORKOUT if not already achieved and creates a notification.

checkProfileSetupCompletionAchievements (Firestore v2 Trigger - onDocumentWritten on users/{userId}):

Triggers on user document creation or update.

If profileSetupComplete changes from false (or non-existent) to true, awards AchievementId.EARLY_BIRD and creates a notification.

seedPredefinedExercises (HTTPS v2 Trigger - onRequest):

An HTTP-callable function to populate the predefinedExercises collection with a predefined set of exercises.

Optionally protected by an admin key (APP_ADMIN_KEY or ADMIN_KEY environment variable). If the key is not set, the function runs unprotected with a warning.

Avoids duplicates by checking normalizedName.

9. Setup and Running the Project

Flutter SDK: Ensure Flutter SDK (^3.8.0 or compatible) is installed.

Clone Repository: Clone this project to your local machine.

Firebase Project Setup:

Create a new project in the Firebase Console. (Project ID used in this snapshot: muscle-up-8c275).

Add Android and/or iOS apps to your Firebase project.

Android: Use com.example.muscle_up as Package Name (or update in android/app/build.gradle.kts and Firebase). Download google-services.json to android/app/.

iOS: Use com.example.muscleUp as Bundle ID (or update in Xcode and Firebase). Download GoogleService-Info.plist to ios/Runner/.

Authentication: Enable Email/Password and Google Sign-In methods in the Firebase Console.

Cloud Firestore: Enable Cloud Firestore. Start with test rules and then secure them for production (see README.md section 7 for example rules).

Firebase Functions:

Install Firebase CLI: npm install -g firebase-tools.

Login: firebase login.

Select project: firebase use YOUR_PROJECT_ID.

Install dependencies: cd functions && npm install && cd ...

Deploy functions: firebase deploy --only functions.

(Optional) For seedPredefinedExercises key protection: firebase functions:config:set app.admin_key="YOUR_SECRET_KEY" and redeploy.

Flutter Dependencies: Run flutter pub get in the project root.

App Icons: (Optional) If assets/images/app_icon.png is changed, regenerate icons: flutter pub run flutter_launcher_icons.

Run App: flutter run on an emulator or physical device.

Seed Exercises: After deploying functions, call seedPredefinedExercises via its HTTPS URL (e.g., https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/seedPredefinedExercises?key=YOUR_SECRET_KEY if key is configured).

10. Future Development

MuscleUP aims to become a comprehensive social fitness platform. Future enhancements include:

Full Implementation of Screens: Complete "Posts", "Profile" details (advanced stats, activity feed).

Enhanced Social Features: User following/followers, activity feeds, comments, likes, direct messaging.

Public Records & Leaderboards: System for submitting and validating personal records, community-validated leaderboards for various exercises/metrics.

Advanced Gamification: More diverse achievements, challenges, seasonal leagues, virtual rewards.

Personalized Goal Setting: More granular goal types (e.g., weight goals for specific lifts, rep max goals) with automated progress tracking.

Push Notifications: Via Firebase Cloud Messaging for reminders, achievements, social interactions.

Comprehensive Testing: Unit, widget, and integration tests for all critical components.

UI/UX Refinements: Based on user feedback and A/B testing.

Admin Panel: For content management (exercises, moderation).

Wearable Device Integration: Syncing data from fitness trackers.

Offline Support: Basic offline capabilities for workout logging.

Advanced Analytics: Deeper insights into training patterns, recovery, and performance trends.# MuscleUP: Next-Gen Fitness Application

Motto: Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

1. Introduction

MuscleUP is an innovative mobile fitness application designed to revolutionize your approach to training. Our mission is to create a highly motivating, socially interactive, and gamified environment that not only helps users achieve their fitness goals but also makes the process enjoyable, fostering long-term engagement. MuscleUP enables detailed workout tracking, personalized goal setting, progress analysis through unique metrics (like RPE for each repetition), and community support by sharing achievements.

This document provides a comprehensive overview of the MuscleUP project, including its current features, core business logic, software architecture, backend design with Firebase, and detailed functionality of its components. It emphasizes modularity, scalability, and maintainability.

2. Current Project Status (Version 0.3.x - Progress Tracking Update)

MuscleUP has evolved significantly, incorporating a robust set of core features and recently introducing a comprehensive Progress Tracking module.

Key Implemented Features:

Authentication & User Profile:

Secure Email/Password and Google Sign-In.

Automated initial profile creation in Cloud Firestore (profileSetupComplete: false) via Firebase Function.

Dedicated ProfileSetupScreen for detailed user information (username, gender, DOB, height, weight, goals, activity level).

Real-time user profile updates via UserProfileCubit.

Automatic "Early Bird" achievement award upon profile setup completion, managed by a Firebase Function.

Main Navigation & Dashboard (HomePage & DashboardScreen):

Central AppBar with dynamic titles ("MuscleUP | Screen Name").

BottomNavigationBar for navigation: Routines, Explore, Progress, Profile.

"START WORKOUT" FloatingActionButton on the Dashboard to begin new or resume active workouts.

Dashboard: Personalized greeting, workout streak, basic stats, and an interactive Notifications Section with unread count, swipe-to-delete, detail view (NotificationDetailScreen), and "Read All" functionality.

Exercise Library (ExerciseExplorerScreen):

Browse standardized exercises from Firestore, populated by seedPredefinedExercises Firebase Function.

Selection mode for adding exercises to routines.

Powered by ExerciseExplorerCubit.

Workout Routine Management (features/routines):

UserRoutinesScreen: View, create, edit, and delete custom routines.

CreateEditRoutineScreen: Define routine name, description, schedule, and exercises.

Add exercises via AddExerciseToRoutineDialog, configure sets/notes per exercise.

State managed by UserRoutinesCubit (for list display) and ManageRoutineCubit (for creation/editing).

Workout Tracking (ActiveWorkoutScreen):

Start workouts from routines or as empty sessions.

Auto-resume incomplete sessions by fetching active session data.

CurrentSetDisplay: Log weight, reps, and a unique RPE (Rate of Perceived Exertion) slider for each repetition.

Navigate sets/exercises, confirm finish/cancel actions.

Managed by ActiveWorkoutCubit.

Workout Completion (WorkoutCompleteScreen):

Celebratory screen with Lottie trophy animation (trophy_animation.json) and confetti effects.

Displays workout summary (routine name, duration, total volume).

XP & Level Up System: Calculates and animates XP earned and progress to the next level. Displays level-up notifications. Data sourced from UserProfile passed after Firebase Function processing.

Automatic "First Workout" achievement, awarded by a Firebase Function.

NEW: Progress Tracking Screen (ProgressScreen):

Purpose: Provides users with a visual and statistical overview of their fitness journey, highlighting achievements and training focus.

League System: Displays the user's current fitness league (e.g., Beginner, Bronze, Gold) based on their level, with custom gradient visuals per league. LeagueInfo is fetched from Firestore by LeagueRepository.

XP & Level Progress: Visualizes XP progression with an animated XPProgressBarWidget.

Muscle Map Visualization (MuscleMapWidget):

Uses flutter_svg to render gender-specific front and back body SVGs (e.g., assets/images/female_front.svg).

Dynamically colors muscle groups based on workout volume (number of completed sets per muscle group) over the last 7 days. Color intensity (interpolated between baseColor, midColor, and maxColor) indicates higher volume.

Training Statistics:

Average RPE per exercise over the last 30 days.

Average working weights per exercise over the last 90 days.

Data for muscle map and statistics is fetched and processed by ProgressCubit using WorkoutLogRepository and PredefinedExerciseRepository.

Includes RefreshIndicator for manual data refresh.

Notification System (features/notifications):

AppNotification model and NotificationType enum.

NotificationRepository for Firestore interaction with users/{userId}/notifications subcollection.

NotificationsCubit manages notification state and real-time updates, including an achievementAlertController for immediate UI alerts (e.g., SnackBars for new achievements).

Firebase Cloud Functions (TypeScript, Node.js v20):

createUserProfile (Auth v1 Trigger): Creates Firestore user profile document on new Firebase Auth user.

calculateAndAwardXpAndStreak (Firestore v2 Trigger): Processes completed workouts, awards XP (base + volume + duration, capped at 200 XP), updates level, streak, and "First Workout" achievement.

checkProfileSetupCompletionAchievements (Firestore v2 Trigger): Awards "Early Bird" achievement on profile setup completion.

seedPredefinedExercises (HTTPS v2 Trigger): Populates the predefinedExercises collection (optionally key-protected via APP_ADMIN_KEY or ADMIN_KEY environment variable).

Achievements System:

AchievementId enum and Achievement entity (see lib/core/domain/entities/achievement.dart).

Achievements like "Early Bird" and "First Workout" are awarded by Firebase Functions and displayed in the user's profile. achievedRewardIds list in UserProfile.

3. Core Architectural Principles

The project adheres to modern software development best practices:

Modularity (Feature-First): Functionality is organized into self-contained feature modules within lib/features/, promoting separation of concerns and easier maintenance.

Clean Architecture (Layered Approach): Each feature, and the app globally, attempts to follow a layered structure (Presentation, Domain, Data) to decouple business logic from UI and data sources.

State Management (BLoC/Cubit): flutter_bloc is extensively used for managing UI state and business logic, ensuring predictability, testability, and a clear flow of data.

Dependency Injection: RepositoryProvider and BlocProvider from flutter_bloc are used to provide dependencies (repositories, cubits) down the widget tree.

Data Abstraction (Repositories): Repository pattern abstracts data sources (primarily Firebase Firestore), providing a clean API to the domain and presentation layers.

Scalability: The architecture is designed for future expansion, allowing new features to be added with minimal impact on existing code.

Testability: Separation of logic facilitates unit testing for business logic (Cubits, repositories) and widget testing for UI components.

4. Technology Stack

Frontend:

Framework: Flutter (Dart SDK ^3.8.0)

Programming Language: Dart

State Management: flutter_bloc: ^9.1.1, bloc: ^9.0.0

Object Equality: equatable: ^2.0.5 (for BLoC states/events and entities)

Date/Time Formatting: intl: ^0.19.0

SVG Rendering: flutter_svg: ^2.0.10+1 (for muscle maps in Progress screen)

Animations & UI Effects:

animated_background: ^2.0.0 (for LavaLampBackground on LoginPage)

confetti: ^0.7.0 (for celebratory effect on WorkoutCompleteScreen)

lottie: ^3.1.2 (for trophy animation on WorkoutCompleteScreen)

Navigation: Standard Flutter Navigation (MaterialPageRoute, Navigator.push/pop/pushAndRemoveUntil).

Backend (Firebase):

Core: firebase_core: ^3.13.1

Authentication: firebase_auth: ^5.5.4 (Email/Password, Google Sign-In)

Google Sign-In Helper: google_sign_in: ^6.2.1

Database: cloud_firestore: ^5.6.8 (NoSQL database for user profiles, routines, exercises, notifications, workout logs, leagues)

Serverless Logic: Firebase Cloud Functions (TypeScript, Node.js v20, firebase-functions: ^6.0.1, firebase-admin: ^12.6.0 in functions/package.json)

Development Tools:

Linting: flutter_lints: ^5.0.0

App Icon Generation: flutter_launcher_icons: ^0.13.1

Project Snapshots: Custom Python script (create_snapshot.py)

5. Project Structure

The project follows a "feature-first" directory structure, promoting modularity and separation of concerns.

muscle_up/
├── android/                  # Android-specific platform code
├── assets/                   # Application assets
│   ├── animations/
│   │   └── trophy_animation.json # Lottie animation for WorkoutCompleteScreen
│   ├── fonts/                # Custom fonts (Inter, IBMPlexMono)
│   └── images/               # Image assets (logos, icons, muscle maps)
│       ├── app_icon.png
│       ├── google_logo.png
│       ├── male_front.svg      # SVG for male front muscle map
│       ├── male_back.svg       # SVG for male back muscle map
│       ├── female_front.svg    # SVG for female front muscle map
│       └── female_back.svg     # SVG for female back muscle map
├── functions/                # Firebase Cloud Functions (TypeScript)
│   ├── src/
│   │   └── index.ts          # Main Cloud Functions logic (Auth, Firestore triggers, HTTP)
│   ├── package.json          # NPM dependencies for Cloud Functions
│   ├── tsconfig.json         # TypeScript configuration for Functions
│   └── .eslintrc.js          # ESLint configuration for Functions code quality
├── ios/                      # iOS-specific platform code
├── lib/                      # Main Dart application code
│   ├── auth_gate.dart        # Handles auth state changes and profile setup redirection
│   ├── firebase_options.dart # Firebase configuration (generated by FlutterFire CLI)
│   ├── home_page.dart        # Main screen with BottomNavigationBar, AppBar, FAB
│   ├── login_page.dart       # Login/Registration screen with animated background
│   ├── main.dart             # App entry point, MaterialApp, RepositoryProviders, Theme setup
│   │
│   ├── core/                 # Shared core logic, domain entities, and repository interfaces
│   │   └── domain/
│   │       ├── entities/     # Plain Dart Objects representing business models
│   │       │   ├── achievement.dart        # Model for achievements
│   │       │   ├── app_notification.dart   # Model for in-app notifications
│   │       │   ├── league_info.dart        # Model for fitness leagues (NEW)
│   │       │   ├── logged_exercise.dart    # Model for an exercise logged in a workout
│   │       │   ├── logged_set.dart         # Model for a set logged in an exercise
│   │       │   ├── predefined_exercise.dart# Model for standardized exercises in the library
│   │       │   ├── routine.dart            # Models for UserRoutine and RoutineExercise
│   │       │   ├── user_profile.dart       # Model for user profile data
│   │       │   └── workout_session.dart    # Model for a workout session
│   │       └── repositories/ # Abstract interfaces for data repositories
│   │           ├── league_repository.dart              # Interface for league data (NEW)
│   │           ├── notification_repository.dart      # Interface for notification data
│   │           ├── predefined_exercise_repository.dart # Interface for exercise library data
│   │           ├── routine_repository.dart           # Interface for user routine data
│   │           ├── user_profile_repository.dart      # Interface for user profile data
│   │           └── workout_log_repository.dart       # Interface for workout log data
│   │
│   ├── features/             # Feature-specific modules
│   │   ├── dashboard/
│   │   │   └── presentation/screens/dashboard_screen.dart # UI for the main dashboard tab
│   │   ├── exercise_explorer/  # Feature for browsing and selecting exercises
│   │   │   ├── data/repositories/predefined_exercise_repository_impl.dart
│   │   │   └── presentation/   # Cubit, screens, and widgets for exercise explorer
│   │   ├── notifications/      # Feature for managing and displaying notifications
│   │   │   ├── data/repositories/notification_repository_impl.dart
│   │   │   └── presentation/   # Cubit, screens, and widgets for notifications
│   │   ├── profile/            # Feature for displaying user profile
│   │   │   └── presentation/   # Cubit and screen for user profile view
│   │   ├── profile_setup/      # Feature for initial user profile configuration
│   │   │   ├── data/repositories/user_profile_repository_impl.dart
│   │   │   └── presentation/   # Cubit and screen for profile setup form
│   │   ├── progress/           # NEW: Feature for tracking and visualizing user progress
│   │   │   ├── data/repositories/league_repository_impl.dart # Implementation for league data
│   │   │   └── presentation/
│   │   │       ├── cubit/      # Cubit and state for progress screen logic
│   │   │       │   ├── progress_cubit.dart
│   │   │       │   └── progress_state.dart
│   │   │       ├── screens/progress_screen.dart      # Main UI for the progress screen
│   │   │       └── widgets/    # Reusable widgets for the progress screen
│   │   │           ├── league_title_widget.dart    # Displays current league and level
│   │   │           ├── muscle_map_widget.dart      # Renders and colors SVG muscle map
│   │   │           └── xp_progress_bar_widget.dart # Animated XP progress bar
│   │   ├── routines/           # Feature for managing user workout routines
│   │   │   ├── data/repositories/routine_repository_impl.dart
│   │   │   └── presentation/   # Cubits, screens, and widgets for routines
│   │   └── workout_tracking/   # Feature for active workout tracking and completion
│   │       ├── data/repositories/workout_log_repository_impl.dart
│   │       └── presentation/   # Cubit, screens, and widgets for workout tracking
│   │
│   ├── utils/                # General utility functions
│   │   └── duration_formatter.dart # Formats Duration objects into readable strings
│   │
│   └── widgets/              # Common reusable widgets used across multiple features
│       └── lava_lamp_background.dart # Animated background for LoginPage
│
├── pubspec.yaml              # Project configuration, dependencies, assets
├── README.md                 # This file (you are reading it!)
└── ...                       # Other config files (.firebaserc, firebase.json, .gitignore)
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END
6. Deep Dive into Key Components & UX
6.1. Authentication & Profile Setup

LoginPage: The initial screen for unauthenticated users, featuring an attractive LavaLampBackground. It provides forms for Email/Password sign-in/sign-up and a "Sign in with Google" button.

AuthGate: This central widget listens to Firebase Auth state changes.

Upon successful authentication, it attempts to stream the user's profile from Firestore via UserProfileRepository.

It gracefully handles potential delays between Firebase Auth user creation and the Firestore document creation by the createUserProfile Firebase Function, by displaying a loading indicator ("Finalizing account setup...").

If the fetched UserProfile has profileSetupComplete == false, the user is navigated to ProfileSetupScreen.

If profileSetupComplete == true, the user is navigated to HomePage.

AuthGate also provides the UserProfileCubit to the HomePage and its descendants.

Firebase Function createUserProfile (Auth v1 Trigger): Automatically triggers when a new user is created in Firebase Authentication. It creates a corresponding document in the users collection in Firestore, initializing default fields like email, displayName (if available from Auth provider), xp: 0, level: 1, and critically, profileSetupComplete: false.

ProfileSetupScreen: A guided form allowing users to input essential profile details: a unique username (mandatory), display name, gender, date of birth, height, weight, primary fitness goal, and activity level. This screen uses ProfileSetupCubit to manage form state and save data. Upon successful submission, profileSetupComplete is set to true in the user's profile.

Firebase Function checkProfileSetupCompletionAchievements (Firestore v2 Trigger): This function monitors writes to user documents. If the profileSetupComplete field changes from false (or non-existent) to true, and the "Early Bird" achievement (AchievementId.EARLY_BIRD) hasn't been awarded yet, it adds the achievement ID to the user's achievedRewardIds array and creates a corresponding notification.

UserProfileCubit: A globally accessible Cubit (provided via AuthGate to HomePage) responsible for loading and providing UserProfile data from Firestore. It listens to real-time changes in the user's profile to update the UI dynamically.

6.2. Main Navigation: HomePage & DashboardScreen

HomePage: The central hub of the application after successful authentication and profile setup.

AppBar: Displays "MuscleUP" (clickable to return to the Dashboard) alongside the title of the currently active tab (e.g., "MuscleUP | My Routines").

BottomNavigationBar: Allows easy switching between:

"ROUTINES": UserRoutinesScreen

"EXPLORE": ExerciseExplorerScreen

"PROGRESS": ProgressScreen (New)

"PROFILE": ProfileScreen

FloatingActionButton ("START WORKOUT"): Located on the Dashboard tab. Tapping it checks for an active (in-progress) WorkoutSession via WorkoutLogRepository.

If an active session exists, it navigates to ActiveWorkoutScreen to resume it.

If no active session, it presents a dialog to start a new workout either "From Routine" (navigates to Routines tab) or as an "Empty Workout" (navigates directly to ActiveWorkoutScreen).

Provides NotificationsCubit to its children, enabling the Dashboard to display notifications.

DashboardScreen: The content for the primary "MuscleUP" tab (when no BottomNavigationBar item is explicitly selected, i.e., _selectedIndex = -1 in HomePage).

Displays a personalized greeting (e.g., "Welcome, John") using the name from UserProfileCubit and a workout streak icon (fire icon with streak count). Tapping the greeting navigates to ProfileScreen; tapping the streak icon navigates to ProgressScreen.

"STATS" Section: Placeholder for a "Total Volume" graph. Displays cards for "WEIGHT", "STREAK", and "ADHERENCE" (data partially from UserProfileCubit).

"NOTIFICATIONS" Section: Dynamically lists recent notifications using NotificationListItem, shows an unread notifications count, and includes a "READ ALL" button. Powered by NotificationsCubit.

6.3. Notification System

AppNotification Model: Defines the structure for notifications, including id, type (enum: achievementUnlocked, workoutReminder, systemMessage, etc.), title, message, timestamp, isRead status, relatedEntityId (e.g., ID of an achievement), relatedEntityType (e.g., "achievement"), and iconName.

NotificationRepositoryImpl: Implements the NotificationRepository interface. Handles all Firestore interactions for the users/{userId}/notifications subcollection, including fetching, marking as read/unread, and deleting notifications.

NotificationsCubit: Manages the state of the notification list for the current user. It subscribes to real-time updates from Firestore via NotificationRepository and updates the UI accordingly. It also features an achievementAlertController (a StreamController) to broadcast new achievement notifications, allowing other parts of the UI (like HomePage) to show immediate alerts (e.g., SnackBars) even if the notification list itself isn't visible.

NotificationListItem: A widget to display a single notification in a list. Supports swipe-to-delete functionality. Tapping navigates to NotificationDetailScreen.

NotificationDetailScreen: Displays the full content of a selected notification. Automatically marks the notification as read if it wasn't already.

6.4. Exercise Library

PredefinedExercise Model: Represents a standardized exercise with attributes like name, normalizedName (for case-insensitive search), primaryMuscleGroup, secondaryMuscleGroups, equipmentNeeded, description, videoDemonstrationUrl, difficultyLevel, and tags.

PredefinedExerciseRepositoryImpl: Fetches the list of all predefined exercises from the predefinedExercises collection in Firestore.

Firebase Function seedPredefinedExercises (HTTPS v2 Trigger): An HTTP-triggered function that populates the predefinedExercises collection with an initial set of exercise data. This function is useful for initial app setup and can be protected by an admin key. It avoids creating duplicate exercises by checking the normalizedName.

ExerciseExplorerCubit: Responsible for fetching and caching the list of predefined exercises for display in the ExerciseExplorerScreen.

ExerciseExplorerScreen: UI for browsing the exercise library. It can operate in two modes:

Normal mode: For viewing exercise details (details screen TBD).

Selection mode (isSelectionMode: true): Used when adding exercises to a routine, where selecting an exercise returns the PredefinedExercise object to the calling screen/dialog .

6.5. Workout Routine Management

UserRoutine & RoutineExercise Models:

UserRoutine: Represents a user-created workout plan, including id, userId, name, description, a list of RoutineExercise objects, scheduledDays, and isPublic flag.

RoutineExercise: Details an exercise within a routine, including predefinedExerciseId, a snapshot of the exerciseNameSnapshot at the time of adding, numberOfSets, and optional notes.

RoutineRepositoryImpl: Implements CRUD (Create, Read, Update, Delete) operations for user routines stored in the userRoutines Firestore collection, ensuring operations are tied to the correct userId.

UserRoutinesCubit: Fetches and provides the list of all routines created by the current user for display in UserRoutinesScreen.

ManageRoutineCubit: Manages the state during the creation of a new routine or editing of an existing one. It holds the intermediate state of the routine being edited (name, description, exercises, etc.) and handles the final save/update to Firestore.

UserRoutinesScreen: Displays a list of the user's workout routines using RoutineListItem. A FAB allows navigation to CreateEditRoutineScreen.

CreateEditRoutineScreen: A form for creating a new routine or modifying an existing one. Users can set the routine's name, description, and select scheduled days of the week. Exercises are added using AddExerciseToRoutineDialog. Each exercise within the routine can be configured (number of sets, notes) or removed.

AddExerciseToRoutineDialog: A custom dialog that utilizes ExerciseExplorerScreen (in selection mode) to pick a PredefinedExercise. After selection, the user specifies the numberOfSets and any notes for that exercise within the context of the current routine.

6.6. Workout Tracking

Entities:

WorkoutSession: The primary entity representing a single training session. Contains id, userId, optional routineId and routineNameSnapshot, startedAt, endedAt (Timestamp), durationSeconds, a list of LoggedExercise objects, general notes for the session, status (enum: inProgress, completed, cancelled), and totalVolume.

LoggedExercise: Represents an exercise performed during the session. Includes predefinedExerciseId, exerciseNameSnapshot, targetSets (from the routine, if applicable), a list of LoggedSet objects, and exercise-specific notes.

LoggedSet: Represents a single set performed for an exercise. Contains setNumber, weightKg, reps (number of repetitions), isCompleted status, and notes. The notes field for a LoggedSet is specifically used to store RPE data in the format "RPE_DATA:val1,val2,...".

WorkoutLogRepositoryImpl: Manages WorkoutSession documents in the users/{userId}/workoutLogs subcollection. Implements logic for starting new sessions, updating set/exercise data within a session, and finalizing sessions (completing or cancelling). Provides a stream (getActiveWorkoutSessionStream) to monitor any ongoing workout.

ActiveWorkoutCubit:

Manages the state of an active workout. On initialization, it subscribes to getActiveWorkoutSessionStream to automatically load an in-progress session if one exists.

startNewWorkout({UserRoutine? fromRoutine}): Creates a new WorkoutSession document in Firestore with status: inProgress. If a UserRoutine is provided, it copies the exercise structure (including target sets) into the new session.

updateLoggedSet(...): Updates the details of a specific LoggedSet (weight, reps, RPE data, notes) in the Cubit's local state and then synchronizes these changes with the corresponding WorkoutSession document in Firestore.

addSetToExercise(int exerciseIndex): Allows the user to add an extra, empty set to the currently active exercise during a workout.

completeWorkout(): Sets the WorkoutSession status to completed, calculates durationSeconds and totalVolume, and updates the document in Firestore. This update triggers the calculateAndAwardXpAndStreak Firebase Function.

cancelWorkout(): Sets the WorkoutSession status to cancelled in Firestore.

Maintains and updates an in-app timer (_durationTimer) to display the elapsed time of the active workout.

Firebase Function calculateAndAwardXpAndStreak (Firestore v2 Trigger):

Triggers when a document in users/{userId}/workoutLogs/{sessionId} is updated and its status field changes to completed.

Calculates XP earned: baseXP (50) + (totalVolume / 100) + (durationSeconds / 300), capped at 200 XP.

Updates the user's UserProfile document: increments xp, recalculates level (based on a formula: xpPerLevelBase (200) + (level - 1) * 50 for each level), updates currentStreak and longestStreak (resets streak to 1 if not consecutive, otherwise increments), and sets lastWorkoutTimestamp.

Awards the "First Workout" achievement (AchievementId.FIRST_WORKOUT) if it's the user's first completed workout (by checking achievedRewardIds) and creates an appropriate AppNotification.

ActiveWorkoutScreen:

The main UI for an ongoing workout session. If a routineForNewWorkout is passed to its route, it initiates the creation of a new session via ActiveWorkoutCubit. Otherwise, the Cubit attempts to load an existing active session.

Displays the routine name (or "Active Workout"), and an elapsed time timer.

The central component is CurrentSetDisplay.

Provides navigation buttons: "PREV. SET", "NEXT SET", "NEXT EXERCISE", and "FINISH WORKOUT". Logic handles skipping exercises with no sets.

CurrentSetDisplay Widget:

Displays the current exercise name, set number, and target number of sets (if from a routine).

Input field for weightKg (editable via a dialog).

"+" and "-" buttons to adjust the number of reps performed.

Unique RPE Sliders: After setting the number of reps, a corresponding number of vertical RPE sliders (scale 0-10, with color gradient from green to red) appear. Users rate the perceived exertion for each individual repetition. This RPE data is then compiled into a string (e.g., "RPE_DATA:7,8,8,9,7") and stored in the notes field of the LoggedSet.

Data for the current set (weight, reps, RPE) is saved via ActiveWorkoutCubit when navigating to another set/exercise or when finishing the workout.

WorkoutCompleteScreen:

Automatically navigated to after a workout is successfully completed (triggered by ActiveWorkoutCubit transitioning to ActiveWorkoutSuccessfullyCompleted state).

Features a celebratory Lottie animation (assets/animations/trophy_animation.json) and a ConfettiWidget effect.

Displays a summary of the completed workout: routine name (if applicable), duration, and total volume.

Shows the XP gained (passed from ActiveWorkoutCubit) and an animated progress bar visualizing XP progression towards the next level.

Displays level-up information if the user advanced a level, based on the updatedUserProfile passed to the screen.

A "Awesome!" button navigates the user back to AuthGate (which then typically leads to HomePage).

6.7. Progress Tracking (ProgressScreen & ProgressCubit)

The Progress screen offers users a multifaceted view of their fitness journey, emphasizing visual feedback and statistical insights.

Purpose: To provide users with a clear understanding of their training achievements, how their efforts are distributed across different muscle groups, and their strength progression over time. This aims to enhance motivation and inform future training decisions.

ProgressCubit: This is the brain behind the Progress screen.

It fetches data from multiple repositories: UserProfileRepository (for current XP, level), LeagueRepository (for league definitions), WorkoutLogRepository (for historical workout data), and PredefinedExerciseRepository (to map exercise IDs to names and muscle groups).

It subscribes to real-time updates of the UserProfile to reflect changes in XP and level immediately.

It processes raw workout data to calculate derived statistics like volume per muscle group, average RPE, and average working weights.

It caches _allLeagues and _allPredefinedExercises upon initialization to optimize subsequent lookups.

League System:

LeagueInfo entities (stored in the leagues Firestore collection) define various fitness leagues (e.g., "BEGINNER LEAGUE", "BRONZE LEAGUE", "GOLDEN LEAGUE"). Each league has a minLevel, maxLevel (optional for the highest league), minXp, maxXp (optional), descriptive name, and gradientColors for visual styling.

The ProgressCubit determines the user's currentLeague based on their UserProfile.level.

LeagueTitleWidget displays the name of the user's current league with its associated gradient colors and the user's current level number.

XP & Leveling Progress:

XPProgressBarWidget displays an animated progress bar showing how much XP the user has accumulated within their current level and how much is needed for the next level.

The XP values (xpForCurrentLevelStart, xpForNextLevelTotal) are calculated by ProgressCubit based on the game's leveling formula (consistent with the calculateAndAwardXpAndStreak Firebase Function).

Muscle Map Visualization (MuscleMapWidget):

This widget uses flutter_svg to render gender-specific front and back body SVGs (e.g., assets/images/male_front.svg, assets/images/female_front.svg), which contain <g> (group) elements tagged with specific muscle ID attributes (e.g., id="chest", id="biceps").

Data Source: The ProgressCubit calculates volumePerMuscleGroup7Days. This map holds the total number of completed sets for each muscle group (identified by SVG IDs) over the last 7 days. The mapping from exercise primary/secondary muscle groups (strings like "Chest") to SVG IDs (like "chest") is handled internally by the cubit.

Dynamic Coloring: The MuscleMapWidget takes the muscleData and applies colors to the SVG paths.

Muscle groups with no recent volume are shown in a baseColor (e.g., light grey).

As volume increases, the color transitions through a midColor (e.g., MuscleUP orange) up to a maxColor (e.g., deep red) at a maxThreshold. The midThreshold defines the point at which the color starts shifting more intensely towards the maxColor.

Training Statistics:

Average RPE per Exercise (Last 30 Days): ProgressCubit parses RPE data (from "RPE_DATA:..." strings in LoggedSet.notes) from workout logs over the past 30 days. It then calculates and displays the average RPE for each distinct exercise performed. This helps users gauge their perceived exertion levels for different movements.

Average Working Weights per Exercise (Last 90 Days): ProgressCubit aggregates weightKg data from completed sets in workout logs over the last 90 days for each distinct exercise. It then calculates and displays the average working weight, offering a view of strength trends.

Data Refresh: The ProgressScreen uses a RefreshIndicator (pull-to-refresh) to allow users to manually trigger a refresh of all displayed progress data via ProgressCubit.refreshData().

6.8. Achievements System

AchievementId Enum & Achievement Entity: AchievementId (e.g., EARLY_BIRD, FIRST_WORKOUT) provides unique identifiers. The Achievement class (defined in lib/core/domain/entities/achievement.dart) stores details like name, description, IconData, and an optional conditionCheckerMessage function to display progress towards unearned achievements. A global map allAchievements centralizes these definitions.

Awarding Logic: Achievements are typically awarded by Firebase Cloud Functions (checkProfileSetupCompletionAchievements for "Early Bird", calculateAndAwardXpAndStreak for "First Workout") based on specific user actions or data milestones.

Storage & Notifications: When an achievement is awarded, its AchievementId.name (e.g., "earlyBird") is added to the achievedRewardIds list in the user's UserProfile document. An AppNotification of type achievementUnlocked is also created.

Display: Achieved rewards are visually represented on the ProfileScreen, often with icons and tooltips showing their descriptions. The NotificationsCubit's achievementAlertController can trigger immediate SnackBars when new achievements are detected from the notification stream.

6.9. Quality of Life & UX Details

Animated Background: The LoginPage features a LavaLampBackground widget, creating a visually engaging and modern welcome experience with smoothly moving, blurred colored blobs.

Custom Theming: A detailed Material 3 theme is defined in main.dart. It uses custom fonts (Inter for general UI and IBMPlexMono for specific elements like statistics or code-like text), a consistent color palette (primary orange, accent colors), and customized styles for AppBar, BottomNavigationBar, ElevatedButton, Card, etc., ensuring a cohesive and branded look and feel.

Intuitive Navigation & Feedback:

Clear navigation patterns between sets and exercises within the ActiveWorkoutScreen.

Confirmation dialogs for critical actions (e.g., deleting routines, canceling workouts, logging out).

SnackBars provide immediate visual feedback for operations like saving data, errors, or successful actions.

Loading Indicators: CircularProgressIndicators are used strategically to indicate data fetching or processing, improving user perception of responsiveness.

RPE Sliders: The unique RPE-per-repetition sliders in CurrentSetDisplay offer a granular way for users to track subjective effort, a key differentiator for the app.

Celebratory Animations: The WorkoutCompleteScreen uses confetti and a Lottie trophy_animation.json to create a rewarding and gamified experience upon workout completion. The XP bar also animates.

Logging: Uses dart:developer's log function for detailed debug messages, aiding in development and troubleshooting.

Automatic UI Updates: Flutter BLoC/Cubit pattern combined with Firestore streams ensures that UI components reactively update to changes in data (e.g., user profile updates reflected in HomePage and DashboardScreen, new notifications appearing in real-time).

Optimized Exercise Selection: ExerciseExplorerScreen offers an isSelectionMode for streamlined addition of exercises to routines.

Duration Formatting: duration_formatter.dart provides a utility to display Duration objects in a user-friendly HH:MM:SS or MM:SS format.

7. Backend: Firebase Cloud Firestore Structure

The Firestore database is structured to efficiently store and retrieve application data:

users/{userId}: Top-level collection for user-specific data. Each document ID is the Firebase Auth UID.

Fields:

uid: (String) User's Firebase Auth UID.

email: (String, nullable) User's email.

displayName: (String, nullable) User's chosen display name.

profilePictureUrl: (String, nullable) URL to the user's profile image.

username: (String, nullable) Unique username chosen by the user.

gender: (String, nullable) User's gender (e.g., "male", "female").

dateOfBirth: (Timestamp, nullable) User's date of birth.

heightCm: (Number, nullable) User's height in centimeters.

weightKg: (Number, nullable) User's weight in kilograms.

fitnessGoal: (String, nullable) User's primary fitness goal (e.g., "gain_muscle").

activityLevel: (String, nullable) User's general activity level (e.g., "moderate").

xp: (Number) Total experience points earned.

level: (Number) Current user level.

currentStreak: (Number) Current workout streak in days.

longestStreak: (Number) Longest workout streak achieved.

lastWorkoutTimestamp: (Timestamp, nullable) Timestamp of the last completed workout.

followersCount: (Number) Count of users following this user (for future social features).

followingCount: (Number) Count of users this user is following (for future social features).

achievedRewardIds: (Array<String>) List of IDs of achievements unlocked by the user.

profileSetupComplete: (Boolean) Flag indicating if the user has completed the initial profile setup.

createdAt: (Timestamp) Server timestamp of when the user profile document was created.

updatedAt: (Timestamp) Server timestamp of the last update to the profile document.

Subcollection notifications/{notificationId}: Stores individual notifications for the user.

Fields per AppNotification: type, title, message, timestamp, isRead, iconName, relatedEntityId, relatedEntityType.

Subcollection workoutLogs/{sessionId}: Stores records of each workout session.

Fields per WorkoutSession: userId, routineId (optional), routineNameSnapshot (optional), startedAt, endedAt (optional), durationSeconds (optional), completedExercises (Array of LoggedExercise objects), notes (optional, session-wide), status (String: "inProgress", "completed", "cancelled"), totalVolume (optional).

Each object in completedExercises (representing a LoggedExercise) contains: predefinedExerciseId, exerciseNameSnapshot, targetSets, notes (optional, exercise-specific), and an array completedSets.

Each object in completedSets (representing a LoggedSet) contains: setNumber, weightKg (optional), reps (optional), isCompleted, notes (optional, can store "RPE_DATA:x,y,z").

predefinedExercises/{exerciseId}: Top-level collection for the standardized exercise library.

Fields per PredefinedExercise: name, normalizedName (for search), primaryMuscleGroup, secondaryMuscleGroups (Array<String>), equipmentNeeded (Array<String>), description, videoDemonstrationUrl (optional), difficultyLevel, tags (Array<String>), createdAt, updatedAt.

userRoutines/{routineId}: Top-level collection for user-created workout routines.

Fields per UserRoutine: userId, name, description (optional), exercises (Array of RoutineExercise objects), scheduledDays (Array<String>), isPublic, createdAt, updatedAt.

Each object in exercises (representing a RoutineExercise) contains: predefinedExerciseId, exerciseNameSnapshot, numberOfSets, notes (optional).

leagues/{leagueId}: Top-level collection defining fitness leagues. (NEW)

Fields per LeagueInfo: name, minLevel, maxLevel (optional), minXp, maxXp (optional), gradientColors (Array<String> of hex color codes), description (optional).

8. Firebase Cloud Functions Logic (functions/src/index.ts)

Server-side automation and critical business logic are handled by Firebase Cloud Functions, written in TypeScript and deployed to the Node.js v20 environment. The default region for these functions is us-central1.

createUserProfile (Auth v1 Trigger - functionsV1.auth.user().onCreate):

Trigger: Automatically executes when a new user account is created in Firebase Authentication.

Action: Creates a corresponding user document in the users/{userId} collection in Cloud Firestore.

Details: Initializes the profile with default values: uid (from Auth), email (from Auth, if available), displayName (from Auth, if available), profilePictureUrl (from Auth, if available), xp = 0, level = 1, profileSetupComplete = false, and server timestamps for createdAt and updatedAt.

calculateAndAwardXpAndStreak (Firestore v2 Trigger - onDocumentUpdated("users/{userId}/workoutLogs/{sessionId}")):

Trigger: Executes when a document within any user's workoutLogs subcollection is updated.

Condition: The function's logic specifically checks if the status field of the workout log has changed to "completed".

Actions:

Calculate XP: xpGained = baseXP (50) + (totalVolume / 100) + (durationSeconds / 300). The result is capped at a maximum of 200 XP per workout.

Update User Profile: Fetches the current UserProfile document.

Streak Logic: Updates currentStreak (increments if the workout is on a consecutive day after the lastWorkoutTimestamp, otherwise resets to 1) and longestStreak.

Sets lastWorkoutTimestamp to the endedAt time of the completed workout.

Adds xpGained to the user's total xp.

Level Calculation: Recalculates the user's level based on their new total xp. The formula for XP required to complete a level is xpPerLevelBase (200) + (currentLevel - 1) * 50.

"First Workout" Achievement: If the AchievementId.FIRST_WORKOUT is not already present in the user's achievedRewardIds array, it adds the ID and creates an AppNotification of type achievementUnlocked.

Saves all updates back to the UserProfile document.

checkProfileSetupCompletionAchievements (Firestore v2 Trigger - onDocumentWritten("users/{userId}")):

Trigger: Executes whenever a user's document in the users collection is created or updated.

Condition: The function checks if the profileSetupComplete field has transitioned from false (or non-existent) to true.

Action: If the condition is met and the AchievementId.EARLY_BIRD is not already in the user's achievedRewardIds, it adds the achievement ID and creates an AppNotification of type achievementUnlocked.

seedPredefinedExercises (HTTPS v2 Trigger - onRequest):

Trigger: An HTTP-callable endpoint (GET or POST).

Action: Populates the predefinedExercises Firestore collection with a hardcoded array of exercise data (predefinedExercisesData within the function code).

Security: Can be optionally protected by an admin key. The function checks for a key query parameter and compares it against the APP_ADMIN_KEY or ADMIN_KEY environment variable (if set). If the key is not provided or is incorrect (and an admin key is configured in the environment), the request is denied. If no admin key is set in the environment, the function executes without this key check (a warning is logged).

Duplicate Prevention: Before adding an exercise, it queries the collection to check if an exercise with the same normalizedName already exists, thus preventing duplicates. It uses Firestore batch writes for efficiency.

9. Setup and Running the Project

Flutter SDK: Ensure you have the Flutter SDK installed (version compatible with ^3.8.0 as specified in pubspec.yaml).

Clone Repository: git clone <repository_url>

Firebase Project Setup:

Go to the Firebase Console and create a new Firebase project (or use an existing one, e.g., muscle-up-8c275).

Add an Android app to your Firebase project:

Package Name: com.example.muscle_up (Ensure this matches android/app/build.gradle.kts).

Download the google-services.json file and place it in the android/app/ directory.

Add an iOS app to your Firebase project:

Bundle ID: com.example.muscleUp (Ensure this matches your Xcode project settings).

Download the GoogleService-Info.plist file and place it in the ios/Runner/ directory.

In the Firebase Console, navigate to Authentication -> Sign-in method and enable:

Email/Password

Google (ensure you've configured SHA-1 fingerprints for Android if required).

Navigate to Firestore Database and create a database. Start in test mode for initial development, then implement security rules (see example below or section 7 of this README for structure).

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile and subcollections
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /notifications/{notificationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /workoutLogs/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    // All authenticated users can read predefined exercises
    // Writes are typically restricted to admin/functions
    match /predefinedExercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false; // Or admin-only rules
    }
    // Users can only read/write their own routines
    match /userRoutines/{routineId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    // Leagues are public read
    match /leagues/{leagueId} {
        allow read: if true; // Or request.auth != null;
        allow write: if false; // Admin only
    }
  }
}
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Firestore.rules
IGNORE_WHEN_COPYING_END

Firebase Functions Setup:

Install Firebase CLI: npm install -g firebase-tools.

Login: firebase login.

Associate with your project: firebase use YOUR_PROJECT_ID (replace YOUR_PROJECT_ID with your actual Firebase project ID, e.g., muscle-up-8c275).

Install function dependencies: cd functions && npm install && cd ...

(Optional, for seedPredefinedExercises protection) Set admin key: firebase functions:config:set app.admin_key="YOUR_CHOSEN_SECRET_KEY" (replace with a strong key).

Deploy functions: firebase deploy --only functions.

Flutter Dependencies: In the root directory of the Flutter project, run: flutter pub get.

Generate App Icons: (Optional) If you've updated assets/images/app_icon.png, run: flutter pub run flutter_launcher_icons.

Run the Application: Connect an emulator or physical device and run: flutter run.

Seed Predefined Exercises:

After deploying the Firebase Functions, you can populate the predefinedExercises collection.

Find the HTTPS URL for your seedPredefinedExercises function in the Firebase Console (Functions tab).

Call this URL from a browser or using curl. If you configured an admin key, append it as a query parameter:
https://<region>-<project-id>.cloudfunctions.net/seedPredefinedExercises?key=YOUR_CHOSEN_SECRET_KEY
(Replace <region> e.g., us-central1, and <project-id> with your details).

10. Future Development

MuscleUP has a roadmap for continued growth and feature enhancement:

Full Implementation of Screens: Complete "Posts" (user-generated content feed) and flesh out "Profile" details (advanced statistics, visual progress charts, full achievement display).

Enhanced Social Features: Implement user following/follower system, activity feeds, comments on posts/workouts, likes, and potentially direct messaging.

Public Records & Leaderboards: Develop a system for users to submit personal records for specific exercises, potentially with community validation. Introduce leaderboards based on various metrics (total volume, XP, specific lift PBs).

Advanced Gamification: Expand the achievement system with more diverse and challenging rewards. Introduce seasonal leagues or challenges with unique badges.

Personalized Goal Setting & Tracking: Allow users to set more granular goals (e.g., target weight for a specific lift, rep max goals for exercises) and automatically track progress towards these goals.

Push Notifications: Implement Firebase Cloud Messaging for timely reminders (workouts, hydration), new achievement alerts, and social interaction notifications.

Comprehensive Testing: Increase test coverage with more unit tests for business logic, widget tests for UI components, and integration tests for key user flows.

UI/UX Refinements: Continuously improve the user interface and experience based on user feedback, A/B testing, and design best practices.

Admin Panel: Create a web-based admin panel for managing application content (e.g., predefinedExercises, leagues), moderating user-generated content, and viewing app analytics.

Wearable Device Integration: Explore integration with popular fitness trackers (e.g., Garmin, Apple Watch, Fitbit) to sync workout data and health metrics.

Offline Support: Implement basic offline capabilities, allowing users to log workouts even without an internet connection, with data syncing once connectivity is restored.

Advanced Analytics & Insights: Provide users with deeper analytics on their training patterns, recovery trends, potential overtraining indicators, and personalized performance insights.