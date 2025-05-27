# MuscleUP: Фітнес-застосунок для справжніх атлетів

**Motto:** Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

## 1. Вступ

**MuscleUP** – це мобільний фітнес-застосунок, розроблений для підвищення мотивації та довгострокової залученості користувачів до тренувального процесу. Застосунок дозволяє відстежувати тренування, встановлювати фітнес-цілі, ділитися прогресом (в майбутньому) та отримувати підтримку від спільноти (в майбутньому).

**Поточний стан (версія 0.1.0):**
На даному етапі реалізовано ключовий функціонал:
*   Автентифікація користувачів (Email/Password та Google Sign-In).
*   Створення та зберігання профілю користувача в Cloud Firestore.
*   Базовий дашборд.
*   Перегляд бібліотеки стандартизованих вправ.
*   Створення, перегляд, редагування та видалення користувацьких тренувальних рутин.
*   Основна навігація за допомогою Bottom Navigation Bar.

## 2. Ключові Архітектурні Принципи

*   **Модульність:** Застосунок розроблено за принципом "feature-first", де кожна функціональна частина є окремим модулем.
*   **Чітке Розділення Відповідальностей:** Використання шарів (Domain, Data, Presentation) в межах кожного модуля.
*   **Управління Станом:** Застосування Flutter BLoC/Cubit для управління станом UI та бізнес-логіки.
*   **Залежності:** Використання `RepositoryProvider` для надання залежностей репозиторіїв віджетам.
*   **Масштабованість:** Архітектура передбачає легке додавання нових функцій та розширення існуючих.

## 3. Технологічний Стек

*   **Фронтенд:**
    *   **Framework:** Flutter (`^3.8.0` Dart SDK, згідно `pubspec.yaml`)
    *   **Мова:** Dart
    *   **Управління станом:** Flutter BLoC/Cubit (`flutter_bloc: ^9.1.1`)
    *   **Порівняння об'єктів:** Equatable (`equatable: ^2.0.5`)
    *   **Анімації:** `animated_background: ^2.0.0` (для сторінки логіну)
    *   **Навігація:** Стандартна Flutter навігація (`MaterialPageRoute`, `Navigator.push/pop`).
*   **Бекенд (Firebase):**
    *   **Firebase Core:** `firebase_core: ^3.13.1`
    *   **Firebase Authentication:** `firebase_auth: ^5.5.4` (Email/Password, Google Sign-In)
    *   **Google Sign-In:** `google_sign_in: ^6.2.1`
    *   **Cloud Firestore:** `cloud_firestore: ^5.6.8` (NoSQL база даних)
    *   **Firebase Storage:** (Планується) для медіафайлів.
    *   **Cloud Functions:** (Планується) для серверної логіки.
*   **Інструменти розробки:**
    *   **Лінтер:** `flutter_lints: ^5.0.0`

## 4. Структура Проєкту (`lib/`)


muscle_up/
├── lib/
│ ├── main.dart # Точка входу, ініціалізація Firebase, MaterialApp, RepositoryProviders
│ ├── auth_gate.dart # Керування потоком автентифікації (логін/головний екран)
│ ├── firebase_options.dart # Конфігурація Firebase (згенеровано)
│ ├── home_page.dart # Головний екран з BottomNavigationBar, що містить вкладки
│ ├── login_page.dart # Екран входу/реєстрації, анімований фон
│ │
│ ├── core/
│ │ └── domain/
│ │ ├── entities/
│ │ │ ├── predefined_exercise.dart # Модель для стандартизованої вправи
│ │ │ └── routine.dart # Моделі UserRoutine та RoutineExercise
│ │ └── repositories/
│ │ ├── predefined_exercise_repository.dart # Абстракція репозиторію вправ
│ │ └── routine_repository.dart # Абстракція репозиторію рутин
│ │
│ └── features/ # Кожен модуль фічі
│ ├── dashboard/
│ │ └── presentation/
│ │ └── screens/
│ │ └── dashboard_screen.dart # UI для вкладки "Dashboard"
│ │
│ ├── exercise_explorer/ # Модуль бібліотеки вправ
│ │ ├── data/
│ │ │ └── repositories/
│ │ │ └── predefined_exercise_repository_impl.dart # Реалізація репозиторію (Firestore)
│ │ └── presentation/
│ │ ├── cubit/
│ │ │ ├── exercise_explorer_cubit.dart
│ │ │ └── exercise_explorer_state.dart
│ │ ├── screens/
│ │ │ └── exercise_explorer_screen.dart # UI для вкладки "Exercises"
│ │ └── widgets/
│ │ └── exercise_list_item.dart # Віджет для елемента списку вправ
│ │
│ └── routines/ # Модуль користувацьких рутин
│ ├── data/
│ │ └── repositories/
│ │ └── routine_repository_impl.dart # Реалізація репозиторію (Firestore)
│ └── presentation/
│ ├── cubit/
│ │ ├── manage_routine_cubit.dart # Cubit для створення/редагування рутини
│ │ ├── manage_routine_state.dart
│ │ ├── user_routines_cubit.dart # Cubit для списку рутин користувача
│ │ └── user_routines_state.dart
│ ├── screens/
│ │ ├── create_edit_routine_screen.dart # UI для створення/редагування рутини
│ │ └── user_routines_screen.dart # UI для вкладки "Routines"
│ └── widgets/
│ ├── add_exercise_to_routine_dialog.dart # Діалог додавання вправи до рутини
│ └── routine_list_item.dart # Віджет для елемента списку рутин
│
├── assets/
│ ├── images/
│ │ └── google_logo.png # Логотип Google
│ └── fonts/
│ └── Inter_...ttf # Файли шрифтів Inter
│
├── android/ # Специфічний код для Android
├── ios/ # Специфічний код для iOS
└── web/ # Специфічний код для Web (базовий шаблон)

## 5. Детальний Опис Ключових Компонентів

### 5.1. Автентифікація та Управління Користувачем

*   **`main.dart`**: Ініціалізує Firebase. Надає `PredefinedExerciseRepository` та `RoutineRepository` через `MultiRepositoryProvider`. Визначає `MaterialApp` з глобальною темою та шрифтом 'Inter'.
*   **`AuthGate` (`auth_gate.dart`)**: Використовує `StreamBuilder` для `FirebaseAuth.instance.authStateChanges()`. Перенаправляє на `HomePage` (якщо користувач увійшов) або `LoginPage`.
*   **`LoginPage` (`login_page.dart`)**:
    *   UI для входу та реєстрації з анімованим градієнтним фоном (`AnimationController`, `AlignmentTween`).
    *   Форма з валідацією для email/password.
    *   Логіка для `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`.
    *   Логіка для `signInWithCredential` (Google Sign-In).
    *   **`_createInitialUserProfile(User user)`**: Після успішної першої реєстрації (email або Google) створює документ для користувача в колекції `users` Firestore. Поля: `uid`, `email`, `displayName`, `profilePictureUrl` (з `User` об'єкта), `username: null`, `xp: 0`, `level: 1`, `profileSetupComplete: false`, `createdAt`, `updatedAt` (через `FieldValue.serverTimestamp()`) та інші поля за замовчуванням.
*   **`HomePage` (`home_page.dart`)**:
    *   `StatefulWidget` з `BottomNavigationBar` для перемикання між вкладками (`DashboardScreen`, `ExerciseExplorerScreen`, `UserRoutinesScreen`).
    *   Використовує `IndexedStack` для збереження стану вкладок.
    *   Містить кнопку виходу (`FirebaseAuth.instance.signOut()`).

### 5.2. Модуль "Exercise Explorer" (`features/exercise_explorer/`)

*   **Сутності (`core/domain/entities/predefined_exercise.dart`)**:
    *   `PredefinedExercise`: Модель даних для вправи (id, name, primaryMuscleGroup, etc.). Має `fromFirestore()` та `toJson()`.
*   **Репозиторії**:
    *   Абстракція: `core/domain/repositories/predefined_exercise_repository.dart`.
    *   Реалізація: `features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart`. Отримує дані з колекції `predefinedExercises` Firestore, сортує за назвою.
*   **Cubit (`features/exercise_explorer/presentation/cubit/`)**:
    *   `ExerciseExplorerCubit`: Завантажує список вправ через репозиторій.
    *   `ExerciseExplorerState`: Стани (Initial, Loading, Loaded, Error).
*   **UI (`features/exercise_explorer/presentation/screens/`)**:
    *   `ExerciseExplorerScreen`: Відображає список вправ. Використовує `BlocProvider` для `ExerciseExplorerCubit` та `BlocBuilder`. Може працювати в режимі вибору вправи (`isSelectionMode`).
    *   `ExerciseListItem` (віджет): Відображає одну вправу. При `isSelectionMode = true` повертає обрану вправу через `Navigator.pop()`.

### 5.3. Модуль "Routines" (`features/routines/`)

*   **Сутності (`core/domain/entities/routine.dart`)**:
    *   `RoutineExercise`: Модель для вправи всередині рутини (ID predefined вправи, назва-знімок, кількість підходів, нотатки). Має `fromMap()`, `toMap()`, `copyWith()`.
    *   `UserRoutine`: Модель для користувацької рутини (id, userId, name, description, список `RoutineExercise`, дні тижня, isPublic, createdAt, updatedAt). Має `fromFirestore()`, `toMap()`, `copyWith()`.
*   **Репозиторії**:
    *   Абстракція: `core/domain/repositories/routine_repository.dart`.
    *   Реалізація: `features/routines/data/repositories/routine_repository_impl.dart`. CRUD операції для `userRoutines` в Firestore. Всі операції враховують `userId` поточного користувача. `createdAt` та `updatedAt` встановлюються через `FieldValue.serverTimestamp()`.
*   **Cubits (`features/routines/presentation/cubit/`)**:
    *   `UserRoutinesCubit`: Завантажує список рутин поточного користувача. Має методи `routineDeleted()` та `routineAddedOrUpdated()` для локального оновлення списку.
    *   `UserRoutinesState`: Стани (Initial, Loading, Loaded, Error).
    *   `ManageRoutineCubit`: Управляє створенням та редагуванням однієї рутини. Зберігає внутрішній стан `_currentRoutine`. Методи для оновлення полів рутини, додавання/оновлення/видалення вправ. Метод `saveRoutine()` (викликає `createRoutine` або `updateRoutine` репозиторію) та `deleteRoutine()`.
    *   `ManageRoutineState`: Стани (Initial, Loading, Success, Failure, ExercisesUpdated).
*   **UI (`features/routines/presentation/screens/` та `widgets/`)**:
    *   `UserRoutinesScreen`: Відображає список рутин користувача. Використовує `BlocProvider` для `UserRoutinesCubit` та `BlocConsumer`. Має FAB для переходу на `CreateEditRoutineScreen`.
    *   `RoutineListItem` (віджет): Відображає одну рутину. Надає опції редагування/видалення через `PopupMenuButton`.
    *   `CreateEditRoutineScreen`: Форма для створення/редагування рутини. Використовує `BlocProvider.value` для `ManageRoutineCubit`. Містить поля для назви, опису, вибору днів тижня. Дозволяє додавати, редагувати та видаляти вправи з рутини.
    *   `AddExerciseToRoutineDialog` (віджет-діалог): Використовує `ExerciseExplorerScreen` в режимі `isSelectionMode` для вибору predefined вправи, потім запитує кількість підходів та нотатки.

## 6. Структура Бекенду (Firebase)

### 6.1. Firebase Authentication
*   Управління користувачами (Email/Password, Google Sign-In).
*   UID користувача є ключем для документів у колекції `users`.

### 6.2. Cloud Firestore

*   **`users`**:
    *   ID Документа: `userId` (Firebase Auth UID).
    *   Поля: `uid`, `email`, `displayName`, `profilePictureUrl`, `username`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastWorkoutTimestamp`, `scheduledWorkoutDays`, `preferredUnits`, `currentLeagueId`, `city`, `country`, `isProfilePublic`, `fcmTokens`, `appSettings`, `initialFitnessLevel`, `profileSetupComplete` (boolean), `createdAt` (Timestamp), `updatedAt` (Timestamp).
*   **`predefinedExercises`**:
    *   ID Документа: Автогенерований.
    *   Поля: `name`, `normalizedName`, `primaryMuscleGroup`, `secondaryMuscleGroups`, `equipmentNeeded`, `description`, `videoDemonstrationUrl`, `difficultyLevel`, `tags`.
*   **`userRoutines`**:
    *   ID Документа: Автогенерований.
    *   Поля: `userId` (String), `name` (String), `description` (String?), `exercises` (List of Maps: `predefinedExerciseId`, `exerciseNameSnapshot`, `numberOfSets`, `notes`), `scheduledDays` (List of Strings), `isPublic` (boolean), `createdAt` (Timestamp), `updatedAt` (Timestamp).

### 6.3. Firebase Storage (Планується)
*   `profile_pictures/{userId}/<filename>`
*   Інші шляхи для медіа.

### 6.4. Firebase Cloud Functions (Планується)
*   Автоматичні обчислення, тригери, заплановані завдання, push-сповіщення.

## 7. Налаштування та Запуск Проєкту

1.  **Передумови**:
    *   Встановлений Flutter SDK (версія, сумісна з `^3.8.0` Dart SDK).
    *   Налаштоване середовище розробки (Android Studio / VS Code).
    *   Firebase CLI встановлено та налаштовано (`firebase login`).
2.  **Клонування Репозиторію** (якщо проєкт у Git):
    ```bash
    git clone <URL_РЕПОЗИТОРІЮ>
    cd muscle_up
    ```
3.  **Налаштування Firebase**:
    *   Переконайтеся, що ви увійшли в Firebase CLI та обрали правильний проєкт.
    *   Запустіть `flutterfire configure` для генерації `lib/firebase_options.dart` та оновлення нативних файлів конфігурації (якщо потрібно).
    *   Для Android: файл `android/app/google-services.json` повинен існувати та бути актуальним.
    *   Для iOS: файл `ios/Runner/GoogleService-Info.plist` (якщо вже додано) повинен бути актуальним. Додайте його до Xcode проєкту.
4.  **Налаштування Google Sign-In**:
    *   **Android**:
        *   Додайте SHA-1 відбитки (debug/release) до налаштувань Android-застосунку в Firebase Console.
        *   `google-services.json` має містити OAuth client ID типу 3.
    *   **iOS**: (Якщо планується)
        *   Додайте URL Scheme до `ios/Runner/Info.plist` (зазвичай `REVERSED_CLIENT_ID` з `GoogleService-Info.plist`).
5.  **Встановлення Залежностей**:
    ```bash
    flutter pub get
    ```
6.  **Запуск Застосунку**:
    *   Оберіть цільовий пристрій/емулятор.
    *   Виконайте:
        ```bash
        flutter run
        ```

## 8. Подальший Розвиток

*   **Логування Тренувань:** Реалізація запису виконаних сетів, повторень, ваги.
*   **Розширений Дашборд:** Відображення статистики, прогресу, активності.
*   **Гейміфікація:** Повноцінна система XP, рівнів, досягнень, стріків.
*   **Соціальні Функції:** Стрічка активності, підписки, коментарі, публічні рекорди.
*   **Цілі:** Створення та відстеження персоналізованих фітнес-цілей.
*   **Профіль Користувача:** Завершення налаштування профілю (`profileSetupComplete`), редагування.
*   **Firebase Storage:** Інтеграція для завантаження зображень профілю.
*   **Cloud Functions:** Розробка функцій для фонових задач.
*   **Тестування:** Написання unit, widget та integration тестів.
*   **Покращення UI/UX:** Подальше вдосконалення дизайну та користувацького досвіду.