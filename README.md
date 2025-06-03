# MuscleUP: Всеосяжна Технічна Документація

**Девіз:** Піднімай Свої Ваги, Об'єднуй Команду, Досягай Цілей. Будуй Свою Силу, Разом.

**Версія додатку (згідно `pubspec.yaml`):** `0.1.0`
**Стан проєкту (згідно `README.md` та аналізу коду):** Фаза Розширених Соціальних Функцій (включаючи типи постів та базовий соціальний граф) реалізована або в активній розробці.

## Зміст

1.  [Вступ](#1-вступ)
2.  [Поточний Стан Проєкту та Реалізовані Функції](#2-поточний-стан-проекту-та-реалізовані-функції)
3.  [Ключові Архітектурні Принципи](#3-ключові-архітектурні-принципи)
4.  [Технологічний Стек](#4-технологічний-стек)
5.  [Структура Проєкту](#5-структура-проекту)
6.  [Налаштування Проєкту та Конфігураційні Файли](#6-налаштування-проекту-та-конфігураційні-файли)
    *   [6.1. Firebase Конфігурація](#61-firebase-конфігурація)
    *   [6.2. `pubspec.yaml` – Залежності та Ресурси](#62-pubspecyaml--залежності-та-ресурси)
    *   [6.3. Інші Конфігурації](#63-інші-конфігурації)
7.  [Глибоке Занурення в Ключові Компоненти та UX](#7-глибоке-занурення-в-ключові-компоненти-та-ux)
    *   [7.1. Автентифікація та Налаштування Профілю](#71-автентифікація-та-налаштування-профілю)
    *   [7.2. Основна Навігація: `HomePage` та `DashboardScreen`](#72-основна-навігація-homepage-та-dashboardscreen)
    *   [7.3. Соціальні Функції (`lib/features/social`)](#73-соціальні-функції-libfeaturessocial)
    *   [7.4. Система Сповіщень](#74-система-сповіщень)
    *   [7.5. Бібліотека Вправ](#75-бібліотека-вправ)
    *   [7.6. Управління Тренувальними Рутинами](#76-управління-тренувальними-рутинами)
    *   [7.7. Відстеження Тренувань](#77-відстеження-тренувань)
    *   [7.8. Відстеження Прогресу](#78-відстеження-прогресу)
    *   [7.9. Система Досягнень](#79-система-досягнень)
    *   [7.10. Деталі UI/UX та Загальні Віджети](#710-деталі-uiux-та-загальні-віджети)
8.  [Бекенд: Структура Firebase Cloud Firestore](#8-бекенд-структура-firebase-cloud-firestore)
9.  [Логіка Firebase Cloud Functions (`functions/src/index.ts`)](#9-логіка-firebase-cloud-functions-functionssrcindexts)
10. [Налаштування та Запуск Проєкту](#10-налаштування-та-запуск-проекту)
11. [Дорожня Карта та Майбутній Розвиток](#11-дорожня-карта-та-майбутній-розвиток)

---

## 1. Вступ

MuscleUP — це інноваційний мобільний фітнес-додаток, розроблений для революціонізації вашого підходу до тренувань. Як зазначено в `pubspec.yaml`, це "Next-gen Fitness App. New height, New companions." Наша місія — створити високомотивуюче, соціально інтерактивне та гейміфіковане середовище, яке не тільки допомагає користувачам досягати своїх фітнес-цілей, але й робить процес приємним, сприяючи довгостроковій залученості. MuscleUP дозволяє детальне відстеження тренувань, персоналізоване встановлення цілей, аналіз прогресу за допомогою унікальних метрик (таких як RPE для кожного повторення), підтримку спільноти через обмін досягненнями, рутинами, рекордами та соціальну взаємодію через різні типи постів та систему підписок.

Цей документ надає всебічний огляд проєкту MuscleUP, деталізуючи його поточні функції, основну бізнес-логіку, програмну архітектуру, дизайн бекенду з Firebase та функціональність його компонентів. Він наголошує на модульності, масштабованості та легкості підтримки.

## 2. Поточний Стан Проєкту та Реалізовані Функції

MuscleUP інкорпорував надійний набір ключових фітнес-функцій і активно розширює соціальні можливості. Реалізовано створення різноманітних типів постів (стандартні, поширення рутин, заявки на рекорди), система лайків, коментарів, голосування за рекорди та базовий соціальний граф (підписки).

**Ключові Реалізовані Функції:**

*   **Автентифікація та Профіль Користувача:**
    *   Безпечний вхід/реєстрація за допомогою Email/Пароль та Google Sign-In (пакети `firebase_auth`, `google_sign_in`). Логіка в `lib/login_page.dart`.
    *   Автоматичне створення початкового профілю (`profileSetupComplete: false`) через Firebase Function `createUserProfile`.
    *   Екран налаштування профілю `ProfileSetupScreen` (`lib/features/profile_setup/`) для введення деталей користувача (ім'я користувача, стать, цілі тощо), керований `ProfileSetupCubit`.
    *   Оновлення профілю користувача в реальному часі через `UserProfileCubit` (`lib/features/profile/`).
    *   Нагородження досягненням "Early Bird" після завершення налаштування профілю (Firebase Function `checkProfileSetupCompletionAchievements`).

*   **Основна Навігація та Панель Інструментів (`HomePage` та `DashboardScreen`):**
    *   `HomePage` (`lib/home_page.dart`) з динамічним AppBar та `BottomNavigationBar` (Рутини, Explore, Прогрес, Профіль).
    *   `DashboardScreen` (`lib/features/dashboard/`) з персоналізованим привітанням, статистикою, графіком об'єму, сповіщеннями та розкладом (`UpcomingScheduleWidget`).
    *   FloatingActionButton "START WORKOUT" з інтелектуальною навігацією (відновлення сесії, список рутин, створення рутини).

*   **Соціальні Функції (`lib/features/social/`):**
    *   **Система Постів:**
        *   Сутність `Post` (`lib/core/domain/entities/post.dart`) з типами `standard`, `recordClaim`, `routineShare`. Включає деталі автора, контент, лайки, коментарі, деталі рутини/рекорду.
        *   Колекція Firestore `posts`. `PostRepository` для CRUD.
        *   **Створення Постів (`CreatePostScreen`):**
            *   Стандартні текстові пости.
            *   **Поширення Рутини:** Вибір рутини, автоматичне заповнення, `routineSnapshot`.
            *   **Заявка на Рекорд:** Вибір вправи, введення ваги/повторень, URL відео, `recordDetails`.
            *   `CreatePostCubit` керує створенням.
    *   **Стрічка "Explore" (`ExploreScreen`):**
        *   Відображення постів усіх користувачів (сортування за новизною). `ExploreFeedCubit`.
        *   `PostListItem` з динамічним контентом `PostCardContentWidget` для різних типів постів.
    *   **Взаємодія з Постами (Лайки, Коментарі, Голосування):**
        *   **Лайки:** Керуються `PostInteractionCubit`.
        *   **Коментарі (`PostDetailScreen`):** Сутність `Comment`, підколекція `comments`. Додавання, перегляд, керування видимістю. Cloud Functions `onCommentCreated`/`onCommentDeleted` оновлюють `commentsCount`.
        *   **Додавання Спільної Рутини:** Кнопка "Add to My Routines" на постах `routineShare`, використовує `RoutineRepository.copyRoutineFromSnapshot`.
        *   **Голосування за Рекорди:** UI для голосування "Validate"/"Dispute" на `PostDetailScreen`. Логіка в `PostInteractionCubit`. Cloud Functions `onRecordClaimVoteCasted` (XP за голос) та `processRecordClaimDeadlines` (обробка дедлайнів, верифікація, нарахування XP/досягнень автору).
    *   **Соціальний Граф (Підписки):**
        *   Сутність `UserProfile` (`lib/core/domain/entities/user_profile.dart`) містить список `following` та лічильники `followersCount`, `followingCount`.
        *   `UserProfileRepository` (`lib/features/profile_setup/data/repositories/user_profile_repository_impl.dart`) реалізує методи `followUser`, `unfollowUser`, `getFollowingList`, `getFollowersList`.
        *   `UserInteractionCubit` (`lib/features/social/presentation/cubit/user_interaction_cubit.dart`) керує логікою підписки/відписки на екрані `ViewUserProfileScreen`.
        *   Firebase Function `handleUserFollowListUpdate` (`functions/src/index.ts`) автоматично оновлює лічильники `followersCount`, `followingCount` та надсилає сповіщення про нового підписника.
        *   Екран `FollowListScreen` для перегляду списків підписників/підписок.

*   **Бібліотека Вправ (`ExerciseExplorerScreen`):**
    *   Перегляд стандартизованих вправ (`PredefinedExercise`) з Firestore (`predefinedExercises`). `ExerciseExplorerCubit`.
    *   HTTPS-тригер `seedPredefinedExercises` для наповнення бази.

*   **Управління Тренувальними Рутинами (`lib/features/routines/`):**
    *   `UserRoutinesScreen` для CRUD операцій та спільного доступу. Сутність `UserRoutine`.
    *   `CreateEditRoutineScreen` для створення/редагування рутин. `ManageRoutineCubit`.

*   **Відстеження Тренувань (`lib/features/workout_tracking/`):**
    *   `ActiveWorkoutScreen` для логування сетів, ваги, повторень, RPE. Відновлення незавершених сесій. `ActiveWorkoutCubit`.
    *   Firebase Function `calculateAndAwardXpAndStreak` для нарахування XP, оновлення серії, нагородження досягненням "First Workout".

*   **Завершення Тренування (`WorkoutCompleteScreen`):**
    *   Святковий екран з анімацією Lottie (`assets/animations/trophy_animation.json`) та конфетті.

*   **Відстеження Прогресу (`lib/features/progress/`):**
    *   `ProgressScreen` та `ProgressCubit`.
    *   Система Ліг (`LeagueInfo`), XP та рівні (`XPProgressBarWidget`).
    *   Карта М'язів (`MuscleMapWidget`) з SVG для чоловічої/жіночої статі (`assets/images/male_*.svg`, `assets/images/female_*.svg`).
    *   Статистика тренувань: тренди RPE та робочої ваги.

*   **Система Сповіщень (`lib/features/notifications/`):**
    *   Модель `AppNotification`, `NotificationType`. `NotificationsCubit` для оновлень в реальному часі, сповіщень в додатку (досягнення, поради, нові підписники).

*   **Система Досягнень:**
    *   Реалізовано "Early Bird", "First Workout", "Personal Record Set". Фреймворк для додавання нових.

## 3. Ключові Архітектурні Принципи

Проєкт MuscleUP дотримується сучасних найкращих практик розробки програмного забезпечення:

*   **Модульність (Feature-First):** Організація коду за функціональними модулями в `lib/features/` (наприклад, `social`, `routines`, `profile`).
*   **Чиста Архітектура (Багатошаровий підхід):** Концептуальне розділення на шари:
    *   **Презентація (UI):** Віджети Flutter, Екрани, Cubits/Blocs.
    *   **Домен (Domain):** Сутності (моделі даних, наприклад, `UserProfile`), абстрактні Репозиторії (інтерфейси).
    *   **Дані (Data):** Реалізації Репозиторіїв, джерела даних (Firebase).
*   **Управління Станом (BLoC/Cubit):** Використання `flutter_bloc` для управління станом UI та бізнес-логікою.
*   **Впровадження Залежностей (DI):** `RepositoryProvider` для надання екземплярів репозиторіїв.
*   **Абстракція Даних (Репозиторії):** Абстрагування джерел даних від доменного та презентаційного шарів.
*   **Масштабованість та Легкість Підтримки:** Забезпечується модульністю та чітким розділенням відповідальностей.

## 4. Технологічний Стек

*   **Фронтенд:**
    *   **Фреймворк:** Flutter (SDK `^3.8.0`)
    *   **Мова:** Dart (SDK `^3.8.0`)
    *   **Управління Станом:** `flutter_bloc: ^9.1.1`, `bloc: ^9.0.0`
    *   **Утиліти:** `equatable: ^2.0.5`, `intl: ^0.19.0`
    *   **Графіка та UI:** `flutter_svg: ^2.0.10+1`, `animated_background: ^2.0.0`, `confetti: ^0.7.0`, `lottie: ^3.1.2`
*   **Бекенд (Firebase):**
    *   **Ядро:** `firebase_core: ^3.13.1`
    *   **Автентифікація:** `firebase_auth: ^5.5.4`, `google_sign_in: ^6.2.1`
    *   **База Даних:** `cloud_firestore: ^5.6.8`
    *   **Безсерверні Функції:** Firebase Cloud Functions (TypeScript, Node.js v20)
*   **Розробка та Інструменти:**
    *   **Лінтери:** `flutter_lints: ^5.0.0` (конфігурація в `analysis_options.yaml`)
    *   **Іконки Додатку:** `flutter_launcher_icons: ^0.13.1` (конфігурація в `pubspec.yaml`)
    *   **Логування:** `dart:developer`
    *   **Firebase Project ID:** `muscle-up-8c275`

## 5. Структура Проєкту

Проєкт дотримується структури каталогів "feature-first" всередині папки `lib`.

muscle_up/
├── android/                            # Файли, специфічні для Android
├── assets/                             # Ресурси додатку
│   ├── animations/                     # Анімації Lottie (trophy_animation.json)
│   ├── fonts/                          # Шрифти (Inter, IBMPlexMono)
│   └── images/                         # Зображення (app_icon.png, SVG м'язів, google_logo.png)
├── functions/                          # Firebase Cloud Functions (TypeScript)
│   ├── src/index.ts                    # Основний файл Cloud Functions
│   └── package.json                    # Залежності функцій
├── ios/                                # Файли, специфічні для iOS
├── lib/
│   ├── auth_gate.dart                  # Керування станом автентифікації
│   ├── firebase_options.dart           # Згенерована конфігурація Firebase
│   ├── home_page.dart                  # Головний екран з навігацією
│   ├── login_page.dart                 # Екран входу/реєстрації
│   ├── main.dart                       # Точка входу, налаштування теми та репозиторіїв
│   │
│   ├── core/                           # Основні сутності, репозиторії, use cases
│   │   └── domain/
│   │       ├── entities/               # Моделі даних (UserProfile, Post, UserRoutine тощо)
│   │       └── repositories/           # Абстрактні інтерфейси репозиторіїв
│   │
│   ├── features/                       # Модулі за функціоналом
│   │   ├── dashboard/                  # Панель інструментів
│   │   ├── exercise_explorer/          # Перегляд вправ
│   │   ├── notifications/              # Сповіщення
│   │   ├── profile/                    # Перегляд профілю користувача
│   │   ├── profile_setup/              # Створення/редагування профілю
│   │   ├── progress/                   # Відстеження прогресу
│   │   ├── routines/                   # Управління рутинами
│   │   ├── social/                     # Соціальні функції (пости, коментарі, підписки)
│   │   └── workout_tracking/           # Відстеження тренувань
│   │
│   ├── utils/                          # Утилітні функції (наприклад, duration_formatter.dart)
│   └── widgets/                        # Загальні віджети (наприклад, lava_lamp_background.dart)
│
├── pubspec.yaml                        # Залежності та ресурси Flutter
├── README.md                           # Цей файл документації
└── ...                                 # Інші конфігураційні файли

## 6. Налаштування Проєкту та Конфігураційні Файли

### 6.1. Firebase Конфігурація

*   **`.firebaserc`**: Визначає стандартний проєкт Firebase для CLI.
    ```json
    {
      "projects": {
        "default": "muscle-up-8c275"
      }
    }
    ```
*   **`firebase.json`**: Детальна конфігурація Firebase для різних платформ та сервісів.
    *   Визначає `projectId` (`muscle-up-8c275`), `appId` для Android, шляхи до `google-services.json`.
    *   Конфігурує генерацію `lib/firebase_options.dart` для Dart, вказуючи конфігурації для Android, iOS, macOS, Web, Windows.
    *   Налаштовує Firebase Functions: джерело (`functions`), ігноровані файли, та команди `predeploy`.
*   **`android/app/google-services.json`**: Специфічний для Android файл конфігурації Firebase, містить `project_id`, `mobilesdk_app_id`, OAuth клієнти та API ключі.
*   **`lib/firebase_options.dart`**: Згенерований файл `flutterfire configure`, містить константи для ініціалізації Firebase на різних платформах.

### 6.2. `pubspec.yaml` – Залежності та Ресурси

Файл `pubspec.yaml` є ключовим для управління залежностями та ресурсами проєкту.

*   **`name`**: `muscle_up`
*   **`description`**: "Next-gen Fitness App. New height, New companions."
*   **`publish_to: 'none'`**: Запобігає випадковій публікації в pub.dev.
*   **`version`**: `0.1.0` (Поточна версія додатку).
*   **`environment.sdk`**: `^3.8.0` (Dart SDK).

*   **`dependencies`**:
    *   **Flutter SDK**: `flutter: sdk: flutter`
    *   **Firebase**:
        *   `firebase_core: ^3.13.1`: Базовий пакет для Firebase.
        *   `firebase_auth: ^5.5.4`: Автентифікація.
        *   `google_sign_in: ^6.2.1`: Вхід через Google.
        *   `cloud_firestore: ^5.6.8`: База даних Firestore.
    *   **State Management**:
        *   `flutter_bloc: ^9.1.1`, `bloc: ^9.0.0`: Для BLoC/Cubit патерну.
    *   **Utilities**:
        *   `equatable: ^2.0.5`: Для порівняння об'єктів.
        *   `intl: ^0.19.0`: Для інтернаціоналізації та форматування.
    *   **Graphics & Animations**:
        *   `flutter_svg: ^2.0.10+1`: Для SVG (карти м'язів).
        *   `animated_background: ^2.0.0`: Анімований фон для `LoginPage`.
        *   `confetti: ^0.7.0`: Ефект конфетті.
        *   `lottie: ^3.1.2`: Анімації Lottie (трофей).

*   **`dev_dependencies`**:
    *   `flutter_test: sdk: flutter`
    *   `flutter_lints: ^5.0.0`: Правила лінтингу.
    *   `flutter_launcher_icons: ^0.13.1`: Генерація іконок додатку.

*   **`flutter_launcher_icons` (Конфігурація)**:
    *   Використовує `assets/images/app_icon.png` для генерації іконок для Android (адаптивні) та iOS.
    *   `min_sdk_android: 23`.

*   **`flutter.uses-material-design: true`**

*   **`flutter.assets`**:
    *   `assets/images/` (включаючи `app_icon.png`, `male_front.svg`, `male_back.svg`, `female_front.svg`, `female_back.svg`)
    *   `assets/fonts/`
    *   `assets/animations/` (включаючи `trophy_animation.json`)

*   **`flutter.fonts`**:
    *   Сімейство `Inter` з різними накресленнями (Regular, Italic, Light, Medium, SemiBold, Bold, ExtraBold, Black) з файлів `.ttf`.
    *   Сімейство `IBMPlexMono` (Regular, Bold).

### 6.3. Інші Конфігурації

*   **`.gitignore`**: Стандартний набір ігнорованих файлів для Flutter/Dart/IntelliJ/Android проєктів. Важливо, що `.vscode/` закоментовано, дозволяючи версіонувати налаштування VS Code.
*   **`.metadata`**: Відстежує властивості проєкту Flutter, такі як `revision` та `channel` Flutter SDK, з яким проєкт було створено або оновлено. Також містить інформацію про міграцію платформ та список `unmanaged_files`.
*   **`analysis_options.yaml`**: Включає стандартний набір правил лінтингу `package:flutter_lints/flutter.yaml`.
*   **`devtools_options.yaml`**: Зберігає налаштування для Dart & Flutter DevTools, наразі без специфічних розширень.
*   **Android Build System (`android/` директорія):**
    *   `android/build.gradle.kts`: Конфігурація Gradle для всіх підпроєктів, встановлює кастомну `buildDirectory`.
    *   `android/gradle.properties`: Налаштування JVM для Gradle, ввімкнення AndroidX та Jetifier.
    *   `android/settings.gradle.kts`: Підключає Flutter SDK Gradle плагін, визначає версії плагінів `com.android.application` та `com.google.gms.google-services`.
    *   `android/app/build.gradle.kts`: Специфічна конфігурація для Android додатку, включає `namespace`, `compileSdk`, `minSdk`, `targetSdk`, `versionCode`, `versionName`.
    *   `android/app/src/main/AndroidManifest.xml`: Маніфест Android додатку, визначає `android:label` (`MuscleUP!`), іконку (`@mipmap/launcher_icon`), основну Activity та необхідні дозволи/запити.
*   **iOS Project Setup (`ios/` директорія):**
    *   `ios/Runner.xcodeproj/project.pbxproj`: Основний файл конфігурації проєкту Xcode. Визначає структуру проєкту, налаштування збірки, цілі (targets) та зв'язки між файлами. Містить посилання на Flutter Frameworks, конфігураційні файли `.xcconfig`, файли ресурсів та вихідного коду.
    *   `ios/Runner/Info.plist`: Список властивостей для iOS додатку, включаючи `CFBundleDisplayName` (`Muscle Up`), `CFBundleIdentifier`, версії, підтримувані орієнтації та інше.
    *   `ios/Runner/AppDelegate.swift`: Точка входу для iOS додатку, реєструє плагіни Flutter.

## 7. Глибоке Занурення в Ключові Компоненти та UX

(Цей розділ значно розширює відповідний розділ з `README.md`, додаючи деталі з файлів коду та пов'язуючи компоненти).

### 7.1. Автентифікація та Налаштування Профілю

*   **Вхід/Реєстрація (`lib/login_page.dart`):**
    *   Надає UI для входу/реєстрації через Email/Пароль та Google Sign-In.
    *   Використовує анімований фон `LavaLampBackground` (`lib/widgets/lava_lamp_background.dart`).
    *   Керує станом завантаження (`_isLoading`) та відображенням помилок (`_errorMessage`).
    *   Методи `_submitForm()` для Email/Password та `_signInWithGoogle()` для Google.
    *   **Важливо:** Логіка створення профілю користувача перенесена в Cloud Function `createUserProfile`, яка спрацьовує автоматично при створенні нового Firebase Auth користувача. `LoginPage` більше не викликає `_createInitialUserProfile`.

*   **Шлюз Автентифікації (`lib/auth_gate.dart`):**
    *   Прослуховує `FirebaseAuth.instance.authStateChanges()`.
    *   Якщо користувач не автентифікований, перенаправляє на `LoginPage`.
    *   Якщо автентифікований:
        *   Використовує `_ProfileCheckGate` для отримання `UserProfile` з Firestore через `UserProfileRepository.getUserProfileStream(userId)`.
        *   Якщо профіль ще не існує (після спрацювання `createUserProfile` може бути невелика затримка) або `profileSetupComplete == false`, перенаправляє на `ProfileSetupScreen`. Показує індикатор завантаження під час очікування синхронізації профілю.
        *   Якщо `profileSetupComplete == true`, перенаправляє на `HomePage` та надає `UserProfileCubit`.

*   **Створення Профілю Користувача (Firebase Function `createUserProfile`):**
    *   Тригер: `onAuthUserCreate` (створення нового Firebase Auth користувача).
    *   Створює документ в `users/{userId}` з полями за замовчуванням: `uid`, `email`, `profilePictureUrl` (з Auth, якщо є), `profileSetupComplete: false`, `xp: 0`, `level: 1`, `followersCount: 0`, `followingCount: 0`, `achievedRewardIds: []`, `following: []`, `createdAt`, `updatedAt`.

*   **Налаштування Профілю (`lib/features/profile_setup/presentation/screens/profile_setup_screen.dart`):**
    *   Дозволяє користувачам вводити/редагувати деталі профілю: ім'я користувача, відображуване ім'я, стать, дата народження, зріст, вага, фітнес-цілі, рівень активності.
    *   Керується `ProfileSetupCubit`.
    *   При збереженні встановлює `profileSetupComplete: true`.
    *   Може бути викликаний для редагування існуючого профілю, передаючи `userProfileToEdit`.

*   **Керування Профілем Користувача (`UserProfileCubit`):**
    *   Надає `UserProfile` для UI.
    *   Підписується на `UserProfileRepository.getUserProfileStream()` для оновлень в реальному часі.

*   **Нагорода за Налаштування Профілю (Firebase Function `checkProfileSetupCompletionAchievements`):**
    *   Тригер: `onDocumentWritten` на `users/{userId}`.
    *   Якщо `profileSetupComplete` змінюється на `true` і досягнення "Early Bird" ще не отримане, нагороджує ним та надсилає сповіщення.

### 7.2. Основна Навігація: `HomePage` та `DashboardScreen`

*   **`HomePage` (`lib/home_page.dart`):**
    *   Головний екран після входу та налаштування профілю. Надає `NotificationsCubit`.
    *   **AppBar:** Динамічний заголовок. Натискання на "MuscleUP" веде на `DashboardScreen`.
    *   **`BottomNavigationBar`:**
        1.  **Routines:** `UserRoutinesScreen`
        2.  **Explore:** `ExploreScreen` (соціальна стрічка)
        3.  **Progress:** `ProgressScreen`
        4.  **Profile:** `ProfileScreen`
    *   **FloatingActionButton ("START WORKOUT"):**
        *   З'являється тільки на `DashboardScreen`.
        *   Логіка:
            1.  Перевіряє активну сесію (`WorkoutLogRepository.getActiveWorkoutSessionStream()`). Якщо є, відновлює в `ActiveWorkoutScreen`.
            2.  Якщо немає, перевіряє наявність рутин (`RoutineRepository.getUserRoutines()`). Якщо є, переходить на вкладку "Routines".
            3.  Якщо рутин немає, переходить на `CreateEditRoutineScreen`.

*   **`DashboardScreen` (`lib/features/dashboard/presentation/screens/dashboard_screen.dart`):**
    *   Привітання користувача (з `UserProfileCubit`).
    *   Іконка та лічильник серії тренувань.
    *   Картки статистики: вага, серія, дотримання графіку (з `DashboardStatsCubit`).
    *   Графік тренду об'єму (`VolumeTrendChartWidget`) за останні 7 тренувань.
    *   Розклад на 7 днів (`UpcomingScheduleWidget`, дані з `UpcomingScheduleCubit`).
    *   Секція сповіщень (останні непрочитані з `NotificationsCubit`).

### 7.3. Соціальні Функції (`lib/features/social`)

Цей модуль зазнав значних оновлень і включає розширену функціональність постів та систему підписок.

*   **Сутності:**
    *   **`Post` (`lib/core/domain/entities/post.dart`):**
        *   `id`, `userId`, `authorUsername`, `authorProfilePicUrl`, `timestamp`, `updatedAt`.
        *   `type`: `PostType` (enum: `standard`, `recordClaim`, `routineShare`).
        *   `textContent`, `mediaUrl` (для майбутнього).
        *   `likedBy` (List<String>), `commentsCount` (int), `isCommentsEnabled` (bool).
        *   **Для `routineShare`**: `relatedRoutineId`, `routineSnapshot` (Map<String, dynamic>).
        *   **Для `recordClaim`**: `recordDetails` (Map: `exerciseId`, `exerciseName`, `weightKg`, `reps`, `videoUrl`), `recordVerificationStatus` (`RecordVerificationStatus` enum: `pending`, `verified`, `rejected`, `expired`), `recordVerificationDeadline` (Timestamp), `isRecordVerified` (bool), `verificationVotes` (Map<String, String> типу `userId: voteTypeString`), `votedAndRewardedUserIds` (List<String>).
    *   **`Comment` (`lib/core/domain/entities/comment.dart`):** `id`, `postId`, `userId`, `authorUsername`, `authorProfilePicUrl`, `text`, `timestamp`.
    *   **`VoteType` (`lib/core/domain/entities/vote_type.dart`):** enum `verify`, `dispute`.

*   **Репозиторії:**
    *   **`PostRepository` (`lib/core/domain/repositories/post_repository.dart`):** Інтерфейс для операцій з постами, лайками, коментарями, голосами.
    *   **`PostRepositoryImpl` (`lib/features/social/data/repositories/post_repository_impl.dart`):** Реалізація з Firestore.
        *   `createPost`, `getAllPostsStream`, `getPostById`, `getPostStreamById`.
        *   `updatePostSettings` (для `isCommentsEnabled`).
        *   `addLike`, `removeLike`.
        *   `addComment`, `getCommentsStream`, `updateComment`, `deleteComment`.
        *   `castVote`, `retractVote` для заявок на рекорд.
    *   **`UserProfileRepository` (оновлено в `lib/features/profile_setup/data/repositories/user_profile_repository_impl.dart`):**
        *   Методи `followUser(currentUserId, targetUserId)` та `unfollowUser(currentUserId, targetUserId)`: оновлюють список `following` у поточного користувача.
        *   Методи `getFollowingList(userId)` та `getFollowersList(userId)` для отримання списків користувачів (з пагінацією).

*   **Кубіти:**
    *   **`CreatePostCubit` (`lib/features/social/presentation/cubit/create_post_cubit.dart`):**
        *   Керує станом створення поста.
        *   Метод `submitPost` приймає `textContent`, `mediaUrl`, `type`, `isCommentsEnabled`, `routineSnapshot`, `relatedRoutineId`, `recordDetails`.
        *   Отримує профіль користувача для заповнення даних автора.
    *   **`ExploreFeedCubit` (`lib/features/social/presentation/cubit/explore_feed_cubit.dart`):**
        *   Завантажує стрічку постів (`_postRepository.getAllPostsStream()`).
    *   **`PostInteractionCubit` (`lib/features/social/presentation/cubit/post_interaction_cubit.dart`):**
        *   Керує станом одного поста (лайки, коментарі, налаштування, статус голосування).
        *   Методи: `toggleLike()`, `castVote(VoteType)`, `addComment()`, `fetchComments()`, `updateComment()`, `deleteComment()`, `toggleCommentsEnabled()`.
    *   **`UserInteractionCubit` (`lib/features/social/presentation/cubit/user_interaction_cubit.dart`):**
        *   Керує станом взаємодії з профілем іншого користувача (зокрема, підпискою).
        *   Метод `toggleFollow()` для підписки/відписки.
        *   Використовує `UserProfileRepository` для виконання дій та отримання оновлень.
    *   **`FollowListCubit` (`lib/features/social/presentation/cubit/follow_list_cubit.dart`):**
        *   Керує завантаженням та відображенням списків підписників/підписок з пагінацією.
        *   Використовує `UserProfileRepository.getFollowersList` або `getFollowingList`.

*   **Екрани та Віджети:**
    *   **`ExploreScreen` (`lib/features/social/presentation/screens/explore_screen.dart`):**
        *   Основна стрічка постів на вкладці "Explore". FAB для створення нового поста.
    *   **`CreatePostScreen` (`lib/features/social/presentation/screens/create_post_screen.dart`):**
        *   UI для створення постів.
        *   **Вибір типу поста:** `SegmentedButton` для `standard`, `routineShare`, `recordClaim`.
        *   **Routine Share:** Якщо `routineToShare` передано, поля заповнюються. Інакше, UI для вибору рутини (перехід на `UserRoutinesScreen` в режимі вибору).
        *   **Record Claim:** Поля для вибору вправи (через `ExerciseExplorerScreen`), ваги, повторень, URL відео.
        *   Перемикач `isCommentsEnabled`.
    *   **`PostListItem` (`lib/features/social/presentation/widgets/post_list_item.dart`):**
        *   Відображає окремий пост. Клікабельний для переходу на `PostDetailScreen`.
        *   Аватар та ім'я автора клікабельні для переходу на `ViewUserProfileScreen` (якщо це не власний профіль).
        *   **`PostCardContentWidget` (`lib/features/social/presentation/widgets/post_card_content_widget.dart`):** Динамічно відображає вміст картки залежно від `post.type`:
            *   `standard`: текст, медіа (в майбутньому).
            *   `routineShare`: деталі рутини, кнопка "Add to My Routines". При натисканні викликає `_addRoutineToMyRoutines`, яка використовує `RoutineRepository.copyRoutineFromSnapshot`.
            *   `recordClaim`: деталі рекорду, статус верифікації (`_getRecordStatusText`, `_getRecordStatusColor`), `VoteProgressBarWidget`. Якщо `isDetailedView == true` (на `PostDetailScreen`) та голосування активне, відображає кнопки "Validate"/"Dispute".
        *   Кнопки лайка та лічильник коментарів.
    *   **`PostDetailScreen` (`lib/features/social/presentation/screens/post_detail_screen.dart`):**
        *   Повний пост, список коментарів (`CommentListItem`).
        *   Форма для додавання коментаря.
        *   Автор поста може вмикати/вимикати коментарі.
        *   Автори коментарів можуть редагувати/видаляти власні коментарі.
        *   Для постів `recordClaim`: відображає кнопки голосування, якщо користувач може голосувати.
    *   **`ViewUserProfileScreen` (`lib/features/social/presentation/screens/view_user_profile_screen.dart`):**
        *   Відображає профіль іншого користувача.
        *   Кнопка "Follow"/"Unfollow", керована `UserInteractionCubit`.
        *   Посилання на списки підписників/підписок, що ведуть на `FollowListScreen`.
    *   **`FollowListScreen` (`lib/features/social/presentation/screens/follow_list_screen.dart`):**
        *   Відображає список підписників або тих, на кого підписаний користувач.
        *   Використовує `FollowListCubit` та `FollowListItemWidget`.

*   **Firebase Cloud Functions для Соціальних Функцій:**
    *   `onCommentCreated`, `onCommentDeleted`: Оновлюють `commentsCount` та `updatedAt` на батьківському пості.
    *   `onRecordClaimPostCreated`: Встановлює `recordVerificationDeadline`, `recordVerificationStatus` на `PENDING`.
    *   `onRecordClaimVoteCasted`: Нараховує XP за голосування (`XP_FOR_VOTING`), якщо користувач ще не голосував/не був нагороджений за цей пост (перевіряє `votedAndRewardedUserIds`).
    *   `processRecordClaimDeadlines` (запланована): Обробляє заявки на рекорд, що пройшли дедлайн. Визначає результат голосування (на основі `MIN_VOTE_PERCENTAGE_FOR_VERIFICATION`), оновлює `recordVerificationStatus`, `isRecordVerified`. Якщо верифіковано, нараховує XP (`XP_FOR_RECORD_BASE` + бонус) та видає досягнення `personalRecordSet`.
    *   `handleUserFollowListUpdate` (тригер `onDocumentWritten` на `users/{userId}`):
        *   Спрацьовує при зміні списку `following` користувача.
        *   Якщо користувач А підписався на Б:
            *   Збільшує `followersCount` у Б.
            *   Надсилає сповіщення типу `newFollower` користувачеві Б.
        *   Якщо користувач А відписався від Б:
            *   Зменшує `followersCount` у Б.
        *   Оновлює `followingCount` у користувача А.
        *   Оновлює `updatedAt` для обох профілів.

### 7.4. Система Сповіщень

*   **`AppNotification` (`lib/core/domain/entities/app_notification.dart`):**
    *   Структура: `id`, `type` (`NotificationType`), `title`, `message`, `timestamp`, `isRead`, `relatedEntityId`, `relatedEntityType`, `iconName`.
    *   **Додано поля для `newFollower`:** `senderProfilePicUrl`, `senderUsername`.
*   **`NotificationType` enum:** Включає `achievementUnlocked`, `workoutReminder`, `newFollower`, `routineShared`, `systemMessage`, `advice`, `custom`.
*   **`NotificationRepository` та `NotificationRepositoryImpl`:** CRUD для сповіщень в `users/{userId}/notifications`. Включає `deleteNotification`.
*   **`NotificationsCubit` (`lib/features/notifications/presentation/cubit/notifications_cubit.dart`):**
    *   Керує списком сповіщень, лічильником непрочитаних.
    *   Надає потоки для спливаючих сповіщень в додатку для досягнень (`achievementAlertStream`) та порад (`adviceAlertStream`). Використовує `_alerted...Ids` для уникнення повторних показів.
*   **UI:** `NotificationListItem`, `NotificationDetailScreen`. Можливість "Mark all as read", видалення окремих сповіщень.

### 7.5. Бібліотека Вправ

*   **`PredefinedExercise` (`lib/core/domain/entities/predefined_exercise.dart`):** Стандартизовані дані (назва, групи м'язів, обладнання, опис, відео, складність, теги).
*   **`PredefinedExerciseRepository` та `PredefinedExerciseRepositoryImpl`:** Отримує дані з колекції `predefinedExercises`.
*   **Firebase Function `seedPredefinedExercises`:** HTTPS-тригер для наповнення бази.
*   **`ExerciseExplorerScreen` (`lib/features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart`):**
    *   Браузер вправ. Використовується в режимі вибору для додавання до рутин або для "Record Claim". `ExerciseExplorerCubit`.

### 7.6. Управління Тренувальними Рутинами

*   **Сутності (`lib/core/domain/entities/routine.dart`):**
    *   `UserRoutine`: Назва, опис, список `RoutineExercise`, розклад, `isPublic`.
    *   `RoutineExercise`: `predefinedExerciseId`, `exerciseNameSnapshot`, `numberOfSets`, `notes`.
*   **`RoutineRepository` та `RoutineRepositoryImpl`:** CRUD для `userRoutines`. Метод `copyRoutineFromSnapshot` для копіювання спільних рутин.
*   **Кубіти:** `UserRoutinesCubit` (список рутин), `ManageRoutineCubit` (створення/редагування).
*   **UI:** `UserRoutinesScreen`, `CreateEditRoutineScreen`, `AddExerciseToRoutineDialog`.

### 7.7. Відстеження Тренувань

*   **Сутності:**
    *   `WorkoutSession`: `routineId`, час, тривалість, список `LoggedExercise`, нотатки, статус, `totalVolume`.
    *   `LoggedExercise`: `exerciseNameSnapshot`, `targetSets`, список `LoggedSet`.
    *   `LoggedSet`: `setNumber`, `weightKg`, `reps`, `isCompleted`, `notes` (для RPE).
*   **`WorkoutLogRepository` та `WorkoutLogRepositoryImpl`:** Керує даними в `users/{userId}/workoutLogs`.
*   **`ActiveWorkoutCubit` (`lib/features/workout_tracking/presentation/cubit/active_workout_cubit.dart`):**
    *   Керує поточною сесією.
    *   Логування сетів, ваги, повторень, RPE через `CurrentSetDisplay`.
    *   Обробляє завершення/скасування.
*   **`WorkoutCompleteScreen` (`lib/features/workout_tracking/presentation/screens/workout_complete_screen.dart`):**
    *   Святковий екран з анімацією Lottie (`assets/animations/trophy_animation.json`), ефектом `confetti`.
    *   Зведення тренування, XP, інформація про підвищення рівня (з `UserProfile`, оновленого Firebase Function `calculateAndAwardXpAndStreak`).

### 7.8. Відстеження Прогресу

*   **`ProgressCubit` (`lib/features/progress/presentation/cubit/progress_cubit.dart`):**
    *   Збирає дані для `ProgressScreen`.
    *   Отримує дані про ліги (`LeagueRepository`), профіль користувача, історію тренувань.
*   **Система Ліг:**
    *   `LeagueInfo` (`lib/core/domain/entities/league_info.dart`): Назва, рівні, XP, кольори градієнту. Колекція `leagues`.
    *   `LeagueTitleWidget`.
*   **XP та Рівні:**
    *   `XPProgressBarWidget` з анімацією заповнення.
*   **Карта М'язів (`MuscleMapWidget`):**
    *   Візуалізація об'єму тренувань (кількість сетів) на SVG м'язів (чоловіча/жіноча версії з `assets/images/`). Інтенсивність кольору залежить від даних за останні 7 днів.
*   **Статистика Тренувань:**
    *   Тренди RPE та Робочої Ваги для кожної вправи за останні N=15 тренувань (відображення через `ValueSparkline`).

### 7.9. Система Досягнень

*   **`AchievementId` enum та `Achievement` (`lib/core/domain/entities/achievement.dart`):** ID, назва, опис, іконка. `isPersonalized` для динамічних назв/описів (наприклад, "NEW RECORD: [Exercise Name]!").
*   **Логіка Нагородження:** Firebase Cloud Functions (`checkProfileSetupCompletionAchievements`, `calculateAndAwardXpAndStreak`, `processRecordClaimDeadlines`).
*   **Відображення:** На `ProfileScreen`.
*   **Реалізовані:** "Early Bird", "First Workout", "Personal Record Set".

### 7.10. Деталі UI/UX та Загальні Віджети

*   **Анімований Фон:** `LavaLampBackground` (`lib/widgets/lava_lamp_background.dart`) на `LoginPage`.
*   **Тема Додатку (`lib/main.dart`):**
    *   Визначено `ThemeData` з основною палітрою кольорів (`primaryOrange = Color(0xFFED5D1A)`), шрифтами (`Inter`, `IBMPlexMono`).
    *   Налаштування для `AppBar`, `BottomNavigationBar`, `Card`, `ElevatedButton`, `InputDecorationTheme` тощо для узгодженого вигляду.
*   **RPE Слайдери:** Унікальний UI елемент в `CurrentSetDisplay` для детального логування зусиль кожного повторення.
*   **Святкові Анімації:** `Confetti` та `Lottie` на `WorkoutCompleteScreen`.

## 8. Бекенд: Структура Firebase Cloud Firestore

*   **`users/{userId}`:** Профіль користувача (`UserProfile`).
    *   `uid`, `email`, `displayName`, `username`, `gender`, `dateOfBirth`, `heightCm`, `weightKg`, `fitnessGoal`, `activityLevel`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastWorkoutTimestamp`, `lastScheduledWorkoutCompletionTimestamp`, `lastScheduledWorkoutDayKey`, `profileSetupComplete`, `createdAt`, `updatedAt`.
    *   **Нові/Оновлені поля:** `followersCount` (int), `followingCount` (int), `following` (List<String> ID користувачів, на яких підписаний).
    *   **Підколекція `notifications/{notificationId}`:** Сповіщення (`AppNotification`).
    *   **Підколекція `workoutLogs/{sessionId}`:** Логи тренувань (`WorkoutSession`).

*   **`predefinedExercises/{exerciseId}`:** Бібліотека вправ (`PredefinedExercise`).

*   **`userRoutines/{routineId}`:** Рутини користувачів (`UserRoutine`).

*   **`leagues/{leagueId}`:** Інформація про ліги (`LeagueInfo`).

*   **`posts/{postId}`:** Соціальні пости (`Post`).
    *   `userId`, `authorUsername`, `authorProfilePicUrl`, `timestamp`, `updatedAt`, `type` (`standard`, `recordClaim`, `routineShare`), `textContent`, `mediaUrl`.
    *   `likedBy` (List<String>), `commentsCount` (int), `isCommentsEnabled` (bool).
    *   **`routineShare` specific**: `relatedRoutineId`, `routineSnapshot`.
    *   **`recordClaim` specific**: `recordDetails` (Map), `recordVerificationStatus` (String), `recordVerificationDeadline` (Timestamp), `isRecordVerified` (bool), `verificationVotes` (Map<String, String>), `votedAndRewardedUserIds` (List<String>).
    *   **Підколекція `comments/{commentId}`:** Коментарі до постів (`Comment`).

## 9. Логіка Firebase Cloud Functions (`functions/src/index.ts`)

Firebase Cloud Functions, написані на TypeScript (Node.js v20), обробляють серверну логіку. Регіон за замовчуванням: `us-central1`.

*   **`createUserProfile`** (Auth Trigger - `v1.auth.user().onCreate()`):
    *   Створює документ в `users` при реєстрації нового користувача. Ініціалізує профіль з `profileSetupComplete: false` та іншими полями за замовчуванням.

*   **`calculateAndAwardXpAndStreak`** (Firestore Trigger - `v2.firestore.onDocumentUpdated("users/{userId}/workoutLogs/{sessionId}")`):
    *   Спрацьовує при оновленні логу тренування, коли `status` стає `completed`.
    *   Розраховує XP (50-200) на основі тривалості та об'єму.
    *   Оновлює `xp`, `level`, `lastWorkoutTimestamp`.
    *   Розраховує та оновлює `currentStreak` та `longestStreak` на основі запланованих днів рутини.
    *   Нагороджує досягненням "First Workout" та надсилає сповіщення.

*   **`checkProfileSetupCompletionAchievements`** (Firestore Trigger - `v2.firestore.onDocumentWritten("users/{userId}")`):
    *   Спрацьовує при записі в профіль користувача.
    *   Якщо `profileSetupComplete` змінюється на `true`, нагороджує досягненням "Early Bird" та надсилає сповіщення.

*   **`seedPredefinedExercises`** (HTTPS Trigger - `v1.https.onCall` або `onRequest`):
    *   Для початкового наповнення колекції `predefinedExercises` даними (використовується переважно для розробки).

*   **`onCommentCreated`** (Firestore Trigger - `v2.firestore.onDocumentCreated("posts/{postId}/comments/{commentId}")`):
    *   Збільшує `commentsCount` та оновлює `updatedAt` на батьківському пості.

*   **`onCommentDeleted`** (Firestore Trigger - `v2.firestore.onDocumentDeleted("posts/{postId}/comments/{commentId}")`):
    *   Зменшує `commentsCount` та оновлює `updatedAt` на батьківському пості.

*   **`onRecordClaimPostCreated`** (Firestore Trigger - `v2.firestore.onDocumentCreated("posts/{postId}")`):
    *   Якщо `type == "recordClaim"`, встановлює `recordVerificationDeadline` (поточний час + `RECORD_VOTE_DURATION_HOURS` = 24 години) та `recordVerificationStatus = PENDING`.

*   **`onRecordClaimVoteCasted`** (Firestore Trigger - `v2.firestore.onDocumentUpdated("posts/{postId}")`):
    *   Якщо пост `recordClaim` та `status == PENDING`.
    *   Перевіряє зміни в `verificationVotes`.
    *   Якщо виборець ще не був нагороджений за голос по цьому посту (перевірка `votedAndRewardedUserIds`), нараховує `XP_FOR_VOTING` (15 XP) та додає ID користувача до `votedAndRewardedUserIds`. Надсилає сповіщення.

*   **`processRecordClaimDeadlines`** (Scheduled Function - `v2.scheduler.onSchedule("every 1 hours")`):
    *   Запитує пости `recordClaim` зі статусом `PENDING`, де `recordVerificationDeadline` минув.
    *   Підраховує голоси. Якщо співвідношення "verify" >= `MIN_VOTE_PERCENTAGE_FOR_VERIFICATION` (0.55), статус змінюється на `VERIFIED`, `isRecordVerified = true`. Автору нараховується XP (`XP_FOR_RECORD_BASE` + бонус за об'єм, макс. 1500 XP) та досягнення `personalRecordSet`.
    *   Інакше статус `REJECTED` або `EXPIRED` (якщо голосів не було).
    *   Надсилає відповідні сповіщення автору.

*   **`handleUserFollowListUpdate`** (Firestore Trigger - `v2.firestore.onDocumentWritten("users/{userId}")`):
    *   Спрацьовує при зміні документа користувача.
    *   Аналізує зміни в полі `following`.
    *   **При підписці:** Збільшує `followersCount` у цільового користувача (`targetUserId`) та надсилає йому сповіщення типу `newFollower` (з інформацією про того, хто підписався).
    *   **При відписці:** Зменшує `followersCount` у цільового користувача.
    *   Оновлює `followingCount` у поточного користувача (`currentUserId`).
    *   Встановлює `updatedAt` для обох зачеплених профілів.

## 10. Налаштування та Запуск Проєкту

1.  **Flutter SDK:** Переконайтеся, що встановлено Flutter SDK (версія `^3.8.0` або сумісна).
2.  **Firebase Проєкт:**
    *   Створіть проєкт на [console.firebase.google.com](https://console.firebase.google.com/).
    *   Додайте додатки Android/iOS. Завантажте `google-services.json` та `GoogleService-Info.plist`.
    *   Увімкніть Firebase Authentication (Email/Password, Google), Firestore (Native mode), Cloud Functions, Firebase Storage (для майбутніх медіа).
3.  **Firebase CLI:** Встановіть, увійдіть (`firebase login`), налаштуйте для Flutter (`flutterfire configure`). Ініціалізуйте Functions в папці `functions`.
4.  **Залежності:** `flutter pub get` в корені, `npm install` в `functions/`.
5.  **Іконки:** `flutter pub run flutter_launcher_icons`.
6.  **Запуск:** `flutter run`.
7.  **Розгортання Cloud Functions:** `cd functions && npm run build && firebase deploy --only functions`.
8.  **Наповнення `predefinedExercises`:** Викличте функцію `seedPredefinedExercises`.
9.  **Правила Безпеки Firestore:** Налаштуйте правила безпеки в консолі Firebase. Детальні правила наведені в оригінальному `README.md` (секція 9). Ці правила мають забезпечувати:
    *   Приватність даних користувача (`users/{userId}` та підколекції).
    *   Публічне читання/обмежений запис для спільних ресурсів (`predefinedExercises`, `leagues`).
    *   Логіку доступу до рутин (`userRoutines`) – приватні/публічні.
    *   Комплексні правила для постів (`posts`) та коментарів (`posts/{postId}/comments`), що враховують авторство, лайки, голосування, керування коментарями.

## 11. Дорожня Карта та Майбутній Розвиток

Нижче наведено оновлену дорожню карту, що враховує вже реалізовані функції.

**Фаза 1: Базові Пости та Стрічка (Завершено)**
*   [✔️] Модель `Post` та структура Firestore.
*   [✔️] Створення стандартних текстових постів.
*   [✔️] Базовий UI стрічки "Explore".
*   [✔️] Вбудування профілю автора в пости.

**Фаза 2: Взаємодія з Постами - Лайки та Коментарі (Завершено)**
*   [✔️] Система лайків.
*   [✔️] Система коментарів (створення, перегляд, редагування/видалення власних).
*   [✔️] Cloud Functions для `commentsCount`.
*   [✔️] Ввімкнення/вимкнення коментарів автором поста.

**Фаза 3: Розширені Типи Постів (Завершено)**
*   **Пост "Поділитися Рутиною" (`routineShare`):**
    *   [✔️] Оновлена модель `Post`, UI для створення та відображення.
    *   [✔️] Кнопка "Add to My Routines" та логіка копіювання.
*   **Пост "Заявка на Рекорд" (`recordClaim`):**
    *   [✔️] Розширена модель `Post`, UI для створення та відображення.
    *   [✔️] Логіка голосування, зберігання голосів.
    *   [✔️] Cloud Functions: `onRecordClaimPostCreated`, `onRecordClaimVoteCasted`, `processRecordClaimDeadlines`.

**Фаза 4: Основний Соціальний Граф (Частково Реалізовано)**
*   **Підписки Користувачів (Followers/Following):**
    *   [✔️] Оновлена сутність `UserProfile` (`following`, `followersCount`, `followingCount`).
    *   [✔️] `UserProfileRepository` з методами `followUser`, `unfollowUser`, `getFollowersList`, `getFollowingList`.
    *   [✔️] UI для кнопок Follow/Unfollow на `ViewUserProfileScreen`, керований `UserInteractionCubit`.
    *   [✔️] Екран `FollowListScreen` для перегляду списків.
    *   [✔️] Cloud Function `handleUserFollowListUpdate` для оновлення лічильників та надсилання сповіщень.
*   **Персоналізована Стрічка:**
    *   [ ] Логіка для відображення постів переважно від підписаних користувачів (потребує розробки).

**Фаза 5: Покращення та Шліфування (Планується)**
*   **Медіа в Постах:**
    *   [ ] Функціонал завантаження зображень/відео (Firebase Storage).
    *   [ ] UI для додавання/відображення медіа.
*   **Сповіщення для Соціальних Взаємодій:**
    *   [ ] Новий лайк на вашому пості.
    *   [ ] Новий коментар на вашому пості.
    *   (Сповіщення про нового підписника вже є).
*   **Покращення UI/UX для Соціальних Функцій:**
    *   [ ] Меню опцій поста (редагувати/видалити, поскаржитися).
    *   [ ] Фільтрація/сортування в стрічці "Explore".
    *   [ ] Розширення сторінок профілів (стрічка активності).

**Довгострокове Бачення (Поза поточним обсягом):**
*   Прямі повідомлення.
*   Публічні рекорди та таблиці лідерів.
*   Розширена гейміфікація (виклики, сезонні ліги).
*   Push-сповіщення через Firebase Cloud Messaging (FCM).
*   Комплексний набір тестів.
*   Адмін-панель.
*   Інтеграція з носимими пристроями.
*   Офлайн-підтримка.

---