# MuscleUP: Фітнес-застосунок для справжніх атлетів

**Motto:** Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

## 1. Вступ

**MuscleUP** – це мобільний фітнес-застосунок, розроблений для розв'язання поширеної проблеми відтоку користувачів у фітнес-додатках. Наша мета – сприяти довгостроковій залученості шляхом створення високомотивуючого, соціально інтерактивного та гейміфікованого середовища. MuscleUP дає змогу користувачам ретельно відстежувати свої тренування, встановлювати та досягати персоналізованих фітнес-цілей, ділитися своїм шляхом та черпати натхнення від спільноти, що підтримує.

Цей документ описує поточну реалізацію бізнес-логіки, архітектуру програмного забезпечення та дизайн бекенду з акцентом на модульність, масштабованість та легкість супроводу. Проєкт розробляється як дипломна робота і є основою для майбутнього повноцінного продукту, як описано в [MuscleUP: Application Design Document (Version 2.0 - Product Focused)](./MuscleUP_Application_Design_Document_v2.txt) (припустимо, що цей файл лежить поруч).

**Поточний стан:** Реалізовано ядро автентифікації (Email/Password, Google Sign-In), створення профілю користувача в Firestore, а також базовий функціонал для перегляду бібліотеки вправ та створення/управління користувацькими тренувальними рутинами.

## 2. Ключові Архітектурні Принципи

Дизайн MuscleUP керується наступними принципами (детальніше в дизайн-документі):

*   **Модульність:** Функції розробляються як слабозв'язані модулі.
*   **Масштабованість:** Фронтенд та бекенд розраховані на зростання.
*   **Легкість супроводу:** Чітке розділення відповідальностей, послідовні патерни кодування.
*   **Розширюваність:** Система спроєктована для легкого додавання нових функцій.
*   **Рішення на основі даних:** Дизайн сприяє збору аналітики (в майбутньому).

## 3. Технологічний Стек

*   **Фронтенд:**
    *   **Framework:** Flutter (версія SDK, як у `pubspec.yaml`)
    *   **Мова:** Dart (версія SDK, як у `pubspec.yaml`)
    *   **Управління станом:** Flutter BLoC/Cubit (використовується в реалізованих модулях `exercise_explorer` та `routines`)
    *   **Навігація:** Стандартна Flutter навігація (в майбутньому планується перехід на GoRouter або AutoRoute).
    *   **Залежності (ключові):**
        *   `firebase_core`: Базовий пакет Firebase.
        *   `firebase_auth`: Автентифікація Firebase.
        *   `google_sign_in`: Автентифікація через Google.
        *   `cloud_firestore`: База даних Firestore.
        *   `flutter_bloc`: Для реалізації BLoC/Cubit.
        *   `equatable`: Для порівняння об'єктів у станах BLoC/Cubit.
        *   `animated_background`: Для анімації фону на сторінці логіну.
        *   `flutter_lints`: Для аналізу коду.
*   **Бекенд:**
    *   **Firebase:**
        *   **Authentication:** Для управління користувачами.
        *   **Cloud Firestore:** NoSQL база даних для зберігання даних застосунку.
        *   **Firebase Storage:** (Планується) для зберігання медіафайлів (аватари, докази рекордів).
        *   **Cloud Functions:** (Планується) для серверної логіки, автоматизації, тригерів.

## 4. Файлова Структура Проєкту (`lib/`)

Проєкт дотримується модульної, feature-first архітектури, що сприяє розділенню відповідальностей та масштабованості.


muscle_up/
├── lib/
│ ├── main.dart # Точка входу в застосунок, ініціалізація Firebase
│ ├── auth_gate.dart # Віджет для управління станом автентифікації (перенаправлення)
│ ├── firebase_options.dart # Конфігураційні дані Firebase (згенеровано FlutterFire CLI)
│ │
│ ├── home_page.dart # Тимчасова домашня сторінка після логіну
│ ├── login_page.dart # UI та логіка для екрану входу/реєстрації
│ │
│ ├── app_config/ # (Планується) Базове налаштування застосунку
│ │ ├── app_widget.dart # (Планується) Кореневий MaterialApp
│ │ ├── di_container.dart # (Планується) Налаштування Dependency Injection (напр. GetIt)
│ │ ├── navigation/ # (Планується) Централізована навігація
│ │ └── theme/ # (Планується) Глобальні теми, кольори, шрифти
│ │
│ ├── core/ # Спільна бізнес-логіка, моделі, інтерфейси
│ │ ├── common/ # (Планується) Базові класи, винятки, типи результатів
│ │ ├── domain/
│ │ │ ├── entities/ # Об'єкти предметної області (POJO/PODO)
│ │ │ │ ├── predefined_exercise.dart # Модель для стандартизованої вправи
│ │ │ │ └── routine.dart # Моделі UserRoutine та RoutineExercise
│ │ │ └── repositories/ # Абстрактні інтерфейси для операцій з даними
│ │ │ ├── predefined_exercise_repository.dart # Інтерфейс для predefinedExercises
│ │ │ └── routine_repository.dart # Інтерфейс для userRoutines
│ │ └── enums/ # (Планується) Глобальні enum'и
│ │
│ ├── features/ # Кожен модуль фічі
│ │ ├── auth/ # (Неявно реалізовано в login_page.dart, auth_gate.dart)
│ │ │ ├── presentation/
│ │ │ │ ├── screens/ # login_page.dart, home_page.dart (поточна)
│ │ │
│ │ ├── exercise_explorer/ # Модуль для перегляду бібліотеки вправ
│ │ │ ├── data/
│ │ │ │ └── repositories/
│ │ │ │ └── predefined_exercise_repository_impl.dart # Реалізація репозиторію
│ │ │ ├── presentation/
│ │ │ │ ├── cubit/
│ │ │ │ │ ├── exercise_explorer_cubit.dart # Логіка стану для списку вправ
│ │ │ │ │ └── exercise_explorer_state.dart # Стани для ExerciseExplorerCubit
│ │ │ │ ├── screens/
│ │ │ │ │ └── exercise_explorer_screen.dart # UI для відображення списку вправ
│ │ │ │ └── widgets/
│ │ │ │ └── exercise_list_item.dart # Віджет для одного елемента списку вправ
│ │ │
│ │ ├── routines/ # Модуль для управління користувацькими рутинами
│ │ │ ├── data/
│ │ │ │ └── repositories/
│ │ │ │ └── routine_repository_impl.dart # Реалізація репозиторію рутин
│ │ │ ├── presentation/
│ │ │ │ ├── cubit/
│ │ │ │ │ ├── user_routines_cubit.dart # Логіка стану для списку рутин користувача
│ │ │ │ │ ├── user_routines_state.dart # Стани для UserRoutinesCubit
│ │ │ │ │ ├── manage_routine_cubit.dart # Логіка стану для створення/редагування рутини
│ │ │ │ │ └── manage_routine_state.dart # Стани для ManageRoutineCubit
│ │ │ │ ├── screens/
│ │ │ │ │ ├── user_routines_screen.dart # UI для списку рутин користувача
│ │ │ │ │ └── create_edit_routine_screen.dart # UI для створення/редагування рутини
│ │ │ │ └── widgets/
│ │ │ │ ├── routine_list_item.dart # Віджет для одного елемента списку рутин
│ │ │ │ └── add_exercise_to_routine_dialog.dart # (Планується) Діалог/екран для додавання вправ до рутини
│ │ │
│ │ ├── onboarding/ # (Планується) Модуль онбордингу
│ │ ├── dashboard/ # (Планується) Головний екран застосунку
│ │ └── ... # Інші майбутні фічі
│ │
│ ├── data_sources/ # (Планується) Спільні реалізації джерел даних
│ │ ├── firebase/
│ │ │ ├── firestore_service.dart # (Планується) Огортка для Firestore
│ │
│ └── presentation_common/ # (Планується) Спільні віджети та UI-утиліти
│ └── widgets/
│
├── assets/
│ ├── images/
│ │ └── google_logo.png # Логотип Google для кнопки
│ └── fonts/
│ └── Inter_...ttf # Файли шрифтів Inter
│
├── android/ # Специфічний код та конфігурація для Android
├── ios/ # Специфічний код та конфігурація для iOS
├── web/ # Специфічний код та конфігурація для Web
└── ... # Інші файли та папки проєкту

## 5. Детальний Опис Ключових Компонентів та Логіки

### 5.1. Автентифікація та Управління Користувачем

*   **`main.dart`**:
    *   **Призначення**: Головний файл, точка входу в застосунок.
    *   **Логіка**: Ініціалізує Firebase (`Firebase.initializeApp`) перед запуском будь-яких віджетів. Створює екземпляр `MainApp`.
*   **`MainApp` (у `main.dart`)**:
    *   **Призначення**: Кореневий віджет застосунку.
    *   **Логіка**: `StatelessWidget`, який повертає `MaterialApp`. Встановлює базову тему, глобальні стилі для полів вводу та кнопок. В якості `home` використовує `AuthGate`.
*   **`auth_gate.dart`**:
    *   **Призначення**: Керує потоком автентифікації.
    *   **Логіка**: Використовує `StreamBuilder` для прослуховування змін стану автентифікації (`FirebaseAuth.instance.authStateChanges()`).
        *   Якщо з'єднання в очікуванні (`ConnectionState.waiting`), показує `CircularProgressIndicator`.
        *   Якщо користувач автентифікований (`snapshot.hasData`), перенаправляє на `HomePage`.
        *   Якщо користувач не автентифікований, перенаправляє на `LoginPage`.
*   **`login_page.dart`**:
    *   **Призначення**: Екран для входу та реєстрації користувача.
    *   **Логіка**:
        *   Використовує `StatefulWidget` та `GlobalKey<FormState>` для валідації форм.
        *   Має контролери `_emailController` та `_passwordController`.
        *   Змінна `_isLogin` перемикає режим між входом та реєстрацією.
        *   **Анімація фону**: Використовує `AnimationController` та `AlignmentTween` для створення динамічного градієнтного фону.
        *   **`_submitForm()`**:
            *   Валідує форму.
            *   Якщо `_isLogin` = `true`, викликає `FirebaseAuth.instance.signInWithEmailAndPassword()`.
            *   Якщо `_isLogin` = `false`, викликає `FirebaseAuth.instance.createUserWithEmailAndPassword()`. Після успішної реєстрації викликає `_createInitialUserProfile()` для нового користувача.
        *   **`_signInWithGoogle()`**:
            *   Використовує плагін `google_sign_in` для отримання облікових даних Google.
            *   Створює `AuthCredential` та викликає `FirebaseAuth.instance.signInWithCredential()`.
            *   Якщо це новий користувач (`additionalUserInfo?.isNewUser`), викликає `_createInitialUserProfile()`.
        *   **`_createInitialUserProfile(User user)`**:
            *   Створює новий документ у колекції `users` Firestore з `uid` користувача як ID документа.
            *   Заповнює базові поля профілю (email, displayName, photoURL з `User` об'єкта, решту полів – значеннями за замовчуванням згідно з дизайн-документом, наприклад, `profileSetupComplete: false`).
            *   Використовує `FieldValue.serverTimestamp()` для `createdAt` та `updatedAt`.
            *   Перевіряє, чи профіль вже існує, щоб уникнути перезапису.
        *   Обробляє `FirebaseAuthException` та інші помилки, відображаючи їх у `_errorMessage`.
*   **`home_page.dart`**:
    *   **Призначення**: Поточна "заглушка" для головного екрану після успішного входу.
    *   **Логіка**: Відображає базову інформацію про користувача (email, displayName, UID) та кнопку виходу (`FirebaseAuth.instance.signOut()`).

### 5.2. Бібліотека Вправ (`exercise_explorer`)

Цей модуль відповідає за відображення списку стандартизованих вправ.

*   **`core/domain/entities/predefined_exercise.dart`**:
    *   **Призначення**: Клас-модель, що представляє одну вправу з усіма її атрибутами (назва, м'язові групи, обладнання тощо).
    *   **Логіка**: Містить конструктор, фабричний метод `fromFirestore()` для перетворення `DocumentSnapshot` з Firestore в об'єкт `PredefinedExercise`, та метод `toMap()` для перетворення об'єкта в `Map` (для запису в Firestore, якщо знадобиться).
*   **`core/domain/repositories/predefined_exercise_repository.dart`**:
    *   **Призначення**: Абстрактний клас (інтерфейс), що визначає контракт для отримання даних про вправи. Це дозволяє відокремити логіку отримання даних від конкретної реалізації (наприклад, Firestore).
    *   **Методи**: `Future<List<PredefinedExercise>> getAllExercises()`.
*   **`features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart`**:
    *   **Призначення**: Конкретна реалізація `PredefinedExerciseRepository`, що використовує Firebase Firestore для отримання даних.
    *   **Логіка**: Метод `getAllExercises()` робить запит до колекції `predefinedExercises` у Firestore, отримує всі документи та перетворює їх на список об'єктів `PredefinedExercise` за допомогою `PredefinedExercise.fromFirestore()`. Обробляє можливі помилки.
*   **`features/exercise_explorer/presentation/cubit/exercise_explorer_state.dart`**:
    *   **Призначення**: Визначає можливі стани для `ExerciseExplorerCubit` (Initial, Loading, Loaded, Error) з використанням `Equatable` для полегшення порівняння станів.
*   **`features/exercise_explorer/presentation/cubit/exercise_explorer_cubit.dart`**:
    *   **Призначення**: Управляє станом екрану бібліотеки вправ.
    *   **Логіка**:
        *   Залежить від `PredefinedExerciseRepository`.
        *   Метод `fetchExercises()`: встановлює стан `ExerciseExplorerLoading`, викликає метод `getAllExercises()` репозиторію. При успішному отриманні даних встановлює стан `ExerciseExplorerLoaded` з отриманим списком вправ. У випадку помилки – `ExerciseExplorerError`.
*   **`features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart`**:
    *   **Призначення**: UI-компонент, що відображає список вправ.
    *   **Логіка**:
        *   Використовує `BlocProvider` для створення та надання `ExerciseExplorerCubit`.
        *   Використовує `BlocBuilder` для перебудови UI залежно від поточного стану `ExerciseExplorerCubit`.
        *   Відображає `CircularProgressIndicator` у стані `Loading`, список вправ (використовуючи `ListView.builder` та `ExerciseListItem`) у стані `Loaded`, або повідомлення про помилку у стані `Error`.
*   **`features/exercise_explorer/presentation/widgets/exercise_list_item.dart`**:
    *   **Призначення**: Віджет для відображення однієї вправи у списку.
    *   **Логіка**: Приймає об'єкт `PredefinedExercise` та відображає його назву, основну м'язову групу. Має обробник `onTap` для майбутньої навігації на детальний екран вправи.

### 5.3. Користувацькі Рутини (`routines`)

Цей модуль дозволяє користувачам створювати, переглядати, редагувати та видаляти власні тренувальні рутини.

*   **`core/domain/entities/routine.dart`**:
    *   **Призначення**: Містить два класи-моделі:
        *   `RoutineExercise`: Представляє одну вправу всередині рутини користувача (посилання на `predefinedExerciseId`, кількість підходів, нотатки).
        *   `UserRoutine`: Представляє повну рутину користувача (ID, userId, назва, список `RoutineExercise`, дні тижня тощо).
    *   **Логіка**: Аналогічно `PredefinedExercise`, ці класи мають конструктори, фабричні методи `fromMap`/`fromFirestore` та методи `toMap`.
*   **`core/domain/repositories/routine_repository.dart`**:
    *   **Призначення**: Абстрактний клас (інтерфейс) для операцій CRUD (Create, Read, Update, Delete) з рутинами користувача.
    *   **Методи**: `createRoutine()`, `getUserRoutines()`, `updateRoutine()`, `deleteRoutine()`.
*   **`features/routines/data/repositories/routine_repository_impl.dart`**:
    *   **Призначення**: Конкретна реалізація `RoutineRepository` з використанням Firestore.
    *   **Логіка**:
        *   `createRoutine()`: Додає новий документ до колекції `userRoutines` Firestore, використовуючи `FieldValue.serverTimestamp()` для `createdAt` та `updatedAt`.
        *   `getUserRoutines()`: Отримує всі рутини для вказаного `userId` з колекції `userRoutines`, сортуючи їх за датою створення.
        *   `updateRoutine()`: Оновлює існуючий документ рутини в Firestore, встановлюючи `updatedAt` на `FieldValue.serverTimestamp()`.
        *   `deleteRoutine()`: Видаляє документ рутини з Firestore за його ID.
*   **Кубіти для Рутин:**
    *   **`user_routines_state.dart` / `user_routines_cubit.dart`**:
        *   **Призначення**: Управління станом списку рутин користувача.
        *   **Логіка**: `UserRoutinesCubit` завантажує список рутин через `RoutineRepository` та надає його UI через стани (Initial, Loading, Loaded, Error). Має методи для завантаження та, можливо, оновлення списку після видалення/додавання.
    *   **`manage_routine_state.dart` / `manage_routine_cubit.dart`**:
        *   **Призначення**: Управління станом процесу створення або редагування однієї рутини.
        *   **Логіка**: `ManageRoutineCubit` обробляє введення даних для нової/редагованої рутини, взаємодіє з `RoutineRepository` для збереження або оновлення. Має стани для відображення процесу (Initial, Loading, Success, Error).
*   **Екрани для Рутин:**
    *   **`features/routines/presentation/screens/user_routines_screen.dart`**:
        *   **Призначення**: Відображає список всіх рутин поточного користувача.
        *   **Логіка**: Використовує `UserRoutinesCubit`. Надає можливість перейти до створення нової рутини (`CreateEditRoutineScreen`) та опції для редагування/видалення існуючих рутин.
    *   **`features/routines/presentation/screens/create_edit_routine_screen.dart`**:
        *   **Призначення**: Форма для створення нової або редагування існуючої рутини.
        *   **Логіка**: Використовує `ManageRoutineCubit`. Містить поля для назви, опису, вибору днів тижня. Ключова частина – інтерфейс для додавання вправ до рутини:
            *   Користувач може обрати вправи з `predefinedExercises` (можна використати `ExerciseExplorerScreen` в режимі вибору або окремий діалог).
            *   Для кожної обраної вправи користувач вказує кількість підходів та, можливо, нотатки.
            *   Список обраних вправ (`List<RoutineExercise>`) динамічно відображається та редагується.
*   **Віджети для Рутин:**
    *   **`features/routines/presentation/widgets/routine_list_item.dart`**: Відображає одну рутину в списку, надає опції (наприклад, через `PopupMenuButton`) для редагування та видалення.
    *   **`features/routines/presentation/widgets/add_exercise_to_routine_dialog.dart`**: (Планується або як частина `CreateEditRoutineScreen`) UI для вибору вправ з `predefinedExercises` та вказання деталей (кількість підходів).

## 6. Структура Бекенду (Firebase)

### 6.1. Firebase Authentication

*   Використовується для реєстрації та входу користувачів (Email/Password, Google).
*   UID користувача з Firebase Auth є первинним ключем для документів у колекції `users` Firestore.

### 6.2. Cloud Firestore (База Даних)

*   **`users`**:
    *   **ID Документа**: `userId` (збігається з Firebase Auth UID).
    *   **Призначення**: Зберігає всю інформацію профілю користувача.
    *   **Ключові поля (поточна реалізація в `_createInitialUserProfile`):**
        *   `uid`: String
        *   `email`: String
        *   `displayName`: String?
        *   `profilePictureUrl`: String?
        *   `username`: String? (поки `null`)
        *   `xp`: Number (default: 0)
        *   `level`: Number (default: 1)
        *   `currentStreak`: Number (default: 0)
        *   `longestStreak`: Number (default: 0)
        *   `lastWorkoutTimestamp`: Timestamp? (default: `null`)
        *   `scheduledWorkoutDays`: List<String> (default: `[]`)
        *   `preferredUnits`: String (default: 'kg')
        *   `profileSetupComplete`: Boolean (default: `false`)
        *   `createdAt`: Timestamp
        *   `updatedAt`: Timestamp
        *   Інші поля з дизайн-документа будуть додаватися поступово.
*   **`predefinedExercises`**:
    *   **ID Документа**: Автогенерований або осмислений ID вправи.
    *   **Призначення**: Зберігає стандартизовану бібліотеку вправ, керовану адміністратором.
    *   **Поля**: `name`, `normalizedName`, `primaryMuscleGroup`, `secondaryMuscleGroups`, `equipmentNeeded`, `description`, `videoDemonstrationUrl`, `difficultyLevel`, `tags`.
*   **`userRoutines`**:
    *   **ID Документа**: Автогенерований ID рутини.
    *   **Призначення**: Зберігає тренувальні рутини, створені користувачами.
    *   **Поля**: `userId`, `name`, `description`, `exercises` (список `Map`, що містить `predefinedExerciseId`, `exerciseNameSnapshot`, `numberOfSets`, `notes`), `scheduledDays`, `isPublic`, `createdAt`, `updatedAt`. Інші поля (рейтинг, копії) для майбутніх соціальних функцій.

### 6.3. Firebase Storage (Планується)

*   `profile_pictures/{userId}/<filename>`: Для зберігання аватарів користувачів.
*   Інші шляхи для медіа, пов'язаного з постами та доказами рекордів (як у дизайн-документі).

### 6.4. Firebase Cloud Functions (Планується)

Хоча ще не реалізовані, їх роль буде критичною для:

*   **Автоматичних обчислень**: Наприклад, розрахунок тренувального об'єму після збереження тренування.
*   **Тригерів**: Наприклад, нарахування XP за виконання рутини, оновлення стріків.
*   **Підтримки цілісності даних**: Наприклад, оновлення денормалізованих полів.
*   **Запланованих завдань**: Наприклад, генерація лідербордів, надсилання нагадувань.
*   **Push-сповіщень**.

## 7. Налаштування та Запуск Проєкту

1.  **Передумови**:
    *   Встановлений Flutter SDK (версія, вказана у `pubspec.yaml` або новіша).
    *   Налаштоване середовище розробки (Android Studio, VS Code з плагінами Flutter/Dart).
    *   Firebase CLI встановлено та налаштовано.
2.  **Клонування Репозиторію** (якщо проєкт у Git):
    ```bash
    git clone <URL_РЕПОЗИТОРІЮ>
    cd muscle_up
    ```
3.  **Налаштування Firebase**:
    *   Переконайся, що в корені проєкту є файл `firebase.json`.
    *   Для Android: файл `android/app/google-services.json` повинен бути завантажений з твого Firebase проєкту.
    *   Для iOS: файл `ios/Runner/GoogleService-Info.plist` (якщо використовується) повинен бути завантажений та доданий до Xcode проєкту.
    *   Файл `lib/firebase_options.dart` повинен бути актуальним (згенерований через `flutterfire configure`).
4.  **Налаштування Google Sign-In**:
    *   **Android**:
        *   Переконайся, що SHA-1 відбиток твого debug та release ключів додано до налаштувань Android-застосунку в Firebase Console.
        *   `google-services.json` повинен містити `client_id` типу 3 (Web application) для Google Sign-In.
    *   **iOS**: (Якщо планується)
        *   Додай URL Scheme до `Info.plist` (зазвичай REVERSED_CLIENT_ID з `GoogleService-Info.plist`).
5.  **Встановлення Залежностей**:
    ```bash
    flutter pub get
    ```
6.  **Запуск Застосунку**:
    *   Обери цільовий пристрій (емулятор або фізичний пристрій).
    *   Виконай:
        ```bash
        flutter run
        ```

## 8. Подальші Кроки та Розвиток (Згідно з Дизайн-Документом)

Поточна реалізація закладає фундамент. Наступні кроки включатимуть:

*   **Логування Тренувань (`userWorkouts`)**: Детальне логування сетів, повторень, ваги, RPE.
*   **Дашборд (`HomePage` -> `DashboardScreen`)**: Відображення статистики, прогресу.
*   **Гейміфікація**: Детальна система XP, рівнів, досягнень.
*   **Соціальні Функції**: Стрічка активності, підписки, публічні рекорди.
*   **Цілі**: Створення та відстеження персоналізованих цілей.
*   **Розширення UI/UX**: Покращення дизайну, онбординг.
*   **Реалізація Cloud Functions** для автоматизації та серверної логіки.
*   **Тестування**: Написання unit, widget та integration тестів.

Цей README буде оновлюватися в міру розвитку проєкту.
