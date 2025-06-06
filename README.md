Of course. Here is a comprehensive documentation for the "Muscle UP!" Flutter project, structured in Markdown format as requested.

# Muscle UP! - Project Documentation

This document provides a detailed overview of the Muscle UP! Flutter application, covering its mission, architecture, features, backend logic, and implementation details.

## Table of Contents
1.  [Project Overview](#1-project-overview)
    -   [Mission & Vision](#11-mission--vision)
    -   [Current State](#12-current-state)
    -   [Core Philosophy](#13-core-philosophy)
2.  [Core Technologies & Architecture](#2-core-technologies--architecture)
    -   [Technology Stack](#21-technology-stack)
    -   [Architectural Design](#22-architectural-design)
3.  [Feature Breakdown](#3-feature-breakdown)
    -   [Authentication & Onboarding](#31-authentication--onboarding)
    -   [Dashboard](#32-dashboard)
    -   [Routine Management](#33-routine-management)
    -   [Workout Tracking](#34-workout-tracking)
    -   [Progress & Gamification](#35-progress--gamification)
    -   [Social & Community](#36-social--community)
4.  [Backend: Firebase Cloud Functions](#4-backend-firebase-cloud-functions)
    -   [Overview](#41-overview)
    -   [Key Functions](#42-key-functions)
5.  [Core Domain & Data Models](#5-core-domain--data-models)
    -   [Entity Overview](#51-entity-overview)
    -   [Key Entities Detailed](#52-key-entities-detailed)
6.  [UI, Design & Localization](#6-ui--design)
    -   [Theming & Styling](#61-theming--styling)
    -   [Custom Widgets & Animations](#62-custom-widgets--animations)
    -   [Localization](#63-localization)
7.  [Project Setup & Configuration](#7-project-setup--configuration)
    -   [Dependencies](#71-dependencies)
    -   [Platform Configuration](#72-platform-configuration)
8.  [Potential Improvements & Next Steps](#8-potential-improvements--next-steps)

---

## 1. Project Overview

### 1.1. Mission & Vision
As stated in the `pubspec.yaml`, Muscle UP! is a "Next-gen Fitness App. New height, New companions." This mission drives its two primary focuses:

1.  **Advanced Fitness Tracking:** Providing users with tools to create, manage, and track detailed workout routines. The system is designed to capture not just exercises and sets, but also nuanced data like RPE (Rate of Perceived Exertion) to provide deeper insights into progress.
2.  **Community & Gamification:** Building a social layer on top of fitness tracking. This includes user profiles, followers, posts, achievements, and a unique record-claiming system, turning personal fitness into a shared, engaging, and competitive experience.

### 1.2. Current State
The project is at **version 0.9.5**, indicating it is in a late-stage development or beta phase, nearing a version 1.0 release. Most core features are implemented, including user authentication, profile setup, routine creation, workout tracking, a social feed, and sophisticated backend logic for calculating stats and achievements. The focus is likely on refinement, bug fixing, and completing the implementation of all designed features.

### 1.3. Core Philosophy
The project's structure and code demonstrate a commitment to several key software engineering principles:

*   **Scalability:** A feature-driven, layered architecture is used to keep code organized and maintainable as the app grows.
*   **Separation of Concerns:** Business logic (Cubits), data handling (Repositories), and UI (Screens/Widgets) are distinctly separated.
*   **Reactivity:** The application heavily relies on Streams and the Bloc/Cubit pattern to ensure the UI reacts automatically to changes in data, whether from user actions or backend updates.
*   **Data Integrity:** Critical calculations like XP, streaks, and follower counts are handled by backend Firebase Functions to prevent client-side manipulation and ensure consistency.
*   **User Engagement:** Features like achievements, levels, XP, streaks, and social interactions are central to the app's design, aiming to keep users motivated and engaged.

---

## 2. Core Technologies & Architecture

### 2.1. Technology Stack
*   **Frontend:** Flutter `^3.8.0` with Dart SDK.
*   **Backend:** Google Firebase
    *   **Authentication:** Firebase Auth (Email/Password, Google Sign-In).
    *   **Database:** Cloud Firestore for real-time data storage.
    *   **Storage:** Firebase Storage for user-uploaded media (avatars, post images).
    *   **Serverless Logic:** Firebase Cloud Functions (written in TypeScript) for backend triggers and processes.
*   **State Management:** `flutter_bloc` `^9.1.1`. The project uses the Cubit pattern, a lightweight subset of BLoC.
*   **Graphics & Animations:**
    *   `flutter_svg`: For rendering SVG assets, crucial for the `MuscleMapWidget`.
    *   `lottie`: For complex JSON-based animations like the `trophy_animation.json`.
    *   `confetti`: For celebratory animations, likely on the workout completion screen.
    *   `animated_background`: Used for the dynamic `LavaLampBackground`.
*   **Utilities:**
    *   `equatable`: To simplify equality checks in BLoC states and entities.
    *   `image_picker`: For selecting images from the gallery or camera.
    *   `intl`: For internationalization (i18n) and date/number formatting.
*   **Localization:** `flutter_localizations` with `.arb` files for English (`en`) and Ukrainian (`uk`).

### 2.2. Architectural Design

The project follows a modern, scalable architecture inspired by Clean Architecture principles.

#### 2.2.1. Feature-Driven Directory Structure
The `lib/` directory is organized by feature, promoting modularity and making it easy to locate code related to a specific part of the app.

```
lib/
├── features/
│   ├── dashboard/
│   ├── profile/
│   ├── routines/
│   ├── social/
│   └── ... (etc.)
├── core/
│   ├── domain/
│   │   ├── entities/
│   │   └── repositories/
│   └── services/
└── ... (main.dart, auth_gate.dart)
```

#### 2.2.2. Layered Architecture
Within each feature, a clear separation of layers is maintained:

1.  **Presentation Layer:**
    *   **Screens (`screens/`):** The top-level widgets for each feature route (e.g., `ProfileScreen`, `ActiveWorkoutScreen`).
    *   **Widgets (`widgets/`):** Reusable UI components specific to a feature.
    *   **Cubit (`cubit/`):** Manages the state for the UI. It receives events (as function calls), interacts with repositories, and emits new states to which the UI listens and rebuilds.

2.  **Domain Layer (`lib/core/domain/`)**
    *   **Entities (`entities/`):** Plain Dart objects representing the core business models of the app (e.g., `UserProfile`, `Post`, `UserRoutine`). They are pure and have no dependency on any framework. The use of `Equatable` is standard here.
    *   **Repositories (`repositories/`):** Abstract interfaces that define the contract for data operations (e.g., `abstract class PostRepository`). This decouples the application's business logic from the specific data source implementation.

3.  **Data Layer (`lib/features/*/data/repositories/`)**
    *   **Repository Implementations:** Concrete implementations of the domain layer's repository interfaces. These classes handle the actual data fetching and manipulation from a specific source, in this case, Firebase. For example, `PostRepositoryImpl` implements `PostRepository` using Cloud Firestore.

#### 2.2.3. Dependency Injection
`MultiRepositoryProvider` in `main.dart` is used to provide repository instances down the widget tree. This allows different parts of the app, primarily Cubits, to access the data layer without being tightly coupled to its implementation.

```dart
// main.dart - Snippet
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<UserProfileRepository>(
      create: (context) => UserProfileRepositoryImpl(),
    ),
    // ... other repositories
  ],
  // ...
)
```

---

## 3. Feature Breakdown

### 3.1. Authentication & Onboarding
*   **Flow:** The user journey is managed by `lib/auth_gate.dart`.
    1.  A `StreamBuilder` listens to `FirebaseAuth.instance.authStateChanges()`.
    2.  **If not authenticated:** The user is directed to `LoginPage`.
    3.  **If authenticated:** A nested `_ProfileCheckGate` listens to the user's profile stream from Firestore.
    4.  **If profile setup is NOT complete:** The user is directed to `ProfileSetupScreen`.
    5.  **If profile setup IS complete:** The user is directed to the `HomePage`.
*   **`LoginPage`:** Features a custom animated `LavaLampBackground`, provides options for Email/Password and Google Sign-In, and handles form validation and error display.
*   **`ProfileSetupScreen`:** A form for new users to input essential data (username, display name, biometrics, goals). It can also be launched in "edit mode" from the `ProfileScreen`. It handles avatar image picking via `ImagePickerService` and uploading to Firebase Storage.

### 3.2. Dashboard
*   **File:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
*   **Purpose:** The main landing screen for an authenticated user. It acts as a hub, displaying key information at a glance.
*   **Components:**
    *   **Greeting & Stats:** Shows a personalized greeting and key stats like weight and workout streak, fetched from the `UserProfileCubit`.
    *   **Volume Trend Chart:** `VolumeTrendChartWidget` is a custom-painted chart showing the total lifting volume (in thousands of kg) of the last 7 workouts. The gradient of the chart dynamically changes based on whether the trend is positive, negative, or neutral.
    *   **Upcoming Schedule:** `UpcomingScheduleWidget` displays the user's scheduled routines for the next 7 days, powered by `UpcomingScheduleCubit`.
    *   **Notifications:** A preview of the latest notifications from the `NotificationsCubit`.
*   **State Management:** Uses `DashboardStatsCubit` and `UpcomingScheduleCubit` to fetch and display aggregated data.

### 3.3. Routine Management
*   **Files:** `lib/features/routines/`
*   **Purpose:** Allows users to create, view, edit, and delete their workout programs.
*   **Key Widgets/Screens:**
    *   `UserRoutinesScreen`: Lists all the user's routines. It's the entry point for starting a workout from a routine or creating a new one.
    *   `CreateEditRoutineScreen`: A form-based screen for building a routine. Users can set a name, description, scheduled days (using `FilterChip`s), and add exercises.
    *   `AddExerciseToRoutineDialog`: A dialog that first pushes the `ExerciseExplorerScreen` in selection mode. Once an exercise is selected, it prompts for the number of sets and notes.
    *   `ExerciseExplorerScreen`: A library of all predefined exercises, which can be viewed or selected to be added to a routine.

### 3.4. Workout Tracking
*   **Files:** `lib/features/workout_tracking/`
*   **Purpose:** Provides an interactive interface for tracking a live workout session.
*   **Flow:**
    1.  Initiated from `UserRoutinesScreen` (with a specific routine) or the main FAB (which might lead to selecting a routine).
    2.  `ActiveWorkoutCubit` either starts a new `WorkoutSession` in Firestore (with status `inProgress`) or finds an existing one.
    3.  `ActiveWorkoutScreen` displays the current exercise and set.
*   **`CurrentSetDisplay` Widget:** This is the core UI for tracking. It features:
    *   Controls to adjust weight and reps.
    *   A unique **RPE (Rate of Perceived Exertion)** tracking system with vertical sliders for each repetition. This is a "tiny trick" that allows for highly granular effort tracking. The RPE data is cleverly stored in the `notes` field of a `LoggedSet`, prefixed with `RPE_DATA:`.
    *   Navigation buttons (`< PREV. SET`, `NEXT SET >`) that save the current set's data before moving.
    *   A final "FINISH WORKOUT" button.
*   **Completion:** Upon finishing, the user is navigated to `WorkoutCompleteScreen`, a celebratory screen featuring a `Lottie` animation and a `Confetti` effect if a level-up occurred. It provides a summary of the workout and XP gained.

### 3.5. Progress & Gamification
*   **Files:** `lib/features/progress/`
*   **Purpose:** Visualizes the user's long-term progress and gamified stats.
*   **Key Widgets/Screens:**
    *   `ProgressScreen`: The main screen for this feature.
    *   `LeagueTitleWidget`: A highly stylized, animated widget displaying the user's current league and level with a shimmering gradient effect.
    *   `XPProgressBarWidget`: An animated progress bar showing XP progress within the current level.
    *   `MuscleMapWidget`: A standout feature. It takes an SVG file of a human body and dynamically colors muscle groups based on workout volume (number of sets) over the last 7 days. It cleverly parses the SVG string to inject fill colors for specific muscle IDs.
    *   `LeagueScreen`: Shows the leaderboard for a specific league, fetched from Firestore.
*   **Concepts:**
    *   **XP & Levels:** XP is awarded for workouts and other actions (see Cloud Functions). The XP required for each level increases progressively.
    *   **Leagues:** Users are grouped into leagues based on their level (`Beginner`, `Intermediate`, etc.), creating a sense of cohort and competition.
    *   **Leaderboards:** Each league has a leaderboard, ranking users by their total XP.

### 3.6. Social & Community
*   **Files:** `lib/features/social/`
*   **Purpose:** The social hub of the app, allowing users to interact, share progress, and validate each other's achievements.
*   **Core Entities:** `Post`, `Comment`.
*   **Features:**
    *   **Explore Feed (`ExploreScreen`):** A global feed of all user posts, sorted chronologically.
    *   **Post Creation (`CreatePostScreen`):** A versatile screen that handles three `PostType`s:
        1.  `standard`: A regular post with text and optional media.
        2.  `routineShare`: A post that embeds a snapshot of a user's routine, which other users can add to their own list.
        3.  `recordClaim`: A special post type where a user claims a new personal record (e.g., Bench Press 100kg x 5 reps). This triggers a community voting mechanism.
    *   **Post Interaction (`PostDetailScreen`, `PostListItem`):** Users can like posts, view and add comments, and interact with special post types. This is managed by the `PostInteractionCubit`.
    *   **Record Verification:** This is a key community feature. When a `recordClaim` post is created, it enters a 24-hour voting window. Other users can vote to `verify` or `dispute` the claim. The backend function `processRecordClaimDeadlines` resolves the claim after 24 hours.
    *   **User Profiles (`ViewUserProfileScreen`):** Allows users to view each other's profiles, see their posts and achievements, and follow/unfollow them. Follow logic is managed by `UserInteractionCubit`.

---

## 4. Backend: Firebase Cloud Functions
The `functions/src/index.ts` file contains the serverless backend logic that ensures data integrity and automates key processes. This is crucial for security and scalability.

### 4.1. Overview
*   **Language:** TypeScript
*   **Firebase SDK:** `firebase-functions` and `firebase-admin`.
*   **Triggers:** The functions are event-driven, responding to events in Firebase Auth and Firestore.

### 4.2. Key Functions
*   `createUserProfile`: An **Auth trigger** (`functionsV1.auth.user().onCreate`) that automatically creates a new user document in the `users` collection in Firestore whenever a new user signs up. This ensures every user has a profile entry.
*   `calculateAndAwardXpAndStreak`: A **Firestore trigger** (`onDocumentUpdated`) on `users/{userId}/workoutLogs/{sessionId}`. It runs when a workout's `status` changes to `completed`.
    *   **Logic:** It calculates XP based on duration and volume, updates the user's total XP, checks for level-ups, and updates their workout streak. It also awards the "First Workout" achievement.
*   `checkProfileSetupCompletionAchievements`: A **Firestore trigger** (`onDocumentWritten`) on `users/{userId}`. When `profileSetupComplete` becomes `true`, it awards the "Early Bird" achievement.
*   `onCommentCreated` / `onCommentDeleted`: Firestore triggers that increment/decrement the `commentsCount` field on the parent `Post` document, ensuring data consistency without requiring a client-side transaction.
*   `onPostDeleted`: A crucial **Firestore cleanup trigger** (`onDocumentDeleted`). When a post is deleted, this function:
    1.  Deletes all sub-collection documents (all comments associated with the post).
    2.  Deletes the associated media file from Firebase Storage, preventing orphaned files.
*   `onRecordClaimPostCreated`: Sets the `recordVerificationDeadline` and initial `PENDING` status when a `recordClaim` post is created.
*   `onRecordClaimVoteCasted`: A trigger that awards a small amount of XP (`XP_FOR_VOTING`) to users for participating in the voting process. It uses a `votedAndRewardedUserIds` array on the post to prevent awarding XP multiple times for the same vote.
*   `processRecordClaimDeadlines`: A **scheduled function** (`onSchedule`) that runs periodically (e.g., every hour).
    *   **Logic:** It queries for all `recordClaim` posts whose deadline has passed. It tallies the `verify` and `dispute` votes. If the verification ratio is met, the post is marked as `VERIFIED`, and the author is awarded a significant amount of XP and the "Personal Record Set" achievement. Otherwise, it's marked `REJECTED` or `EXPIRED`.
*   `handleUserFollowListUpdate`: A **Firestore trigger** (`onDocumentWritten`) on the `users/{userId}` document. It detects changes in the `following` array.
    *   **Logic:** When a user A follows user B, this function automatically increments user B's `followersCount`. When A unfollows B, it decrements B's count. It also updates user A's `followingCount`. This server-side management is robust and prevents data desynchronization.

---

## 5. Core Domain & Data Models
The `lib/core/domain/entities/` directory defines the data structures of the app.

### 5.1. Entity Overview
*   **`UserProfile`:** The central model for a user's data.
*   **`UserRoutine` & `RoutineExercise`:** Defines a workout plan and its constituent exercises.
*   **`WorkoutSession`, `LoggedExercise`, `LoggedSet`:** Models for an actual, logged workout, capturing performance data.
*   **`Post`, `Comment`:** Models for the social feed.
*   **`Achievement`:** Defines the structure of an achievement, including its ID, name, description, and asset path.
*   **`AppNotification`:** Model for user notifications.
*   **`LeagueInfo`:** Defines the properties of a competitive league.

### 5.2. Key Entities Detailed
*   **`UserProfile.dart`:** Contains all user-specific data, from biometrics to gamification stats (`xp`, `level`, `currentStreak`) and social stats (`followersCount`, `following`, etc.).
*   **`Post.dart`:** A versatile entity that uses a `PostType` enum to differentiate between standard posts, routine shares, and record claims. It includes fields like `routineSnapshot` and `recordDetails` to store the relevant data for special post types.
*   **`Achievement.dart`:** Defines achievements with a static map `allAchievements`. This acts as a client-side source of truth for achievement details. The `emblemAssetPath` field directly links the achievement ID to its corresponding image asset, a pattern mirrored in the Firebase Function for sending notifications.

---

## 6. UI, Design & Localization

### 6.1. Theming & Styling
*   **File:** `lib/main.dart`
*   **Implementation:** A comprehensive `ThemeData` object is defined, establishing a consistent design system.
    *   **Colors:** A clear color scheme is defined around a primary orange (`#ED5D1A`).
    *   **Fonts:** The app uses two primary fonts: `Inter` for general UI and `IBMPlexMono` for stats and data-heavy displays, creating a modern, clean aesthetic.
    *   **Component Styling:** `elevatedButtonTheme`, `inputDecorationTheme`, `cardTheme`, etc., are all customized for a cohesive look and feel.

### 6.2. Custom Widgets & Animations
The project features several impressive custom widgets:
*   **`LavaLampBackground`:** Found on the `LoginPage`, this widget uses `AnimationController` and a custom painter to create a mesmerizing, slow-moving blob effect. It leverages `BackdropFilter` with a blur to achieve the "lava lamp" merging effect.
*   **`MuscleMapWidget`:** A technically impressive widget that dynamically colors an SVG based on data. It reads the raw SVG string, uses regular expressions to find specific muscle group IDs, and injects the appropriate `fill` color based on workout volume.
*   **`VolumeTrendChartWidget`:** A `CustomPaint` widget that draws a smooth, gradient-filled line chart to visualize workout volume trends.
*   **`AnimatedSpotlightBackground`:** Used on the `LeagueScreen`, this creates a dramatic, cinematic background with animated spotlights, enhancing the competitive feel.
*   **Lottie Animations:** The use of `trophy_animation.json` on the `WorkoutCompleteScreen` provides a high-quality, celebratory animation that would be difficult to achieve with standard Flutter animations.

### 6.3. Localization
*   **Setup:** The project is configured for internationalization using `flutter_localizations` and the `.arb` file format, as defined in `l10n.yaml`.
*   **Languages:** It currently supports English (`en`) and Ukrainian (`uk`).
*   **Implementation:** Localized strings are accessed via `AppLocalizations.of(context)!.someStringKey`. The generated `app_localizations.dart` file provides type-safe access to all strings. The `main.dart` file is configured with the necessary delegates and supported locales. There is a line `locale: const Locale('uk'),` which forces the Ukrainian locale for debugging purposes.

---

## 7. Project Setup & Configuration

*   **`pubspec.yaml`:** This is the project's manifest. It defines dependencies, assets (images, fonts, animations), and configuration for packages like `flutter_launcher_icons`.
*   **Firebase Integration:**
    *   **Flutter:** `firebase.json` and `lib/firebase_options.dart` (generated by FlutterFire CLI) configure the Flutter app to connect to the correct Firebase project for different platforms.
    *   **Android:** `android/app/google-services.json` contains the Android-specific Firebase configuration.
    *   **iOS:** The `ios/Runner.xcodeproj/project.pbxproj` and other config files handle the iOS integration.
*   **Gradle Configuration (`android/`):** The project uses the modern `build.gradle.kts` (Kotlin DSL) format. `settings.gradle.kts` applies the `google-services` plugin.

---

## 8. Potential Improvements & Next Steps

Based on the current code, here are some areas for future development:

1.  **Pagination:** While the `FollowListCubit` implements pagination for the followers list, other feeds like `ExploreFeed` and `UserPostsFeed` fetch a fixed limit. Implementing proper pagination (e.g., using `startAfterDocument`) would be crucial for performance as the user base grows.
2.  **Error Handling & UI:** While error states exist in Cubits, the UI could provide more user-friendly error messages and recovery options instead of just showing a raw error string.
3.  **Caching Strategy:** For data that doesn't change often (like predefined exercises or league info), implementing a caching layer (e.g., storing in a local database like Moor/Drift or simply in memory) could reduce Firestore reads and improve startup time after the initial fetch.
4.  **Complete "TODO"s:** There are implicit TODOs, such as implementing the video player for record claim proofs (`/* TODO: Launch URL */`).
5.  **Refactoring Repetitive UI:** Widgets for displaying stats or user info (like the avatar/name combination) could be extracted into more generic, reusable components to reduce code duplication across screens like `ProfileScreen` and `ViewUserProfileScreen`.
6.  **Real-time Updates on Likes/Comments:** The current implementation relies on re-fetching the entire post or list to see updated like/comment counts. For a more responsive experience, the `PostInteractionCubit` could listen to streams for these sub-collections or the parent `Post` document could be updated via Cloud Functions to reflect real-time counts.
7.  **Optimizing `didUpdateWidget`:** The `_initializeSetData` method in `CurrentSetDisplay` is called on every `didUpdateWidget`, which could be optimized by comparing the specific parts of the `currentSet` that changed, rather than re-initializing everything.