# **Muscle UP! - Full Project Documentation**

---

## 1. Project Overview

### 1.1. Purpose and Vision

**Muscle UP!** is a next-generation, gamified fitness application designed to motivate users through social interaction, progress tracking, and achievements. The project's core philosophy is to transform fitness from a solitary activity into an engaging, community-driven journey. The application's tagline, "New height, New companions," encapsulates this vision of personal growth alongside social connection.

### 1.2. Core Problems Solved

The project addresses several common challenges in the fitness app market:

*   **Lack of Motivation:** Traditional fitness trackers can be monotonous. Muscle UP! introduces gamification elements like XP (Experience Points), levels, streaks, and achievement badges to create a rewarding user experience.
*   **Isolation:** Fitness is often a solo endeavor. The app integrates a social feed, follower/following system, and community validation for personal records to foster a sense of community and friendly competition.
*   **Disorganization:** Users often struggle to structure their workouts. The app provides a system for creating, managing, and sharing workout routines.
*   **Progress Obscurity:** It can be hard to visualize long-term progress. The app includes a dedicated Progress screen with visual charts for workout volume, RPE (Rate of Perceived Exertion) trends, and strength gains over time.

### 1.3. Core Components

The application is built around a set of interconnected features, all powered by a Flutter frontend and a Firebase backend.

*   **Authentication & User Profile:** Secure user sign-up/sign-in via Email/Password and Google Sign-In. Each user has a detailed profile tracking everything from basic biometrics to fitness stats like XP, level, and workout streaks.
*   **Workout & Routine Management:** Users can create custom workout routines, schedule them for specific days of the week, and log their workout sessions in real-time.
*   **Gamification & Progress Tracking:** The app features a sophisticated XP and leveling system. Users earn XP for completing workouts and participating in community events. This progress is visualized through stats, charts, and a league system.
*   **Social Feed & Interaction:** A central "Explore" feed where users can create posts, share routines, and claim personal records. This includes a full suite of social features like likes, comments, and following other users.
*   **Record Claim & Verification System:** A unique feature where users can post a claim for a new personal record (e.g., a new max weight for an exercise). The community then votes to verify or dispute the claim, fostering engagement and a sense of shared accomplishment.
*   **Firebase Backend:** The entire application is serverless, relying on:
    *   **Firebase Authentication** for user management.
    *   **Cloud Firestore** as the primary NoSQL database for all user data, posts, routines, etc.
    *   **Firebase Storage** for hosting user-uploaded media like profile pictures and post images.
    *   **Cloud Functions for Firebase** for running backend logic, such as calculating XP, updating user stats, and managing notifications.
*   **Internationalization (i18n):** The app is built with localization in mind, supporting English and Ukrainian out-of-the-box, with a clear structure to add more languages.

---

## 2. File and Folder Structure

The project follows a well-organized, feature-first structure within the `lib` directory, complemented by standard Flutter, Android, iOS, and Firebase Functions directories.

### 2.1. Root Directory

```
muscle_up_android/
├── .firebaserc
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── create_snapshot.py
├── devtools_options.yaml
├── firebase.json
├── l10n.yaml
├── pubspec.yaml
├── android/
├── assets/
├── functions/
├── ios/
├── lib/
└── web/
```

| File / Folder                    | Description                                                                                                                                                                                                                          |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **`.firebaserc`**                | Firebase CLI configuration file. It links the local project directory to a specific Firebase project (`muscle-up-8c275`). This is used for deploying functions and other Firebase resources.                                       |
| **`.flutter-plugins-dependencies`** | A generated file that tracks the exact versions of native plugin dependencies. It's managed by the Flutter tool and should not be manually edited.                                                                                 |
| **`.gitignore`**                 | Specifies intentionally untracked files to be ignored by Git. This includes build artifacts, logs, IDE-specific files, and sensitive information like API keys.                                                                      |
| **`.metadata`**                  | A file managed by the Flutter tool to track project properties, such as the Flutter version (revision and channel) the project was created with. It's used for migration and tool assessment.                                       |
| **`analysis_options.yaml`**      | Configures the Dart analyzer and linter. In this project, it includes the standard `flutter_lints` package, enforcing a consistent and high-quality coding style.                                                                   |
| **`create_snapshot.py`**         | A custom Python script used to generate the project snapshot provided for this documentation. It is a tooling file, not part of the application itself.                                                                               |
| **`devtools_options.yaml`**      | A configuration file for Dart & Flutter DevTools, allowing for customization and extension management. Currently, it is empty.                                                                                                         |
| **`firebase.json`**              | Core Firebase configuration for the project. It defines how the Firebase CLI interacts with the Flutter app, specifying project IDs, app IDs, and output paths for configuration files like `google-services.json` and `firebase_options.dart`. It also configures the Firebase Functions deployment. |
| **`l10n.yaml`**                  | Configuration file for Flutter's internationalization (i10n) tool. It specifies the location of ARB (Application Resource Bundle) files and the output Dart file (`app_localizations.dart`).                                         |
| **`pubspec.yaml`**               | The heart of a Flutter project's metadata. It defines the project name, description, version, and, most importantly, its dependencies (`dependencies` and `dev_dependencies`). It also configures assets, fonts, and build runners like `flutter_launcher_icons` and `flutter_native_splash`. |
| **`android/`**                   | Contains the Android-specific part of the Flutter project. Includes Gradle build scripts, `AndroidManifest.xml`, and native code.                                                                                                     |
| **`assets/`**                    | Stores static assets used by the application, such as images, fonts, and Lottie animations.                                                                                                                                          |
| **`functions/`**                 | A self-contained Node.js project for Firebase Cloud Functions. Contains the TypeScript source code (`src/`), configuration files (`tsconfig.json`, `.eslintrc.js`), and dependency management (`package.json`).                           |
| **`ios/`**                       | Contains the iOS-specific part of the Flutter project. Includes the Xcode project (`Runner.xcodeproj`), `Info.plist`, and native code.                                                                                              |
| **`lib/`**                       | The main directory containing all the Dart code for the Flutter application. Its internal structure is described below.                                                                                                                |
| **`web/`**                       | Contains files for building the web version of the application, including `index.html` and `manifest.json`.                                                                                                                          |

### 2.2. `lib/` Directory Structure

The `lib` directory is organized by feature, following principles of Clean Architecture to separate concerns.

```
lib/
├── auth_gate.dart
├── firebase_options.dart
├── home_page.dart
├── login_page.dart
├── main.dart
├── core/
│   ├── domain/
│   │   ├── entities/
│   │   └── repositories/
│   ├── presentation/
│   │   └── cubit/
│   └── services/
├── features/
│   ├── dashboard/
│   ├── exercise_explorer/
│   ├── leagues/
│   ├── notifications/
│   ├── profile/
│   ├── profile_setup/
│   ├── progress/
│   ├── routines/
│   ├── social/
│   └── workout_tracking/
├── l10n/
│   ├── app_en.arb
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   ├── app_localizations_uk.dart
│   └── app_uk.arb
└── widgets/
```

| File / Folder                         | Description                                                                                                                                                                                          |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`auth_gate.dart`**                  | A critical widget that acts as a gatekeeper. It listens to Firebase Auth state changes and directs the user to either the `LoginPage` or the main app (`HomePage`/`ProfileSetupScreen`) accordingly. |
| **`firebase_options.dart`**           | A generated file containing Firebase project configurations for different platforms (Android, iOS, web), enabling the app to connect to the correct Firebase project.                                 |
| **`home_page.dart`**                  | The main screen after a user logs in and completes profile setup. It contains the bottom navigation bar and acts as a host for the primary feature screens.                                           |
| **`login_page.dart`**                 | The UI for user sign-in and sign-up, including email/password and Google Sign-In options.                                                                                                              |
| **`main.dart`**                       | The entry point of the Flutter application. It initializes Firebase, sets up localization, provides dependencies via `MultiRepositoryProvider`, and runs the `MainApp` widget.                           |
| **`core/`**                           | Contains code shared across multiple features.                                                                                                                                                       |
| `core/domain/entities/`               | Defines the core business objects (data models) of the app, such as `UserProfile`, `Post`, `UserRoutine`. These are plain Dart objects, independent of any framework or data source.                    |
| `core/domain/repositories/`           | Defines the abstract contracts (interfaces) for data repositories. This decouples the application's business logic from the specific data sources (e.g., Firestore).                                     |
| `core/presentation/cubit/`            | Contains shared Cubits, such as `LocaleCubit` for managing app-wide language changes.                                                                                                                  |
| `core/services/`                      | Contains utility services, such as `ImagePickerService` for handling image selection and cropping.                                                                                                     |
| **`features/`**                       | The main application code, organized by feature. Each sub-folder represents a distinct feature of the app.                                                                                             |
| `features/*/data/repositories/`       | Contains concrete implementations of the repository interfaces defined in `core/domain/repositories`. This is where the interaction with Firebase (Firestore) happens.                                  |
| `features/*/presentation/cubit/`      | Contains the BLoC/Cubit classes responsible for managing the state of a specific feature.                                                                                                            |
| `features/*/presentation/screens/`    | Contains the main UI screen widgets for a feature.                                                                                                                                                   |
| `features/*/presentation/widgets/`    | Contains smaller, reusable UI components specific to a feature.                                                                                                                                      |
| **`l10n/`**                           | Contains all files related to localization (internationalization).                                                                                                                                   |
| `l10n/app_*.arb`                      | Application Resource Bundle files. These are JSON-like files that store key-value pairs of translation strings for each supported language (`en` for English, `uk` for Ukrainian).                    |
| `l10n/app_localizations*.dart`        | Dart files auto-generated by the Flutter i10n tool from the `.arb` files. They provide a type-safe way to access localized strings in the app.                                                          |
| **`widgets/`**                        | A directory for UI widgets that are generic enough to be shared across the entire application, such as `FullScreenImageViewer` and `LavaLampBackground`.                                               |

---

## 3. Database Schema (Cloud Firestore)

The project uses **Cloud Firestore**, a flexible, scalable NoSQL document database from Firebase. The schema is document-oriented and designed around the application's features.

### 3.1. Top-Level Collections

| Collection Name   | Description                                                                                                                                                                    |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **`users`**       | Stores the profile information for every registered user. The document ID is the user's Firebase Auth UID.                                                                       |
| **`userRoutines`** | Stores all workout routines created by users. Each document represents a single routine.                                                                                         |
| **`posts`**       | Stores all social posts created by users, including standard posts, routine shares, and record claims.                                                                           |
| **`leagues`**     | (Inferred) Stores the definitions for different user leagues based on level/XP.                                                                                                    |
| **`predefinedExercises`** | (Inferred) A library of all available exercises with details like muscle groups, descriptions, etc.                                                                         |

### 3.2. Collection Schemas

#### 3.2.1. `users` Collection

*   **Document ID:** User's Firebase Auth UID.
*   **Description:** Holds all public and private information related to a user's profile and progress.

| Field                                   | Data Type      | Constraints      | Description                                                                                                                            |
| --------------------------------------- | -------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `uid`                                   | String         | Required         | The user's unique identifier, matching the Auth UID.                                                                                   |
| `email`                                 | String         | Nullable         | The user's email address.                                                                                                              |
| `username`                              | String         | Nullable, Unique | The user's public, unique username.                                                                                                    |
| `displayName`                           | String         | Nullable         | The user's public display name (can be non-unique).                                                                                    |
| `profilePictureUrl`                     | String         | Nullable         | URL to the user's avatar image, hosted on Firebase Storage.                                                                            |
| `gender`                                | String         | Nullable         | User's self-identified gender (e.g., 'male', 'female').                                                                                |
| `dateOfBirth`                           | Timestamp      | Nullable         | User's date of birth.                                                                                                                  |
| `heightCm`                              | Number         | Nullable         | User's height in centimeters.                                                                                                          |
| `weightKg`                              | Number         | Nullable         | User's weight in kilograms.                                                                                                            |
| `fitnessGoal`                           | String         | Nullable         | User's primary fitness goal (e.g., 'gain_muscle').                                                                                     |
| `activityLevel`                         | String         | Nullable         | User's self-reported activity level (e.g., 'sedentary').                                                                               |
| `xp`                                    | Number         | Required         | Total experience points earned by the user. **Indexed for leaderboards.**                                                               |
| `level`                                 | Number         | Required         | The user's current level, calculated from XP. **Indexed for leagues.**                                                                  |
| `currentStreak`                         | Number         | Required         | The user's current workout streak.                                                                                                     |
| `longestStreak`                         | Number         | Required         | The user's longest-ever workout streak.                                                                                                |
| `lastWorkoutTimestamp`                  | Timestamp      | Nullable         | The timestamp of the user's last completed workout.                                                                                    |
| `lastScheduledWorkoutCompletionTimestamp` | Timestamp      | Nullable         | The timestamp of the last *scheduled* workout completion, used for streak calculation.                                                 |
| `lastScheduledWorkoutDayKey`            | String         | Nullable         | The day key (e.g., 'MON') of the last scheduled workout completion.                                                                      |
| `followersCount`                        | Number         | Required         | A denormalized count of the user's followers. Managed by Cloud Functions.                                                              |
| `followingCount`                        | Number         | Required         | A denormalized count of how many users this user is following. Managed by Cloud Functions.                                             |
| `achievedRewardIds`                     | Array\<String> | Required         | An array of `AchievementId` strings for all unlocked achievements.                                                                     |
| `following`                             | Array\<String> | Required         | An array of UIDs of users that this user is following. **Indexed for querying followers.**                                             |
| `profileSetupComplete`                  | Boolean        | Required         | A flag indicating if the user has completed the initial profile setup. **Indexed for filtering.**                                       |
| `createdAt`                             | Timestamp      | Required         | Server-side timestamp of when the user profile document was created.                                                                   |
| `updatedAt`                             | Timestamp      | Required         | Server-side timestamp of the last time the document was modified.                                                                      |

*   **Subcollections:**
    *   **`workoutLogs`**: Stores a history of all workout sessions for the user. (Schema below)
    *   **`notifications`**: Stores all notifications for the user. (Schema below)

#### 3.2.2. `posts` Collection

*   **Document ID:** Auto-generated by Firestore.
*   **Description:** A single social feed post.

| Field                        | Data Type           | Description                                                                                                                                                                                                             |
| ---------------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`                         | String              | The document's own ID. Stored for convenience in the data model.                                                                                                                                                          |
| `userId`                     | String              | The UID of the user who created the post. **Indexed for querying user-specific posts.**                                                                                                                                   |
| `authorUsername`             | String              | A snapshot of the author's username at the time of posting.                                                                                                                                                               |
| `authorProfilePicUrl`        | String (Nullable)   | A snapshot of the author's profile picture URL at the time of posting.                                                                                                                                                    |
| `timestamp`                  | Timestamp           | The server-side timestamp of when the post was created. **Indexed for sorting the feed.**                                                                                                                                 |
| `updatedAt`                  | Timestamp           | The server-side timestamp of when the post was last modified.                                                                                                                                                             |
| `type`                       | String              | The type of post: `standard`, `routineShare`, or `recordClaim`. **Indexed for filtering.**                                                                                                                                |
| `textContent`                | String              | The main text content of the post.                                                                                                                                                                                      |
| `mediaUrl`                   | String (Nullable)   | URL to an image or video associated with the post, hosted on Firebase Storage.                                                                                                                                            |
| `likedBy`                    | Array\<String>      | An array of UIDs of users who have liked the post.                                                                                                                                                                      |
| `commentsCount`              | Number              | A denormalized count of comments. Managed by Cloud Functions.                                                                                                                                                           |
| `isCommentsEnabled`          | Boolean             | A flag to enable or disable comments on the post.                                                                                                                                                                       |
| `relatedRoutineId`           | String (Nullable)   | If `type` is `routineShare`, this is the ID of the `UserRoutine` document.                                                                                                                                                |
| `routineSnapshot`            | Map                 | If `type` is `routineShare`, this is a complete snapshot of the routine data at the time of sharing.                                                                                                                      |
| `recordDetails`              | Map                 | If `type` is `recordClaim`, this contains the details of the record (exercise ID, name, weight, reps, video URL).                                                                                                         |
| `recordVerificationStatus`   | String (Nullable)   | The status of a record claim: `pending`, `verified`, `rejected`, `expired`. **Indexed for the scheduled function.**                                                                                                     |
| `recordVerificationDeadline` | Timestamp (Nullable)| The deadline for voting on a record claim. **Indexed for the scheduled function.**                                                                                                                                        |
| `isRecordVerified`           | Boolean (Nullable)  | A final boolean flag indicating if the record was successfully verified.                                                                                                                                                |
| `verificationVotes`          | Map                 | A map where keys are voter UIDs and values are their votes (`verify` or `dispute`).                                                                                                                                     |
| `votedAndRewardedUserIds`    | Array\<String>      | An array of UIDs of users who have already received XP for voting on this claim, to prevent duplicate rewards.                                                                                                            |

*   **Subcollections:**
    *   **`comments`**: Stores all comments for a specific post. (Schema below)

#### 3.2.3. `posts/{postId}/comments` Subcollection

*   **Document ID:** Auto-generated by Firestore.
*   **Description:** A single comment on a post.

| Field                 | Data Type         | Description                                                          |
| --------------------- | ----------------- | -------------------------------------------------------------------- |
| `id`                  | String            | The document's own ID.                                               |
| `postId`              | String            | The ID of the parent post.                                           |
| `userId`              | String            | The UID of the user who wrote the comment.                           |
| `authorUsername`      | String            | A snapshot of the author's username at the time of commenting.       |
| `authorProfilePicUrl` | String (Nullable) | A snapshot of the author's profile picture URL at the time of commenting. |
| `text`                | String            | The content of the comment.                                          |
| `timestamp`           | Timestamp         | The server-side timestamp of when the comment was created. **Indexed for sorting.** |

#### 3.2.4. Other Collections (Inferred/Standard)

*   **`userRoutines`**: Schema matches the `UserRoutine` entity. `userId` is indexed.
*   **`users/{userId}/workoutLogs`**: Schema matches the `WorkoutSession` entity. `status` and `startedAt` are indexed for querying.
*   **`users/{userId}/notifications`**: Schema matches the `AppNotification` entity. `isRead` and `timestamp` are indexed.

---

## 4. Cloud Functions / Serverless Functions

The backend logic is handled by Cloud Functions for Firebase, written in TypeScript. These functions are event-driven, responding to changes in the database or authentication events.

**Location:** `functions/src/index.ts`

| Function Name                          | Trigger                                                  | Description & Logic                                                                                                                                                                                                                                                                                           |
| -------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `createUserProfile`                    | `auth.user().onCreate()`                                 | **Triggered:** When a new user signs up. **Logic:** Creates a new document in the `users` collection with the user's UID. It pre-populates the document with default values (XP=0, level=1, etc.) and any available info from the auth provider (email, photoURL). This ensures a user profile exists immediately upon sign-up. |
| `calculateAndAwardXpAndStreak`         | `firestore.onDocumentUpdated("users/{...}/workoutLogs/{...}")` | **Triggered:** When a `workoutLogs` document is updated. **Logic:** Checks if the `status` field changed to "completed". If so, it calculates XP based on volume and duration, updates the user's streak, determines if a level-up occurred, and grants the "First Workout" achievement. It wraps these operations in a Firestore transaction for atomicity. |
| `checkProfileSetupCompletionAchievements` | `firestore.onDocumentWritten("users/{...}")`           | **Triggered:** When a `users` document is created or updated. **Logic:** Checks if the `profileSetupComplete` flag changed from `false` to `true`. If so, it awards the "Early Bird" achievement and sends a corresponding notification. |
| `onCommentCreated`                     | `firestore.onDocumentCreated("posts/{...}/comments/{...}")` | **Triggered:** When a new comment is added to a post. **Logic:** Atomically increments the `commentsCount` field on the parent post document. This is a denormalization pattern for efficient comment count display. |
| `onCommentDeleted`                     | `firestore.onDocumentDeleted("posts/{...}/comments/{...}")` | **Triggered:** When a comment is deleted. **Logic:** Atomically decrements the `commentsCount` field on the parent post document. |
| `onPostDeleted`                        | `firestore.onDocumentDeleted("posts/{...}")`            | **Triggered:** When a post document is deleted. **Logic:** A cleanup function that deletes all sub-collection documents (comments) and associated media from Firebase Storage to prevent orphaned data. |
| `onRecordClaimPostCreated`             | `firestore.onDocumentCreated("posts/{...}")`             | **Triggered:** When a new post is created. **Logic:** Checks if the post `type` is `recordClaim`. If so, it sets the `recordVerificationDeadline` (24 hours in the future) and initializes the `recordVerificationStatus` to `pending`. |
| `onRecordClaimVoteCasted`              | `firestore.onDocumentUpdated("posts/{...}")`             | **Triggered:** When a post is updated (specifically, when votes are cast). **Logic:** Detects when a new vote is added to the `verificationVotes` map. It awards the voter a small amount of XP (`XP_FOR_VOTING`) and adds their UID to the `votedAndRewardedUserIds` array to prevent duplicate rewards. |
| `processRecordClaimDeadlines`          | `scheduler.onSchedule("every 1 hours")`                  | **Triggered:** Every hour by a scheduler. **Logic:** Queries for all `recordClaim` posts where the `recordVerificationStatus` is `pending` and the `recordVerificationDeadline` is in the past. For each found post, it tallies the votes, determines if the claim is `verified` or `rejected`, updates the post's status, and sends notifications to the author. If verified, it also awards a large XP bonus and the "Personal Record" achievement. |
| `handleUserFollowListUpdate`           | `firestore.onDocumentWritten("users/{...}")`             | **Triggered:** When a user's `following` array is modified. **Logic:** Detects when a user follows or unfollows another. It updates the `followersCount` and `followingCount` on the respective user documents and sends a `newFollower` notification to the user who was followed. |

---

## 5. All Functions, Classes, and Methods

This section provides a detailed breakdown of the Dart code in the `lib` directory.

### 5.1. Root `lib` Files

#### `main.dart`

*   **`main()` function:**
    *   **Purpose:** The main entry point of the application.
    *   **Logic:**
        1.  Ensures Flutter bindings are initialized with `WidgetsFlutterBinding.ensureInitialized()`.
        2.  Initializes the Firebase App using `Firebase.initializeApp()`.
        3.  Loads the user's saved language preference from `SharedPreferences`.
        4.  Sets an `initialLocale` (defaults to 'en' if none is saved).
        5.  Runs the `MainApp` widget.
*   **`MainApp` class:**
    *   **Purpose:** The root widget of the application.
    *   **Logic:**
        1.  Wraps the entire application in a `MultiRepositoryProvider` to make all repository implementations (`UserProfileRepositoryImpl`, `PostRepositoryImpl`, etc.) available to the widget tree. This is a key part of the dependency injection setup.
        2.  Wraps the app in a `BlocProvider<LocaleCubit>` to manage the application's language.
        3.  Uses a `BlocBuilder<LocaleCubit, Locale>` to rebuild the `MaterialApp` whenever the locale changes, ensuring the entire UI updates to the new language.
        4.  Defines the `MaterialApp`, setting up:
            *   Localization delegates (`AppLocalizations.delegate`, etc.).
            *   Supported locales (`AppLocalizations.supportedLocales`).
            *   The current `locale` from the `LocaleCubit`.
            *   A comprehensive `ThemeData` object defining the app's visual style (colors, fonts, button styles, etc.).
            *   Sets `home` to `AuthGate`, which handles the initial routing based on authentication state.

#### `auth_gate.dart`

*   **`AuthGate` class:**
    *   **Purpose:** Determines the user's initial screen based on their Firebase authentication state.
    *   **Logic:**
        1.  Uses a `StreamBuilder` to listen to `FirebaseAuth.instance.authStateChanges()`.
        2.  If the connection is waiting, it shows a `CircularProgressIndicator`.
        3.  If `authSnapshot.hasData` is true (user is logged in), it defers to `_ProfileCheckGate` to check the user's profile status.
        4.  If `authSnapshot.hasData` is false (user is logged out), it navigates to `LoginPage`.
*   **`_ProfileCheckGate` class:**
    *   **Purpose:** A secondary gate that checks if a logged-in user has completed their profile setup.
    *   **Logic:**
        1.  Receives the `userId` from `AuthGate`.
        2.  Uses a `StreamBuilder` to listen to the specific user's profile document stream from `userProfileRepository.getUserProfileStream(userId)`.
        3.  **Error Handling:** If the stream has an error, it navigates back to the `LoginPage`.
        4.  **Loading/Syncing State:** If the stream is waiting or the `userProfile` is `null` (which can happen for a brief moment after account creation while the Cloud Function creates the document), it shows a `CircularProgressIndicator` with a "Finalizing account setup..." message.
        5.  **Routing Logic:**
            *   If `userProfile.profileSetupComplete` is `true`, it navigates to `HomePage`.
            *   If `userProfile.profileSetupComplete` is `false`, it navigates to `ProfileSetupScreen`.

#### `login_page.dart`

*   **`LoginPage` class:**
    *   **Purpose:** Provides the UI and logic for user authentication.
    *   **State (`_LoginPageState`):** Manages form controllers (`_emailController`, `_passwordController`), loading state (`_isLoading`), form mode (`_isLogin`), and error messages (`_errorMessage`).
    *   **Widgets:**
        *   `_buildLanguageSelector()`: A `DropdownButton` to allow the user to switch the app's language via the `LocaleCubit`.
        *   The main `build` method uses a `Stack` with a `LavaLampBackground` for visual appeal.
        *   A `Form` widget with a `GlobalKey` (`_formKey`) is used for input validation.
        *   `TextFormField`s are used for email and password input with appropriate validators.
        *   Conditional UI logic shows either "Sign In" or "Sign Up" elements based on the `_isLogin` boolean.
    *   **Methods:**
        *   `_submitForm()`: Handles email/password authentication. Validates the form, sets `_isLoading` to true, and calls either `signInWithEmailAndPassword` or `createUserWithEmailAndPassword`. Catches `FirebaseAuthException` to display user-friendly error messages based on the error code (e.g., `invalid-credential`).
        *   `_signInWithGoogle()`: Handles the Google Sign-In flow. It uses the `google_sign_in` package to get a `GoogleSignInAccount`, then obtains an `AuthCredential` from it, and finally signs into Firebase using `signInWithCredential`.
        *   `dispose()`: Cleans up the `TextEditingController`s.

#### `home_page.dart`

*   **`HomePage` class:**
    *   **Purpose:** Acts as the main container for the app's primary screens after login.
    *   **Logic:** Wraps the content in a `BlocProvider<NotificationsCubit>` to make notification state available to all child screens.
*   **`_HomePageContentState` class:**
    *   **State:**
        *   `_selectedIndex`: An integer that controls which screen is displayed. `-1` is a special value used to represent the main `DashboardScreen`. `0-3` correspond to the bottom navigation bar items.
        *   `_bottomNavScreens`: A static list of the widgets for the bottom navigation bar (`UserRoutinesScreen`, `ExploreScreen`, etc.).
    *   **Methods:**
        *   `_onItemTapped(index)`: Updates `_selectedIndex` when a bottom navigation bar item is tapped.
        *   `_navigateToDashboard()`: Sets `_selectedIndex` to `-1` to show the dashboard.
        *   `_handleFabPress()`: Logic for the central "START WORKOUT" Floating Action Button. It checks for an active workout session. If one exists, it navigates to `ActiveWorkoutScreen`. If not, it checks if the user has any routines. If they do, it switches to the "Routines" tab. If not, it navigates to `CreateEditRoutineScreen`.
    *   **`build()` Method:**
        *   Conditionally renders the `body` based on `_selectedIndex`. If `-1`, it shows `DashboardScreen`. Otherwise, it shows the screen from the `_bottomNavScreens` list.
        *   The `AppBar` title is also dynamic, showing "MuscleUP" on the dashboard and "MuscleUP | [ScreenName]" on other screens.
        *   The `FloatingActionButton` is only shown when on the dashboard (`_selectedIndex == -1`).
        *   A standard `BottomNavigationBar` is configured to control navigation between the main feature areas.
---
### 5.2. `core/`

This directory contains the foundational code that is shared across multiple features, adhering to the principles of Clean Architecture.

#### `core/domain/entities/`

This folder contains the Plain Old Dart Objects (PODOs) that represent the core data structures of the application. They are framework-agnostic and use `equatable` for value-based comparison, simplifying testing and state management.

| Entity Class                 | Description                                                                                                                                                                                                                                                            |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `achievement.dart`           | Defines the `AchievementId` enum and the `Achievement` class, which holds an achievement's ID, emblem path, and display logic. It includes methods for getting localized names and descriptions from ARB files.                                                            |
| `app_notification.dart`      | Defines the `NotificationType` enum and the `AppNotification` class. This entity represents a single notification, handling both raw text and localized content via `titleLocKey`, `messageLocKey`, and `messageLocArgs`.                                                   |
| `comment.dart`               | Represents a single comment on a post, containing the comment text, author details (ID, username, profile picture), and a timestamp.                                                                                                                                   |
| `league_info.dart`           | Represents a single competitive league, including its name, level/XP requirements, and visual gradient colors for UI representation.                                                                                                                                   |
| `logged_exercise.dart`       | Represents a single exercise within a logged workout session. It contains a list of `LoggedSet`s and a snapshot of the exercise name at the time of logging to prevent issues if the original exercise name in the library changes.                                       |
| `logged_set.dart`            | Represents a single set within a logged exercise, tracking weight, reps, and completion status. It includes a `volume` getter for easy calculation.                                                                                                                      |
| `post.dart`                  | A complex entity representing a social post. It includes enums for `PostType` and `RecordVerificationStatus` and holds all data related to a post, including text content, media URLs, likes, comments, and specific data for routine shares or record claims.           |
| `predefined_exercise.dart`   | Represents a single exercise from the main library. Critically, it uses `Map<String, String>` and `Map<String, List<String>>` for fields like `name` and `primaryMuscleGroup` to support localization. It includes helper methods like `getLocalizedName(context)` to retrieve the correct string based on the current app locale. |
| `routine.dart`               | Defines two classes: `RoutineExercise`, representing an exercise within a routine template, and `UserRoutine`, representing the full routine created by a user, including its schedule and list of exercises.                                                            |
| `user_profile.dart`          | The central data model for a user. It contains all personal information, fitness stats (XP, level, streak), social counts, and a list of followed user IDs (`following`).                                                                                                  |
| `vote_type.dart`             | Defines the `VoteType` enum (`verify`, `dispute`) used in the record claim system and includes helper functions for converting between the enum and its string representation for Firestore.                                                                           |
| `workout_session.dart`       | Defines the `WorkoutStatus` enum and the `WorkoutSession` class, which represents a single workout from start to finish. It contains a list of `LoggedExercise`s and metadata like start/end times and total volume.                                                     |

#### `core/domain/repositories/`

This folder defines the abstract classes (interfaces) for data repositories. This is a crucial part of the architecture, as it decouples the application's business logic (in Cubits) from the data layer's concrete implementation (Firestore).

| Repository Interface                  | Description                                                                                                                                                                                                                |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `league_repository.dart`              | Defines methods for fetching league information (`getAllLeagues`) and the leaderboard for a specific league (`getLeaderboardForLeague`).                                                                                     |
| `notification_repository.dart`        | Defines the contract for all notification-related data operations, such as streaming notifications for a user, getting the unread count, and marking notifications as read or deleting them.                                 |
| `post_repository.dart`                | Defines the complete API for interacting with posts, including creating, updating, deleting, liking, commenting, and voting on posts.                                                                                         |
| `predefined_exercise_repository.dart` | Defines the contract for fetching the list of all available exercises from the exercise library.                                                                                                                             |
| `routine_repository.dart`             | Defines methods for CRUD (Create, Read, Update, Delete) operations on user workout routines and a method for copying a shared routine.                                                                                      |
| `user_profile_repository.dart`        | Defines the contract for interacting with user profiles, including fetching, updating, and streaming profile data, as well as handling follow/unfollow logic and retrieving follower/following lists.                      |
| `workout_log_repository.dart`         | Defines the contract for managing workout sessions. This includes starting, updating, completing, and canceling sessions, as well as fetching a user's workout history and their currently active session.                     |

#### `core/presentation/cubit/`

*   **`locale_cubit.dart`**:
    *   **Purpose:** Manages the application's current `Locale` for internationalization.
    *   **State:** The state is simply the `Locale` object itself.
    *   **Methods:**
        *   `setLocale(Locale newLocale)`: This method is called when the user selects a new language. It saves the new language code to `SharedPreferences` for persistence across app restarts and then `emits` the new `Locale` to trigger a UI rebuild via the `BlocBuilder` in `main.dart`.

#### `core/services/`

*   **`image_picker_service.dart`**:
    *   **Purpose:** Encapsulates the logic for picking and cropping images, abstracting the `image_picker` and `image_cropper` packages.
    *   **Methods:**
        *   `pickAndCropImage(...)`: A versatile method that takes an `ImageSource` (gallery or camera). It first picks an image, then uses `image_cropper` to present a cropping UI. It includes pre-configured `AndroidUiSettings` and `IOSUiSettings` for a consistent, branded experience. Returns a `File` object of the cropped image or `null` if the process is canceled.
        *   `pickImageFromGallery()` & `pickImageFromCamera()`: Convenience methods that call `pickAndCropImage` with a fixed source but without the cropping step, intended for use cases like attaching a full image to a post.

---
### 5.3. `features/`

This directory is the core of the application, with each sub-folder representing a distinct user-facing feature.

#### `features/dashboard/`

*   **Purpose:** Manages the main dashboard screen, which serves as the user's landing page. It displays key stats, upcoming workouts, and recent notifications.
*   **`presentation/cubit/dashboard_stats_cubit.dart`**:
    *   **Purpose:** Fetches and calculates aggregate statistics for the dashboard widgets.
    *   **Logic:**
        1.  `fetchAllDashboardStats()`: Fetches the last 7 workout logs to calculate the volume trend. It also fetches all of the user's routines and their recent workout history to calculate the "adherence" percentage (how many scheduled workouts were actually completed).
        2.  `_calculateAdherence(...)`: A private helper that iterates through the last 7 days, counts how many workouts were scheduled based on the user's routines, and compares that to how many were actually completed on those days.
*   **`presentation/cubit/upcoming_schedule_cubit.dart`**:
    *   **Purpose:** Fetches the user's routines and calculates the workout schedule for the next 7 days.
    *   **Logic:**
        1.  `fetchUpcomingSchedule()`: Retrieves all user routines. It then iterates from today for the next 7 days, checking which routines are scheduled for each day key ('MON', 'TUE', etc.) and builds a `Map<DateTime, List<String>>` representing the schedule.
*   **`presentation/screens/dashboard_screen.dart`**:
    *   **Purpose:** The main UI for the dashboard.
    *   **Logic:**
        *   Uses a `MultiBlocProvider` to create instances of `DashboardStatsCubit` and `UpcomingScheduleCubit`.
        *   Uses a `BlocBuilder<UserProfileCubit, ...>` to display personalized information like the user's name, weight, and streak.
        *   Contains a `RefreshIndicator` to allow the user to pull-to-refresh all dashboard data.
        *   Delegates the display of complex data to specialized widgets: `VolumeTrendChartWidget` and `UpcomingScheduleWidget`.
        *   Includes a section for the latest notifications, driven by the `NotificationsCubit`.
*   **`presentation/widgets/`**:
    *   **`upcoming_schedule_widget.dart`**: A widget that listens to the `UpcomingScheduleCubit` and displays the 7-day schedule in a horizontal `ListView`. It uses `DateFormat` to correctly format dates and day names according to the current app locale.
    *   **`volume_trend_chart_widget.dart`**: A sophisticated widget that uses a `CustomPainter` (`_VolumeChartPainter`) to draw a sparkline chart of the user's recent workout volumes. It dynamically changes the gradient color of the chart based on whether the trend is positive, negative, or neutral.

#### `features/exercise_explorer/`

*   **Purpose:** Provides a library of predefined exercises for users to browse or select from when building routines.
*   **`data/repositories/predefined_exercise_repository_impl.dart`**:
    *   **Purpose:** Implements the `PredefinedExerciseRepository` interface.
    *   **Logic:**
        *   `getAllExercises()`: Queries the `predefinedExercises` collection in Firestore, orders them by name, and maps the documents to `PredefinedExercise` objects.
*   **`presentation/cubit/exercise_explorer_cubit.dart`**:
    *   **Purpose:** Manages the state for the exercise explorer screen.
    *   **Logic:**
        *   `fetchExercises()`: Calls the repository to get all exercises and emits a `ExerciseExplorerLoaded` state with the list or an `ExerciseExplorerError` state on failure.
*   **`presentation/screens/exercise_explorer_screen.dart`**:
    *   **Purpose:** The main UI for browsing exercises.
    *   **Logic:**
        *   Accepts a boolean `isSelectionMode`. If `true`, the screen is used to pick an exercise and return it via `Navigator.pop(context, exercise)`. If `false`, it's a simple browser.
        *   Uses a `BlocBuilder` to display a loading indicator, an error message, or a `ListView` of `ExerciseListItem` widgets.
*   **`presentation/widgets/exercise_list_item.dart`**:
    *   **Purpose:** A single list item representing one exercise.
    *   **Logic:** Displays the localized exercise name, primary muscle group, and secondary muscle groups. The `onTap` behavior changes based on `isSelectionMode`.

#### `features/leagues/`

*   **Purpose:** Manages the UI and logic for displaying competitive leagues and their leaderboards.
*   **`presentation/cubit/league_cubit.dart`**:
    *   **Purpose:** Manages the state for a single league's leaderboard.
    *   **Logic:**
        *   Receives an `initialLeague` in its constructor.
        *   `fetchLeaderboard()`: Calls the `leagueRepository` to get the list of top users for the `currentLeague` and emits the result.
*   **`presentation/screens/league_screen.dart`**:
    *   **Purpose:** Displays the details of a single league and its leaderboard.
    *   **Logic:**
        *   Uses a `Stack` with a custom `AnimatedSpotlightBackground` for a dramatic visual effect.
        *   Displays the league title using `LeagueTitleWidget`.
        *   Uses a `BlocBuilder<LeagueCubit, ...>` to display the leaderboard in a `ListView`, using `LeaderboardListItemWidget` for each user.
*   **`presentation/widgets/`**:
    *   **`animated_spotlight_background.dart`**: A purely decorative widget that uses `AnimationController` and a `CustomPainter` to render moving, gradient spotlights, creating a "stage" effect.
    *   **`leaderboard_list_item_widget.dart`**: Renders a single row in the leaderboard. It displays the user's rank (with special medal icons for top 3), avatar, name, XP, and level. It highlights the currently authenticated user in the list.

#### `features/notifications/`

*   **Purpose:** This feature is responsible for managing and displaying all user-facing notifications, such as new followers, achievement unlocks, and system messages.
*   **`data/repositories/notification_repository_impl.dart`**:
    *   **Class:** `NotificationRepositoryImpl`
    *   **Implements:** `NotificationRepository`
    *   **Purpose:** The concrete implementation of the notification repository, handling all interactions with the Firestore database for notification-related data.
    *   **Dependencies:** `cloud_firestore`, `firebase_auth`.
    *   **Methods:**
        *   `_userNotificationsCollection(String userId)`: A private helper method that returns a `CollectionReference` to the `notifications` subcollection for a given user (`users/{userId}/notifications`). This avoids code duplication.
        *   `getUserNotificationsStream(String userId)`:
            *   **Purpose:** To provide a real-time stream of a user's notifications.
            *   **Logic:** It sets up a Firestore snapshot listener on the user's notification subcollection, ordering the results by `timestamp` in descending order. It maps the resulting `QuerySnapshot` to a `List<AppNotification>` and uses `handleError` to gracefully manage any stream errors.
        *   `getUnreadNotificationsCountStream(String userId)`:
            *   **Purpose:** To provide a real-time stream of the count of unread notifications.
            *   **Logic:** Similar to the above, but adds a `.where('isRead', isEqualTo: false)` clause to the query. It then maps the snapshot to `snapshot.docs.length`, providing an efficient way to get the count without fetching the full documents.
        *   `markNotificationAsRead(String userId, String notificationId)`:
            *   **Purpose:** To mark a single notification as read.
            *   **Logic:** Performs a simple `update` operation on the specific notification document, setting the `isRead` field to `true`.
        *   `markAllNotificationsAsRead(String userId)`:
            *   **Purpose:** To mark all of a user's unread notifications as read in a single operation.
            *   **Logic:** It first queries for all documents where `isRead` is `false`. Then, it iterates over the results and adds an `update` operation for each document to a `WriteBatch`. Finally, it commits the batch, which is significantly more efficient for updating multiple documents than performing individual updates.
        *   `deleteNotification(String userId, String notificationId)`:
            *   **Purpose:** To permanently delete a notification.
            *   **Logic:** Performs a `delete` operation on the specified notification document.
        *   `createTestNotification(...)`:
            *   **Purpose:** A debug/testing method to manually create a notification for the currently logged-in user.
            *   **Logic:** It constructs an `AppNotification` object based on the provided parameters, determines an appropriate icon, and adds it to the user's notifications subcollection in Firestore.

*   **`presentation/cubit/notifications_cubit.dart`**:
    *   **Class:** `NotificationsCubit`
    *   **Purpose:** Manages the state of the user's notifications, including the full list, the unread count, and real-time alerts for specific notification types.
    *   **Dependencies:** `NotificationRepository`, `FirebaseAuth`.
    *   **State (`NotificationsState`):** Manages loading, loaded, and error states, holding the list of notifications and the unread count.
    *   **Key Logic & Subscriptions:**
        *   It uses three `StreamSubscription`s to manage its lifecycle:
            1.  `_authStateSubscription`: Listens to `FirebaseAuth.instance.authStateChanges()`. When a user logs in, it triggers `_subscribeToNotifications`. When they log out, it cancels all other subscriptions and resets the state to `NotificationsInitial`. This is crucial for handling user session changes cleanly.
            2.  `_notificationsSubscription`: Subscribes to the stream from `_notificationRepository.getUserNotificationsStream()`.
            3.  `_unreadCountSubscription`: Subscribes to the stream from `_notificationRepository.getUnreadNotificationsCountStream()`.
        *   **Alert Controllers (`_achievementAlertController`, `_adviceAlertController`):** These `StreamController`s are used to broadcast specific, high-priority notifications (like achievements or new advice) that might trigger a pop-up or other special UI element in the app, separate from just appearing in the notification list. The cubit checks incoming notifications and adds them to these streams if they are new and unread.
    *   **Methods:**
        *   `_subscribeToNotifications(String userId)`: The core method that sets up the real-time data flow. It cancels any existing subscriptions and then creates new ones for both the notification list and the unread count. It emits a `NotificationsLoading` state while fetching, but cleverly includes the previous data (if any) to prevent the UI from flickering to an empty state during a refresh.
        *   `markNotificationAsRead`, `markAllNotificationsAsRead`, `deleteNotification`: These are public methods that simply delegate the call to the corresponding method in the `_notificationRepository`.
        *   `close()`: Overridden to ensure all `StreamSubscription`s and `StreamController`s are properly canceled and closed when the cubit is disposed, preventing memory leaks.

*   **`presentation/screens/notification_detail_screen.dart`**:
    *   **Purpose:** Displays the full content of a single `AppNotification`.
    *   **Logic:** It is a stateless widget that receives a single `notification` object.
    *   **Widgets & UI:**
        *   `_getLeadingWidgetForDetail()`: A helper method with conditional logic to display the correct leading icon/image. It checks the `notification.type` and `notification.iconName` to decide whether to show:
            *   An asset image (for achievements).
            *   A network image (for a new follower's avatar).
            *   A standard `Icon` based on the `iconName` string.
        *   The screen uses the `getLocalizedTitle` and `getLocalizedMessage` methods from the `AppNotification` entity to render the text, ensuring it respects the user's locale.

*   **`presentation/widgets/notification_list_item.dart`**:
    *   **Purpose:** Renders a single row in a list of notifications.
    *   **Logic:**
        *   It is wrapped in a `Dismissible` widget to allow swipe-to-delete functionality. The `onDismissed` callback triggers the `deleteNotification` method in the cubit.
        *   It uses the same `_getLeadingWidget` logic as the detail screen.
        *   The UI visually distinguishes between read and unread notifications using font weight, color, and a small colored dot indicator.
        *   `onTap`: When the list item is tapped, it first calls `markNotificationAsRead` on the cubit (if the notification is unread) and then navigates to the `NotificationDetailScreen`.

#### `features/profile/`

*   **Purpose:** Manages the display of the current user's own profile, including their stats, achievements, and posts.
*   **`presentation/cubit/user_profile_cubit.dart`**:
    *   **Purpose:** The central state management for the currently authenticated user's profile. It ensures the profile data is available throughout the app where needed.
    *   **Dependencies:** `UserProfileRepository`, `FirebaseAuth`.
    *   **Logic:**
        *   Similar to `NotificationsCubit`, it uses an `_authStateSubscription` to react to user login/logout.
        *   `_listenToUserProfileChanges(userId)`: The key method. It subscribes to the `userProfileRepository.getUserProfileStream(userId)`. Whenever the user's document in Firestore changes (e.g., XP is updated by a Cloud Function), this stream emits the new `UserProfile` object, and the cubit updates its state to `UserProfileLoaded`, causing all listening UI components to rebuild with the fresh data.
        *   `fetchUserProfile(userId, forceRemote: bool)`: An explicit method to fetch the profile. The `forceRemote` flag is used for pull-to-refresh actions.
        *   `updateUserProfileState(updatedProfile)`: A public method that allows other parts of the app (like the `ProfileSetupCubit` after saving) to push an updated profile directly into this cubit's state, providing instant UI feedback without waiting for the stream to fire.
*   **`presentation/cubit/user_posts_feed_cubit.dart`**:
    *   **Purpose:** Manages the state for the feed of posts specifically created by a single user.
    *   **Logic:**
        *   `fetchUserPosts(userId)`: Subscribes to the `postRepository.getUserPostsStream(userId)` to get a real-time list of posts for the specified user. It emits `UserPostsFeedLoaded` with the list of posts.
*   **`presentation/screens/profile_screen.dart`**:
    *   **Purpose:** The main UI for the authenticated user's profile page.
    *   **Logic:**
        *   It uses a `MultiBlocProvider` to provide the `UserPostsFeedCubit`. The `UserProfileCubit` is expected to be provided higher up in the widget tree (likely in `auth_gate.dart` or `home_page.dart`).
        *   It uses a `BlocBuilder` on `UserProfileCubit` to build the main profile header (name, avatar, stats).
        *   It includes a `RefreshIndicator` to allow the user to refresh both their profile data and their post feed.
        *   It displays user stats like followers and following counts, which are tappable and navigate to the `FollowListScreen`.
        *   It displays a horizontal `ListView` of unlocked achievements. Tapping an achievement opens an `AchievementDetailsDialog`.
        *   It uses a `BlocBuilder` on `UserPostsFeedCubit` to display the list of the user's own posts using `PostListItem` widgets.
        *   `_logout()`: A private method that shows a confirmation dialog and then calls `FirebaseAuth.instance.signOut()`, navigating the user back to the `AuthGate`.
*   **`presentation/widgets/achievement_details_dialog.dart`**:
    *   **Purpose:** A simple, reusable `AlertDialog` that displays the details of a single achievement (large emblem, name, and description).

#### `features/profile_setup/`

*   **Purpose:** Handles the initial creation and subsequent editing of a user's profile.
*   **`data/repositories/user_profile_repository_impl.dart`**:
    *   **Purpose:** The concrete implementation of the `UserProfileRepository`.
    *   **Logic:**
        *   `getUserProfile(userId)`: Fetches a single user profile document from Firestore.
        *   `updateUserProfile(userProfile)`: Updates a user's profile document. The `userProfile.toMap()` method is designed to only include fields that are safe for the client to update. It also adds a server-side `updatedAt` timestamp.
        *   `getUserProfileStream(userId)`: Sets up a real-time listener on a user profile document.
        *   `followUser(currentUserId, targetUserId)`: Updates the `following` array of the `currentUserId`'s document by adding the `targetUserId` using `FieldValue.arrayUnion`. The reciprocal action (updating the target's `followers` array and `followersCount`) is handled by the `handleUserFollowListUpdate` Cloud Function.
        *   `unfollowUser(...)`: Similar to `followUser`, but uses `FieldValue.arrayRemove`.
        *   `getFollowingList(...)` / `getFollowersList(...)`: These methods fetch the lists of followers/following. `getFollowingList` reads the `following` array from the user's document and then queries for those user profiles. `getFollowersList` performs a query using `.where('following', arrayContains: userId)` to find all users who are following the specified user. The `followers` list demonstrates a common denormalization query pattern in Firestore.
*   **`presentation/cubit/profile_setup_cubit.dart`**:
    *   **Purpose:** Manages the state and logic for the profile creation/editing form.
    *   **Logic:**
        *   It's initialized with an optional `initialProfile`. If provided, it enters "editing mode."
        *   It maintains an internal `_currentUserProfile` object that is updated incrementally as the user fills out the form.
        *   `_loadInitialData()`: Fetches the user's profile from the repository to pre-fill the form fields if editing.
        *   `updateField(...)`: A method called by listeners on the `TextEditingController`s to update the internal `_currentUserProfile` state.
        *   `_uploadAvatarImage(...)`: A private helper that takes a `File`, uploads it to Firebase Storage under a `user_avatars/{userId}/avatar.jpg` path, and returns the public download URL.
        *   `saveProfile({File? avatarImageFile})`: The main submission logic. It validates input, uploads a new avatar if provided, constructs the final `UserProfile` object (ensuring `profileSetupComplete` is set to `true`), and calls the repository's `updateUserProfile` method.
*   **`presentation/screens/profile_setup_screen.dart`**:
    *   **Purpose:** The UI for the multi-field profile setup form.
    *   **Logic:**
        *   Uses a `StatefulWidget` to manage `TextEditingController`s and local state for dropdowns/date pickers.
        *   It conditionally renders UI elements and text (e.g., "Save Changes" vs. "Complete Profile") based on whether it's in editing mode.
        *   Uses the `ImagePickerService` to handle avatar selection.
        *   On success (`ProfileSetupSuccess` state), it pops the screen and also updates the global `UserProfileCubit` to ensure the rest of the app immediately reflects the changes.

#### `features/progress/`

*   **Purpose:** Provides users with a visual overview of their fitness progress, including league standing, XP, muscle volume, and performance trends.
*   **`data/repositories/league_repository_impl.dart`**:
    *   **Purpose:** Implements the `LeagueRepository` interface.
    *   **Logic:**
        *   `getAllLeagues()`: Fetches all documents from the `leagues` collection and orders them by `minLevel`. It includes a hardcoded `_getDefaultLeagues()` list as a fallback in case of an error or if the collection is empty.
        *   `getLeaderboardForLeague(...)`: Constructs a complex Firestore query to get the leaderboard. It filters by `profileSetupComplete`, `level` (using range operators `>=` and `<=`), and then orders by `xp` descending to get the top players.
*   **`presentation/cubit/progress_cubit.dart`**:
    *   **Purpose:** A comprehensive cubit that orchestrates the fetching and processing of all data needed for the progress screen.
    *   **Logic:**
        *   `_initialize()`: The entry point. It first fetches static data (`_allLeagues`, `_allPredefinedExercises`) and caches it. Then, it subscribes to the `userProfileRepository` stream.
        *   `_processUserProfileUpdate(userProfile)`: This is the core reactive method, triggered whenever the user's profile updates. It determines the user's current league, calculates XP progress for the current level, and then triggers the asynchronous calculation of all workout-derived stats.
        *   `_calculateVolumePerMuscleGroup7Days(...)`: Fetches the last 7 days of workout logs. It iterates through every set of every exercise, looks up the exercise in the cached `_allPredefinedExercises` list to find its primary and secondary muscle groups, and aggregates the number of sets per muscle group. It uses a `_getMuscleGroupToSvgIdMapping()` to map muscle group names to the IDs used in the SVG files.
        *   `_calculateRpePerWorkoutTrend` & `_calculateWorkingWeightPerWorkoutTrend`: These methods fetch the last `maxWorkoutsForTrend` sessions, iterate through them, and calculate the average RPE or weight for each exercise within each session, compiling a list of data points for trend analysis.
*   **`presentation/screens/progress_screen.dart`**:
    *   **Purpose:** The main UI for the Progress tab.
    *   **Logic:**
        *   Uses a `BlocBuilder` on `ProgressCubit` to display the UI.
        *   Shows a loading state with specific messages (e.g., "Loading workout stats...").
        *   Displays the `LeagueTitleWidget` and `XPProgressBarWidget` with data from the loaded state.
        *   Displays the `MuscleMapWidget` for both front and back views, passing in the calculated `volumePerMuscleGroup7Days` data.
        *   Renders lists of RPE and Strength trends, using a `ValueSparkline` widget to visualize the trend data for each exercise.
*   **`presentation/widgets/`**:
    *   **`league_title_widget.dart`**: A highly animated widget that displays the league name and user level with sliding and gradient-shifting text effects, driven by `AnimationController`s.
    *   **`muscle_map_widget.dart`**: A complex widget that loads an SVG file as a string, programmatically modifies its XML content to change the `fill` color of paths based on workout volume data, and then renders the modified SVG string using the `flutter_svg` package. It uses a color interpolation logic (`_getColorForValue`) to create a heat-map effect.
    *   **`xp_progress_bar_widget.dart`**: A custom progress bar that uses an `AnimationController` to animate the filling of the bar when the user's XP changes.

#### `features/routines/`

*   **Purpose:** Allows users to create, view, edit, and delete their workout routines.
*   **`data/repositories/routine_repository_impl.dart`**:
    *   **Purpose:** Implements the `RoutineRepository` interface.
    *   **Logic:** Contains standard Firestore CRUD operations for the `userRoutines` collection. The `createRoutine` and `updateRoutine` methods correctly apply `FieldValue.serverTimestamp()` for `createdAt` and `updatedAt`. The `deleteRoutine` method includes a security check to ensure a user can only delete their own routines. `copyRoutineFromSnapshot` handles the logic of creating a new routine document for the current user based on the data of a shared routine.
*   **`presentation/cubit/manage_routine_cubit.dart`**:
    *   **Purpose:** Manages the state of a *single* routine that is being created or edited.
    *   **Logic:** Holds a `_currentRoutine` object in its state. Public methods like `updateRoutineName`, `addExerciseToRoutine`, etc., modify this internal object and emit a `ManageRoutineExercisesUpdated` state to trigger a UI rebuild. The `saveRoutine` method performs validation and then calls the appropriate repository method (`createRoutine` or `updateRoutine`).
*   **`presentation/cubit/user_routines_cubit.dart`**:
    *   **Purpose:** Manages the list of *all* routines for the current user.
    *   **Logic:**
        *   `fetchUserRoutines()`: Calls the repository to get the list of routines and emits a `UserRoutinesLoaded` state.
        *   `routineDeleted(routineId)`: A helper method to optimistically remove a routine from the current state's list for immediate UI feedback, without waiting for a full refetch.
*   **`presentation/screens/create_edit_routine_screen.dart`**:
    *   **Purpose:** Provides the form UI for creating or editing a routine.
    *   **Logic:**
        *   It's a `StatefulWidget` to manage `TextEditingController`s and the `_selectedDays` list.
        *   It uses `_dayMapping` to display localized day names for the schedule selection `FilterChip`s.
        *   It uses the `showAddExerciseToRoutineDialog` to allow users to add exercises.
        *   The main "Save" button calls the `saveRoutine` method on the `ManageRoutineCubit`.
*   **`presentation/screens/user_routines_screen.dart`**:
    *   **Purpose:** Displays the list of the user's saved routines.
    *   **Logic:**
        *   Uses a `BlocBuilder` on `UserRoutinesCubit` to display the list of routines using `RoutineListItem` widgets.
        *   Handles the empty state by showing an informative message and a "Create" button.
        *   The Floating Action Button navigates to `CreateEditRoutineScreen` to create a new routine. It awaits the result and calls `fetchUserRoutines` if a new routine was successfully created.
*   **`presentation/widgets/`**:
    *   **`add_exercise_to_routine_dialog.dart`**: A function that shows a dialog flow. First, it pushes the `ExerciseExplorerScreen` in selection mode. After an exercise is selected, it shows a second `AlertDialog` to input the number of sets and notes.
    *   **`routine_list_item.dart`**: Displays a single routine in the list. It includes a `PopupMenuButton` with options to "Start Workout," "Edit," "Share," and "Delete."

#### `features/social/`

*   **Purpose:** Contains all social interaction features, including the main feed, post creation/details, and user profile viewing.
*   **`data/repositories/post_repository_impl.dart`**:
    *   **Purpose:** Implements the `PostRepository` contract for all post-related Firestore operations.
    *   **Logic:** Contains implementations for creating, updating, deleting, and streaming posts and comments. The `castVote` and `retractVote` methods use dot notation (`verificationVotes.$userId`) to update a specific field within a map in Firestore.
*   **`presentation/cubit/`**:
    *   **`create_post_cubit.dart`**: Manages the state for creating or editing a post. The `submitPost` method is complex: it checks for a `mediaImageFile`, uploads it to Firebase Storage if present (using `_uploadPostMedia`), and then calls the repository to either `createPost` or `updatePost`.
    *   **`explore_feed_cubit.dart`**: A simple cubit that subscribes to `postRepository.getAllPostsStream()` to power the main "Explore" feed.
    *   **`follow_list_cubit.dart`**: Manages fetching and paginating the list of followers or following users.
    *   **`post_interaction_cubit.dart`**: Manages the state of a *single* post, including its comments and the current user's interaction with it (like/vote status). It subscribes to both the post document and its comments subcollection to provide real-time updates. It contains methods for all user interactions with a post (`toggleLike`, `castVote`, `addComment`, etc.).
    *   **`user_interaction_cubit.dart`**: Manages the state for viewing *another* user's profile. It's crucial because it listens to *two* streams simultaneously: the target user's profile and the *current authenticated user's* profile. This allows it to determine the `isFollowing` status in real-time. The `toggleFollow` method calls the repository and relies on the stream to update the UI.
*   **`presentation/screens/`**:
    *   **`create_post_screen.dart`**: A complex form screen that adapts its UI based on the `_selectedPostType`. It shows different fields for standard posts, routine shares, and record claims.
    *   **`explore_screen.dart`**: The main social feed screen, powered by `ExploreFeedCubit`.
    *   **`follow_list_screen.dart`**: A screen that displays either a user's followers or the users they are following, based on the `FollowListType` enum passed to it. It implements infinite scrolling by listening to the `ScrollController` and calling `fetchMore` on its cubit.
    *   **`post_detail_screen.dart`**: Displays a single post in full detail, along with its comment thread. It uses the `PostInteractionCubit` to manage its state and handle all interactions.
    *   **`view_user_profile_screen.dart`**: Displays another user's profile. It uses `UserInteractionCubit` to manage the follow/unfollow state and `UserPostsFeedCubit` to display that user's posts.
*   **`presentation/widgets/`**: Contains various reusable widgets for the social features, like `CommentListItem`, `PostListItem`, `VoteProgressBarWidget`, etc.

#### `features/workout_tracking/`

*   **Purpose:** Manages the real-time experience of an active workout session and the summary screen upon completion.
*   **`data/repositories/workout_log_repository_impl.dart`**:
    *   **Purpose:** Implements the `WorkoutLogRepository` contract.
    *   **Logic:**
        *   `startWorkoutSession`: Creates a new document in the `workoutLogs` subcollection with `status: inProgress`.
        *   `getActiveWorkoutSessionStream`: A key method that queries for a workout log with `status: inProgress` and `limit(1)`. This provides a real-time stream of the user's single active session, if one exists.
        *   `completeWorkoutSession`: Updates the session document, setting the status to `completed`, and calculates and saves the final `durationSeconds` and `totalVolume`.
        *   `getAverageWorkingWeightForExercise`: A new, more complex query method. It fetches the last `lookbackLimit` workout logs, iterates through them to find all sets for a specific exercise, and calculates the average weight used.
*   **`presentation/cubit/active_workout_cubit.dart`**:
    *   **Purpose:** Manages the state of an in-progress workout. This is a highly stateful cubit.
    *   **Logic:**
        *   `_subscribeToActiveSession()`: Subscribes to the repository stream. If an active session is found, it loads predefined exercise data and starts a `Timer` to update the `currentDuration` every second.
        *   `startNewWorkout()`: Creates a new `WorkoutSession` object. If it's based on a routine, it pre-populates the sets and even fetches the user's average working weight for each exercise to provide a smart suggestion.
        *   `updateLoggedSet`: Updates the state of a single set within the session. It optimistically updates the local state first by emitting a new `ActiveWorkoutInProgress` state, and then saves the change to Firestore. It includes error handling to revert the state if the save fails.
        *   `completeWorkout()`: Calls the repository to mark the session as complete. It then fetches the user's *updated* profile (which should have been modified by the `calculateAndAwardXpAndStreak` Cloud Function) and emits an `ActiveWorkoutSuccessfullyCompleted` state containing all the data needed for the summary screen.
*   **`presentation/screens/`**:
    *   **`active_workout_screen.dart`**: The main UI for an ongoing workout. It's a `StatefulWidget` to manage the `_currentExerciseIndex` and `_currentSetIndex`. It uses the `_requestSetNavigation` methods to handle moving between sets and exercises. The core of the UI is delegated to the `CurrentSetDisplay` widget.
    *   **`workout_complete_screen.dart`**: The summary screen shown after a workout is completed. It receives the final session data, XP gained, and the updated user profile. It features a `ConfettiController` and a Lottie animation for a celebratory effect. It also has a custom animated `XPProgressBarWidget` that animates from the user's XP *before* the workout to their new total, visually showing the progress and any level-ups.
*   **`presentation/widgets/current_set_display.dart`**:
    *   **Purpose:** The interactive UI for a single set.
    *   **Logic:**
        *   It's a `StatefulWidget` to manage controllers for weight and local state for reps and RPE values.
        *   It displays the exercise name and muscle groups.
        *   It includes a custom `RpeSlider` widget for each repetition, allowing the user to log their perceived exertion for each rep.
        *   It has buttons for incrementing/decrementing weight and reps.
        *   It includes navigation buttons ("PREV. SET", "NEXT SET", "FINISH WORKOUT") that call back to the main screen's navigation logic.

---

## 6. Third-Party Dependencies

This project relies on several key third-party packages to function.

| Package                         | Version    | Purpose                                                                                                                                                                                              |
| ------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `flutter`                       | sdk        | The core Flutter framework for building the UI.                                                                                                                                                      |
| `flutter_localizations`         | sdk        | Provides localization support for Flutter widgets.                                                                                                                                                   |
| **Firebase SDK**                |            |                                                                                                                                                                                                      |
| `firebase_core`                 | ^3.13.1    | Core package for initializing a connection to a Firebase project.                                                                                                                                    |
| `firebase_auth`                 | ^5.5.4     | Handles user authentication (sign-up, sign-in, sign-out) with Firebase.                                                                                                                              |
| `google_sign_in`                | ^6.2.1     | A plugin to enable Google Sign-In functionality, used in conjunction with `firebase_auth`.                                                                                                          |
| `cloud_firestore`               | ^5.6.8     | The primary package for interacting with the Cloud Firestore NoSQL database.                                                                                                                           |
| `firebase_storage`              | ^12.1.0    | Used for uploading, downloading, and managing user-generated files like images.                                                                                                                      |
| **State Management**            |            |                                                                                                                                                                                                      |
| `flutter_bloc`                  | ^9.1.1     | A Flutter library that helps implement the BLoC (Business Logic Component) design pattern for state management. This project uses its `BlocProvider` and `BlocBuilder` widgets extensively.             |
| `bloc`                          | ^9.0.0     | The core Dart package for the BLoC pattern.                                                                                                                                                          |
| **Utilities**                   |            |                                                                                                                                                                                                      |
| `equatable`                     | ^2.0.5     | A package that helps with value equality for Dart objects, making state and entity comparisons in BLoC simpler and more reliable.                                                                      |
| `intl`                          | ^0.20.2    | Provides internationalization and localization facilities, including date, number, and message formatting. Used heavily for dates and localized strings.                                             |
| `image_picker`                  | ^1.1.2     | A Flutter plugin for selecting images from the device's camera or gallery.                                                                                                                           |
| `image_cropper`                 | ^9.1.0     | A plugin used after `image_picker` to provide a UI for cropping images, particularly useful for user avatars.                                                                                          |
| `shared_preferences`            | ^2.5.3     | Provides a simple key-value store for persisting simple data on the device, used here to save the user's selected language.                                                                          |
| **Graphics & Animations**     |            |                                                                                                                                                                                                      |
| `flutter_svg`                   | ^2.0.10+1  | A library for rendering SVG (Scalable Vector Graphics) files. Used for the muscle map visualization.                                                                                                 |
| `animated_background`           | ^2.0.0     | The package used for the `LavaLampBackground` on the login page.                                                                                                                                     |
| `confetti`                      | ^0.7.0     | A package for creating a celebratory confetti effect, used on the `WorkoutCompleteScreen` when a user levels up.                                                                                     |
| `lottie`                        | ^3.1.2     | A library for rendering Adobe After Effects animations exported as JSON. Used for the trophy animation on the `WorkoutCompleteScreen`.                                                               |
| **Dev Dependencies**            |            |                                                                                                                                                                                                      |
| `flutter_lints`                 | ^5.0.0     | A recommended set of linter rules for Flutter projects to enforce good coding practices.                                                                                                             |
| `flutter_launcher_icons`        | ^0.13.1    | A build runner that generates app launcher icons for both Android and iOS from a single source image.                                                                                                |
| `flutter_native_splash`         | ^2.4.0     | A build runner that generates native splash screens for Android and iOS, providing a more professional app launch experience. The configuration in `pubspec.yaml` is highly customized for this project. |

### 6.1. Firebase Functions Dependencies

| Package                      | Version    | Purpose                                                                                                                                        |
| ---------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `firebase-admin`             | ^12.1.0    | The Node.js SDK for interacting with Firebase services from a trusted backend environment (like Cloud Functions). Allows for privileged database access. |
| `firebase-functions`         | ^5.0.1     | The core library for defining and deploying Firebase Cloud Functions.                                                                          |
| `@typescript-eslint/eslint-plugin` & `@typescript-eslint/parser` | ^5.12.0 | Tooling for ESLint to understand and lint TypeScript code. |
| `eslint-config-google`       | ^0.14.0    | Enforces the Google JavaScript/TypeScript style guide.                                                                                        |
| `typescript`                 | ^5.4.5     | The TypeScript language compiler.                                                                                                              |

---

## 7. Environment and Configuration

The project's configuration is managed through several key files.

*   **`pubspec.yaml`**:
    *   **App Icons (`flutter_launcher_icons`):** Configured to use `assets/images/app_icon.png` as the source for generating platform-specific launcher icons. The `min_sdk_android` is also set here.
    *   **Splash Screen (`flutter_native_splash`):** A detailed configuration that uses gradient background images (`splash_gradient_background.png`) and a central logo (`splash_logo.png`) for older Android versions. For Android 12+, it specifies a separate icon and `icon_background_color` to match the brand colors, ensuring a modern look.
    *   **Assets:** Explicitly lists all asset directories (`assets/images/`, `assets/fonts/`, etc.) to make them available to the application at runtime.
    *   **Fonts:** Defines two custom font families, `Inter` and `IBMPlexMono`, and maps different font weights and styles to their corresponding `.ttf` files in the `assets/fonts/` directory.

*   **Firebase Configuration (`.firebaserc`, `firebase.json`):**
    *   These files are generated and managed by the Firebase CLI. They contain the project ID (`muscle-up-8c275`) and the specific configurations for each platform (Android, iOS, Web), including App IDs and the output paths for generated config files. This ensures that the `flutterfire configure` command works correctly.

### 7.1. Android Configuration (Continued)

*   **`android/app/build.gradle.kts`**:
    *   **Purpose:** The main build script for the Android application module.
    *   **Configuration:**
        *   `plugins`: Applies the necessary Gradle plugins, including `com.android.application`, `com.google.gms.google-services` (for Firebase), and `kotlin-android`.
        *   `namespace` & `applicationId`: Defines the unique identifier for the app on the Google Play Store. It is currently set to a default value (`com.example.muscle_up`) and should be changed for a production release.
        *   `compileSdk` & `minSdk`: These values are dynamically set by Flutter's build system (`flutter.compileSdkVersion`, `flutter.minSdkVersion`), ensuring compatibility with the Flutter version being used. The `minSdk` is explicitly coerced to be at least `23`, as specified in `pubspec.yaml`.
        *   **`signingConfig`**: The `release` build type is currently configured to use the `debug` signing key. For a production release, this **must** be changed to a secure, private release keystore.

*   **`android/app/google-services.json`**:
    *   **Purpose:** The configuration file downloaded from the Firebase console. It contains all the necessary project identifiers (`project_id`, `project_number`, `storage_bucket`) and client information (`mobilesdk_app_id`, `api_key`) for the Android app to connect to the correct Firebase project. It also includes OAuth client IDs used for Google Sign-In. **This file contains sensitive information and should ideally not be committed to public version control, although it is present in this snapshot.**

*   **`android/app/src/main/AndroidManifest.xml`**:
    *   **Purpose:** The core manifest file for the Android app, declaring its components and required permissions.
    *   **Configuration:**
        *   `android:label`: Sets the app name displayed on the device to "MuscleUP!".
        *   `android:icon`: Points to the generated launcher icon (`@mipmap/launcher_icon`).
        *   **`com.yalantis.ucrop.UCropActivity`**: An `<activity>` tag is added specifically for the `image_cropper` package. This is a native Android activity that the plugin uses to provide the cropping UI.
        *   **`<queries>` tag:** Added to comply with Android 11+ package visibility rules, allowing the app to interact with other apps that can process text.

*   **`android/app/src/main/res/`**:
    *   **`values/colors.xml`**: Contains custom color definitions specifically to theme the `image_cropper`'s native UI (`UCropActivity`), ensuring it matches the app's orange branding.
    *   **`drawable/` and `values/styles.xml` files**: These directories configure the app's native launch screen.
        *   `launch_background.xml`: A `layer-list` drawable that combines a background image (`background`) and a centered splash image (`splash`). These are generated by the `flutter_native_splash` package.
        *   `styles.xml`: Defines the `LaunchTheme` and `NormalTheme`. The `LaunchTheme` is applied immediately on app start and points to `@drawable/launch_background` to show the splash screen.
        *   **Android 12+ Splash (`values-v31/`)**: For devices running Android 12 and higher, a modern splash screen is configured using `<item name="android:windowSplashScreenAnimatedIcon">` and `<item name="android:windowSplashScreenIconBackgroundColor">`. The icon background color (`#ED5D1A` for light mode, `#C70039` for dark mode) is set to match the app's branding, providing a seamless launch experience on modern devices.

### 7.2. iOS Configuration

*   **`ios/Runner/Info.plist`**:
    *   **Purpose:** The core information property list file for the iOS app. It defines key metadata about the application.
    *   **Configuration:**
        *   `CFBundleDisplayName`: Sets the app's display name on the home screen to "Muscle Up".
        *   `CFBundleIdentifier`: This is set to `$(PRODUCT_BUNDLE_IDENTIFIER)`, which is a variable configured in the Xcode build settings.
        *   `UILaunchStoryboardName`: Specifies `LaunchScreen` as the storyboard to be used for the splash screen.

*   **`ios/Runner/Base.lproj/LaunchScreen.storyboard`**:
    *   **Purpose:** Defines the UI for the native iOS launch screen.
    *   **Logic:** It's a simple storyboard that contains a full-screen `UIImageView` with the `LaunchBackground` image and another centered `UIImageView` with the `LaunchImage`. These images are generated by the `flutter_native_splash` package.

### 7.3. Internationalization (i18n) Configuration

*   **`l10n.yaml`**:
    *   **Purpose:** Configures the `flutter gen-l10n` tool.
    *   **Configuration:**
        *   `arb-dir`: Specifies that the source translation files are in `lib/l10n`.
        *   `template-arb-file`: Defines `app_en.arb` as the template file. All other language files must contain the same keys as this file.
        *   `output-localization-file`: Sets the name of the main generated Dart file to `app_localizations.dart`.
        *   `nullable-getter`: Set to `false`, meaning the generated getters for localized strings will not be nullable, which simplifies their usage in the code.

---

## 8. Design Patterns and Architecture

The project employs a clear architectural approach based on **Clean Architecture** principles, facilitated by the **BLoC (Business Logic Component)** pattern for state management.

### 8.1. Clean Architecture

The project structure is a practical implementation of Clean Architecture, separating the code into distinct layers with specific responsibilities:

1.  **Domain Layer (`core/domain/`)**: This is the innermost layer.
    *   **Entities (`entities/`)**: Contains the core business objects (e.g., `UserProfile`, `Post`). These are pure Dart classes and have no dependencies on any other layer.
    *   **Repositories (`repositories/`)**: Defines abstract interfaces (contracts) for data sources. It dictates *what* data operations can be performed, but not *how*. For example, `UserProfileRepository` defines `getUserProfile`, but doesn't know if the data comes from Firestore, a local database, or an API.

2.  **Data Layer (`features/*/data/`)**:
    *   **Repositories Implementation (`repositories/`)**: Provides the concrete implementation of the repository interfaces from the domain layer. This layer is responsible for interacting with external data sources. In this project, all implementations (`UserProfileRepositoryImpl`, etc.) use the `cloud_firestore` package to communicate with Firebase. This is the only layer that "knows" about Firestore.

3.  **Presentation Layer (`features/*/presentation/`)**: This is the outermost layer, containing all UI and state management logic.
    *   **Cubits (`cubit/`)**: Cubits (a simpler form of BLoC) are responsible for managing the state of a screen or feature. They interact with the domain layer by calling methods on the repository interfaces. They receive data, process it, and emit new states. They have no knowledge of the UI widgets themselves.
    *   **Screens & Widgets (`screens/`, `widgets/`)**: These are the Flutter widgets that build the UI. They listen to state changes from Cubits (via `BlocBuilder` or `BlocListener`) and rebuild themselves accordingly. They dispatch events to the Cubits (e.g., calling `cubit.fetchData()`) in response to user interactions.

This separation provides several key benefits:

*   **Testability:** Each layer can be tested in isolation. The presentation layer can be tested with mock Cubits, and Cubits can be tested with mock repositories.
*   **Maintainability:** Changes to one layer (e.g., switching from Firestore to another database) have minimal impact on other layers. Only the data layer's repository implementations would need to be rewritten.
*   **Scalability:** The feature-first organization makes it easy to add new features without disrupting existing ones.

### 8.2. BLoC / Cubit Pattern

The project extensively uses the **Cubit** pattern (a subset of BLoC) for state management.

*   **How it's used:**
    *   Each feature or complex screen has its own Cubit (e.g., `UserRoutinesCubit`, `PostInteractionCubit`).
    *   The UI widgets use `BlocProvider` to create and provide Cubits to the widget tree.
    *   `BlocBuilder` widgets are used to rebuild parts of the UI in response to new states emitted by the Cubit.
    *   `BlocListener` (used via `BlocConsumer`) is used to perform one-time actions in response to state changes, such as showing a `SnackBar` or navigating to a new screen.
    *   User interactions (like button presses) call methods on the Cubit (e.g., `context.read<MyCubit>().fetchData()`).

*   **Benefits:**
    *   It separates UI from business logic, making the code cleaner and easier to reason about.
    *   It provides a predictable, unidirectional data flow: UI Event -> Cubit -> State -> UI Rebuild.
    *   The use of `Equatable` with state classes prevents unnecessary UI rebuilds, as the `BlocBuilder` only rebuilds if the new state is not equal to the old one.

### 8.3. Dependency Injection

The project uses the `flutter_bloc` package's `RepositoryProvider` for simple dependency injection.

*   **How it's used:** In `main.dart`, `MultiRepositoryProvider` is used to create and provide singleton instances of all repository implementations to the entire application.
*   **Benefits:** Any widget or Cubit lower in the tree can access a repository instance using `RepositoryProvider.of<MyRepository>(context)`. This avoids the need for global singletons or passing repository instances down through widget constructors, leading to cleaner, more decoupled code.

---

## 9. API Endpoints (N/A)

This project is a mobile application with a serverless backend (Firebase). It does not expose any public REST or GraphQL API endpoints. All communication with the backend is done directly through the Firebase SDKs (Firestore, Auth, Storage). The Cloud Functions are triggered by backend events, not by direct HTTP calls from the client, with the exception of any callable functions which are not present in this snapshot.

---

## 10. Security and Permissions

### 10.1. Authentication

*   **Providers:** The app uses Firebase Authentication with two enabled providers:
    1.  **Email/Password:** Standard email and password sign-up.
    2.  **Google Sign-In:** OAuth 2.0 flow for secure authentication via a user's Google account.
*   **Session Management:** Firebase Auth SDKs handle session management automatically, persisting user sessions across app restarts and managing token refresh in the background.

### 10.2. Authorization (Firestore Security Rules)

While the security rules file is not provided in the snapshot, a professional implementation would enforce the following rules on the Firestore database to ensure data integrity and security. **The following is a projection of what the rules *should* be, based on the application's logic.**

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if the user is authenticated.
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper function to check if the user is the owner of the document.
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Users Collection
    match /users/{userId} {
      // ANY authenticated user can read any public user profile.
      allow read: if isSignedIn();

      // ONLY the owner of the profile can create or update it.
      // Allow creation only if the incoming UID matches the user's auth UID.
      allow create: if isOwner(userId);
      // Allow update only by the owner. Restrict which fields can be updated.
      // Prevent users from maliciously giving themselves XP, levels, or followers.
      allow update: if isOwner(userId) &&
                       !('xp' in request.resource.data) &&
                       !('level' in request.resource.data) &&
                       !('followersCount' in request.resource.data) &&
                       !('followingCount' in request.resource.data);
      // Generally, users should not be able to delete their own profiles directly from the client.
      allow delete: if false;

      // Subcollections
      match /workoutLogs/{logId} {
        // A user can only access their own workout logs.
        allow read, write, delete: if isOwner(userId);
      }
      match /notifications/{notificationId} {
        // A user can only access their own notifications.
        allow read, write, delete: if isOwner(userId);
      }
    }

    // userRoutines Collection
    match /userRoutines/{routineId} {
      // Allow read if the routine is public OR if the request is from the owner.
      allow read: if resource.data.isPublic == true || isOwner(resource.data.userId);
      // Allow create, update, delete only by the owner of the routine.
      allow write: if isOwner(request.resource.data.userId);
    }

    // posts Collection
    match /posts/{postId} {
      // Any signed-in user can read any post.
      allow read: if isSignedIn();
      // Allow post creation by any signed-in user.
      allow create: if isSignedIn();
      // Allow update/delete only by the post's author.
      allow update, delete: if isOwner(resource.data.userId);

      // Comments Subcollection
      match /comments/{commentId} {
        // Any signed-in user can read comments.
        allow read: if isSignedIn();
        // Allow comment creation by any signed-in user.
        allow create: if isSignedIn();
        // Allow update/delete only by the comment's author.
        allow update, delete: if isOwner(resource.data.userId);
      }
    }

    // Read-only collections
    match /predefinedExercises/{exerciseId} {
      allow read: if isSignedIn();
      allow write: if false; // Only admin can write
    }
    match /leagues/{leagueId} {
      allow read: if isSignedIn();
      allow write: if false; // Only admin can write
    }
  }
}
```

### 10.3. Data Validation

*   **Client-Side:** The application performs form validation in the UI (e.g., on the `LoginPage` and `ProfileSetupScreen`) to provide immediate feedback to the user.
*   **Server-Side:** Firestore Security Rules provide server-side data validation. For example, rules can enforce that `xp` must be a number, a `displayName` cannot exceed a certain length, or a `post.type` must be one of the allowed enum values. This is a critical security layer to prevent malformed or malicious data from being written to the database.

### 10.4. Potential Security Risks

*   **Insecure Firestore Rules:** If the security rules are too permissive (e.g., `allow read, write: if true;`), any user could read, modify, or delete any data in the database. The projected rules above are a starting point to mitigate this.
*   **Sensitive Information in Logs:** The use of `developer.log` is excellent for debugging, but care must be taken not to log sensitive information (passwords, tokens, PII) in production builds, as these logs can sometimes be accessed on the device.
*   **API Key Exposure:** The `google-services.json` file contains an API key. While these keys are typically restricted to only work from the specified app's package ID, it's best practice to keep them out of public repositories.

---

## 11. Logging, Monitoring, and Error Handling

### 11.1. Logging

*   **Client-Side (Flutter):** The project uses the `dart:developer` library's `log()` function for debugging. This is a good practice as these logs are automatically stripped from release builds. Log messages include a `name` parameter (e.g., "ProfileSetupCubit") which helps in filtering and identifying the source of the log in the console.
*   **Server-Side (Cloud Functions):** The functions use the `firebase-functions/logger` module (`logger.info`, `logger.error`, etc.). These logs are automatically collected and can be viewed in the Google Cloud Console / Firebase Console, providing crucial insight into the execution of backend logic.

### 11.2. Error Handling

*   **Cubits:** Cubits consistently use `try-catch` blocks when interacting with repositories. On failure, they emit a specific `Error` state (e.g., `UserProfileError`, `CreatePostFailure`) which contains an error message. The UI then uses a `BlocBuilder` or `BlocListener` to display this message to the user, often in a `SnackBar`.
*   **Repositories:** Repository implementations also use `try-catch` blocks around their Firestore calls. They throw a new `Exception` with a user-friendly message, which is then caught by the calling Cubit.
*   **Cloud Functions:** The Cloud Functions also contain `try-catch` blocks. Errors are logged using `logger.error` for later inspection and debugging.

### 11.3. Monitoring

The current setup relies on the default monitoring provided by Firebase:
*   **Firebase Console:** Provides dashboards for Firestore usage (reads/writes/deletes), Authentication events, Storage bandwidth, and Cloud Function invocations/errors.
*   **Google Cloud Logging:** All logs from Cloud Functions are sent here, allowing for detailed filtering and analysis. Alerts can be configured based on log messages (e.g., alert if the number of `logger.error` messages exceeds a threshold).

---

## 12. Tiniest Details

This section highlights the purpose and reasoning behind small but important code decisions.

*   **`equatable` Package:** By extending `Equatable` and overriding the `props` getter in all entity and state classes, the project ensures that two instances are considered equal if their properties are equal, not just if they are the same instance in memory. This is fundamental for the BLoC pattern to work efficiently, as it prevents unnecessary UI rebuilds.
*   **`copyWith()` Method:** Nearly every entity and state class has a `copyWith` method. This is a core tenet of immutable state management. Instead of modifying an existing state object, the cubit creates a *new* object that is a copy of the old one but with specific properties changed. This ensures state is predictable and prevents side effects.
*   `allowNull...` **Flags in `copyWith`:** In some `copyWith` methods (e.g., `UserProfile`), flags like `allowNullDisplayName` are present. This is a clever pattern to distinguish between "I don't want to change this field" (the parameter is `null`) and "I want to explicitly set this field to `null`" (the parameter is `null` and the `allowNull...` flag is `true`).
*   **`Key` in `BlocProvider`:** In `PostListItem`, the `BlocProvider` is given a `key: ValueKey(post.id)`. This is critical in a `ListView`. Without it, as the user scrolls, Flutter might reuse the widget state (and thus the `PostInteractionCubit` instance) for a different post, leading to incorrect data being displayed. The `ValueKey` ensures that a unique `PostInteractionCubit` is created and maintained for each unique post ID.
*   **Stream Management (`StreamSubscription`):** Cubits like `NotificationsCubit` and `PostInteractionCubit` meticulously manage their `StreamSubscription`s. They are stored as instance variables and canceled in the `close()` method and before a new subscription is created. This is vital to prevent memory leaks and to stop listening to data for a user who has logged out or a screen that has been disposed.
*   **Optimistic UI Updates:** In methods like `toggleLike` and `castVote`, the UI is updated *before* the network request to the backend completes. The cubit immediately emits a new state with the "liked" post. If the network call fails, it reverts the state back to the original. This makes the UI feel instantaneous and responsive to the user.

---

## 13. Suggestions and Improvements

While the project is well-structured, there are several areas for potential improvement.

### 13.1. Code & Architecture

*   **Error Handling Granularity:** Currently, most `catch` blocks in repositories throw a generic `Exception('Failed to...: ${e.toString()}')`. It would be more robust to define custom exception classes (e.g., `UserProfileNotFoundException`, `NetworkException`). This would allow the Cubits to catch specific exceptions and emit more granular error states, enabling the UI to show more specific error messages or UI states.
*   **Use `freezed`:** The `equatable` package is good, but the `freezed` package could further reduce boilerplate. It auto-generates `copyWith`, `==`, `hashCode`, and `toString` methods, as well as providing powerful sealed class capabilities for states, which can make the `BlocBuilder` code even cleaner and safer (e.g., using `when` or `map` to exhaustively handle all possible states).
*   **Service Locator vs. `RepositoryProvider`:** For a larger application, using a dedicated service locator like `get_it` instead of `RepositoryProvider` can be more flexible. It decouples the dependency providing mechanism from the widget tree, which can be useful for accessing services from non-UI code.
*   **Cloud Function Code Organization:** As the number of functions grows, `functions/src/index.ts` could become very large. It would be beneficial to split each function into its own file (e.g., `functions/src/auth.ts`, `functions/src/posts.ts`) and import them into `index.ts`.
*   **Redundant Code in `_ProfileCheckGate`:** The `_ProfileCheckGate` logic inside `auth_gate.dart` is sound but could potentially be integrated into a more sophisticated `AuthenticationBloc` that manages not just the auth state but also the user profile loading state as a single, cohesive state machine.

### 13.2. Performance

*   **Image Optimization:** While `image_cropper` and `image_picker` have quality settings, a dedicated image processing service (like a Cloud Function with ImageMagick or a third-party service like Cloudinary) could be used to generate multiple image sizes (thumbnails, medium, large) on upload. This would reduce the amount of data the client needs to download, especially for feed views with many images.
*   **Firestore Query Optimization:**
    *   **Follower List:** The current implementation of `getFollowersList` performs a collection query (`.where('following', arrayContains: ...)`). For users with millions of followers, this could become slow. A common scaling pattern is to denormalize this by creating a `followers` subcollection under each user's document (`users/{userId}/followers/{followerId}`), though this increases write costs.
    *   **Pagination:** The `getFollowersList` method has parameters for pagination (`lastFetchedUserId`), but `getFollowingList` does not. While the `following` array is unlikely to exceed a few thousand, for consistency and future-proofing, pagination could be added there as well.

### 13.3. Security & Best Practices

*   **Environment-Specific Firebase Config:** Instead of committing `google-services.json` and `firebase_options.dart` directly, it's better practice to use different Firebase projects for development and production. This can be managed using Flutter flavors and different configuration files for each environment, loaded at build time.
*   **Input Sanitization in Cloud Functions:** While client-side validation exists, all data received in Cloud Functions (especially from triggers like `onDocumentWritten`) should be treated as untrusted. The functions should validate the incoming data schema before processing to prevent errors or malicious data from corrupting the system. For example, ensuring `xpGained` is within a reasonable range before adding it to a user's total.

### 13.4. Documentation & Naming

*   **Magic Strings:** Keys for localization (e.g., `'loginPageErrorInvalidCredential'`) and Firestore fields (e.g., `'profileSetupComplete'`) are used as raw strings throughout the app. It would be safer to define these as `const` variables in a central file (e.g., `lib/core/constants/firestore_fields.dart`) to prevent typos and make refactoring easier.
*   **Cubit Naming:** The name `UserInteractionCubit` is slightly ambiguous. A more descriptive name might be `ViewUserProfileCubit` or `TargetProfileCubit` to make it clear that it's for viewing *another* user's profile, distinguishing it from the global `UserProfileCubit`.

This concludes the comprehensive documentation for the Muscle UP! project. The codebase demonstrates a strong foundation in modern Flutter development practices with a clear, scalable architecture. The suggested improvements are aimed at further enhancing its robustness, performance, and maintainability as the project grows.