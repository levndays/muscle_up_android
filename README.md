# MuscleUP: Фітнес-застосунок нового покоління

**Девіз:** Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

## 1. Вступ

**MuscleUP** – це інноваційний мобільний фітнес-застосунок, покликаний революціонізувати ваш підхід до тренувань. Наша місія – створити надзвичайно мотивуюче, соціально інтерактивне та гейміфіковане середовище, яке допоможе користувачам не лише досягати своїх фітнес-цілей, але й отримувати задоволення від процесу, підтримуючи довгострокову залученість. MuscleUP дає змогу детально відстежувати кожне тренування, встановлювати та досягати персоналізовані цілі, аналізувати прогрес за допомогою унікальних метрик (як-от RPE для кожного повторення), ділитися своїми досягненнями та отримувати підтримку від спільноти.

Цей документ описує поточний стан проєкту, ключову бізнес-логіку, архітектуру програмного забезпечення, дизайн бекенду та функціональність хмарних функцій Firebase, з акцентом на модульність, масштабованість та простоту підтримки.

## 2. Поточний стан проєкту (Версія ~0.3.x)

На даному етапі реалізовано значний набір ключових функцій, що формують ядро застосунку:

*   **Автентифікація та Профіль Користувача:**
    *   Реєстрація та вхід за допомогою Email/Password та Google Sign-In.
    *   Автоматичне створення початкового профілю користувача в Cloud Firestore при першій реєстрації (`profileSetupComplete: false`).
    *   Спеціалізований екран "Profile Setup" (`ProfileSetupScreen`) для введення користувачем детальної інформації (username, стать, дата народження, зріст, вага, фітнес-цілі, рівень активності).
    *   Динамічне оновлення профілю користувача в реальному часі за допомогою `UserProfileCubit`.
    *   Автоматичне нагородження "Early Bird" ачівкою після завершення налаштування профілю.
*   **Головний Екран та Навігація (`HomePage`):**
    *   Центральний AppBar з динамічним заголовком, що відображає назву "MuscleUP" та поточний розділ.
    *   BottomNavigationBar для легкої навігації між основними розділами: Routines, Explore, Progress (плейсхолдер), Profile.
    *   FloatingActionButton "START WORKOUT" на вкладці Dashboard, що дозволяє розпочати нове тренування (з рутини або порожнє) або продовжити активне.
*   **Дашборд (`DashboardScreen`):**
    *   Персоналізоване привітання користувача та відображення стріку тренувань (з `UserProfileCubit`).
    *   Базова статистика (вага, стрік – частково плейсхолдери, але дані беруться з профілю).
    *   **Секція Сповіщень:** Інтерактивний список останніх сповіщень (`NotificationListItem`) з лічильником непрочитаних, можливістю видалення свайпом, переходу до деталей (`NotificationDetailScreen`) та позначення всіх як прочитаних.
*   **Бібліотека Вправ (`ExerciseExplorerScreen`):**
    *   Перегляд стандартизованих вправ з Firestore.
    *   Підтримка режиму вибору вправи для додавання до рутин.
*   **Керування Рутинами Тренувань (`features/routines`):**
    *   Екран `UserRoutinesScreen` для перегляду, створення, редагування та видалення користувацьких рутин.
    *   Додавання вправ до рутини з `ExerciseExplorerScreen` через кастомний діалог `AddExerciseToRoutineDialog`.
    *   Налаштування назви, опису, днів тижня, кількості сетів та нотаток для кожної вправи в рутині.
*   **Трекінг Тренувань (`ActiveWorkoutScreen`):**
    *   Можливість розпочати тренування на основі обраної рутини або як порожнє.
    *   Автоматичне завантаження та продовження незавершеної сесії тренування.
    *   Інтерфейс логування сету (`CurrentSetDisplay`):
        *   Відображення назви поточної вправи, номера сету.
        *   Введення ваги та кількості виконаних повторень.
        *   **Унікальна фіча: RPE (Rate of Perceived Exertion) слайдери для кожного повторення,** що дозволяють оцінити складність кожного окремого повторення.
        *   Навігація між сетами та вправами.
    *   Завершення/Скасування тренування з підтвердженням.
*   **Екран Завершення Тренування (`WorkoutCompleteScreen`):**
    *   Відображається після успішного завершення тренування.
    *   Анімація з Lottie (трофей) та ефект конфетті.
    *   Відображення ключових показників: назва рутини (якщо була), тривалість, загальний об'єм.
    *   **Нарахування XP та Прогрес Рівня:** Розрахунок та анімоване відображення отриманого досвіду (XP) та прогресу до наступного рівня.
    *   Відображення інформації про перехід на новий рівень (якщо відбувся).
    *   Автоматичне оновлення стріку тренувань та `lastWorkoutTimestamp` у профілі користувача (через Firebase Function).
    *   Автоматичне нагородження "First Workout" ачівкою.
*   **Модуль Сповіщень (`features/notifications`):**
    *   Модель `AppNotification` та `NotificationType`.
    *   `NotificationRepository` для взаємодії з Firestore.
    *   `NotificationsCubit` для управління станом сповіщень.
*   **Хмарні Функції Firebase:**
    *   `createUserProfile`: Створює документ профілю при реєстрації нового користувача.
    *   `calculateAndAwardXpAndStreak`: Обробляє завершені тренування, нараховує XP, оновлює рівень, стрік та видає ачівку "First Workout".
    *   `checkProfileSetupCompletionAchievements`: Видає ачівку "Early Bird" при завершенні налаштування профілю.
    *   `seedPredefinedExercises`: HTTP-функція для початкового заповнення бази даних вправ.
*   **Архітектура та Стан:**
    *   Використання Flutter BLoC/Cubit для управління станом.
    *   Чітке розділення на шари (Domain, Data, Presentation).
    *   Репозиторії для абстрагування доступу до даних.

## 3. Ключові Архітектурні Принципи

Проєкт дотримується сучасних практик розробки програмного забезпечення:

*   **Модульність (Feature-First):** Кожна значна функціональність розробляється як окремий модуль, що спрощує розробку, тестування та підтримку.
*   **Чітке Розділення Відповідальностей:** Застосування шарової архітектури (Presentation, Domain, Data) в межах кожного модуля та на рівні всього додатку.
*   **Управління Станом:** Flutter BLoC/Cubit використовується для ефективного управління станом UI та бізнес-логіки, забезпечуючи передбачуваність та тестованість.
*   **Залежності (Dependency Injection):** `RepositoryProvider` та `BlocProvider` з пакету `flutter_bloc` використовуються для надання залежностей віджетам та іншим кубітам/блокам.
*   **Абстракція Джерел Даних:** Репозиторії надають абстрактний інтерфейс для роботи з даними, приховуючи деталі реалізації (наприклад, взаємодію з Firebase).
*   **Масштабованість:** Архітектура спроєктована з урахуванням майбутнього розширення функціоналу, дозволяючи легко додавати нові фічі.
*   **Тестованість:** Розділення логіки сприяє написанню unit-тестів для бізнес-логіки та widget-тестів для UI.

## 4. Технологічний Стек

*   **Фронтенд:**
    *   **Framework:** Flutter (`^3.8.0` Dart SDK)
    *   **Мова програмування:** Dart
    *   **Управління станом:** Flutter BLoC/Cubit (`flutter_bloc: ^9.1.1`, `bloc: ^9.0.0`)
    *   **Рівність об'єктів:** Equatable (`equatable: ^2.0.5`)
    *   **Форматування дати/часу:** `intl: ^0.19.0`
    *   **Анімації:**
        *   `animated_background: ^2.0.0` (для фону сторінки входу - `LavaLampBackground`)
        *   `confetti: ^0.7.0` (для ефекту конфетті на екрані завершення тренування)
        *   `lottie: ^3.1.2` (для анімації трофею на екрані завершення тренування)
    *   **Навігація:** Стандартна Flutter навігація (`MaterialPageRoute`, `Navigator.push/pop/pushAndRemoveUntil`).
*   **Бекенд (Firebase):**
    *   **Firebase Core:** `firebase_core: ^3.13.1` (ініціалізація Firebase)
    *   **Firebase Authentication:** `firebase_auth: ^5.5.4` (автентифікація через Email/Password, Google Sign-In)
    *   **Google Sign-In:** `google_sign_in: ^6.2.1` (інтеграція з Google для входу)
    *   **Cloud Firestore:** `cloud_firestore: ^5.6.8` (NoSQL база даних для зберігання профілів, рутин, вправ, сповіщень, логів тренувань та ін.)
    *   **Firebase Functions:** (`firebase-functions: ^6.0.1`, `firebase-admin: ^12.6.0` в `functions/package.json`) для серверної логіки (Node.js v20, TypeScript).
*   **Інструменти розробки:**
    *   **Лінтер:** `flutter_lints: ^5.0.0` (забезпечення якості коду)
    *   **Іконки запуску:** `flutter_launcher_icons: ^0.13.1` (генерація іконок додатку для різних платформ)
    *   **Python Snapshoting Script:** `create_snapshot.py` (кастомний скрипт для генерації знімків проєкту).

## 5. Структура Проєкту

Проєкт організований за принципом "feature-first", де кожна основна функціональність винесена в окрему директорію в `lib/features/`.

muscle_up/
├── android/ # Специфічний для Android код
├── assets/ # Ресурси додатку
│ ├── animations/
│ │ └── trophy_animation.json # Lottie анімація для WorkoutCompleteScreen
│ ├── fonts/ # Шрифти (Inter, IBMPlexMono)
│ └── images/ # Зображення (google_logo.png, app_icon.png)
├── functions/ # Код для Firebase Cloud Functions
│ ├── src/
│ │ └── index.ts # Головний файл з логікою функцій Firebase
│ ├── populatedb.js # Допоміжний скрипт для заповнення БД (може бути замінений HTTP функцією)
│ ├── package.json # Залежності та скрипти для Firebase Functions
│ ├── tsconfig.json # Конфігурація TypeScript для функцій
│ └── ... # Інші файли конфігурації ESLint, .gitignore для функцій
├── ios/ # Специфічний для iOS код
├── lib/ # Основний код додатку на Dart
│ ├── auth_gate.dart # Керує потоком автентифікації та перевіркою profileSetupComplete
│ ├── firebase_options.dart # Конфігурація Firebase (згенеровано FlutterFire)
│ ├── home_page.dart # ГОЛОВНИЙ ЕКРАН: AppBar, BottomNavigationBar, FAB, керування вкладками. Надає NotificationsCubit.
│ ├── login_page.dart # Екран входу/реєстрації, анімований фон
│ ├── main.dart # Точка входу, ініціалізація Firebase, MaterialApp, RepositoryProviders
│ │
│ ├── core/ # Спільна логіка, моделі та інтерфейси репозиторіїв
│ │ └── domain/
│ │ ├── entities/ # Сутності домену (POJO/PODO)
│ │ │ ├── achievement.dart # Модель для ачівок та їх словник
│ │ │ ├── app_notification.dart # Модель для сповіщення
│ │ │ ├── logged_exercise.dart # Модель для залогованої вправи в сесії тренування
│ │ │ ├── logged_set.dart # Модель для залогованого сету
│ │ │ ├── predefined_exercise.dart # Модель для стандартизованої вправи з бібліотеки
│ │ │ ├── routine.dart # Моделі UserRoutine та RoutineExercise
│ │ │ ├── user_profile.dart # Модель для профілю користувача
│ │ │ └── workout_session.dart # Модель для сесії тренування
│ │ └── repositories/ # Абстрактні інтерфейси для репозиторіїв
│ │ ├── notification_repository.dart
│ │ ├── predefined_exercise_repository.dart
│ │ ├── routine_repository.dart
│ │ ├── user_profile_repository.dart
│ │ └── workout_log_repository.dart
│ │
│ ├── features/ # Модулі окремих фіч
│ │ ├── dashboard/ # Фіча дашборду
│ │ │ └── presentation/
│ │ │ └── screens/
│ │ │ └── dashboard_screen.dart # UI для дашборду (вміст для HomePage)
│ │ │
│ │ ├── exercise_explorer/ # Фіча бібліотеки вправ
│ │ │ ├── data/
│ │ │ │ └── repositories/
│ │ │ │ └── predefined_exercise_repository_impl.dart
│ │ │ └── presentation/
│ │ │ ├── cubit/ # Cubit та State для управління логікою бібліотеки
│ │ │ │ ├── exercise_explorer_cubit.dart
│ │ │ │ └── exercise_explorer_state.dart
│ │ │ ├── screens/
│ │ │ │ └── exercise_explorer_screen.dart # Екран перегляду вправ
│ │ │ └── widgets/
│ │ │ └── exercise_list_item.dart # Віджет для відображення однієї вправи
│ │ │
│ │ ├── notifications/ # Фіча сповіщень
│ │ │ ├── data/
│ │ │ │ └── repositories/
│ │ │ │ └── notification_repository_impl.dart
│ │ │ └── presentation/
│ │ │ ├── cubit/ # Cubit та State для управління сповіщеннями
│ │ │ │ ├── notifications_cubit.dart
│ │ │ │ └── notifications_state.dart
│ │ │ ├── screens/
│ │ │ │ └── notification_detail_screen.dart # Екран деталей сповіщення
│ │ │ └── widgets/
│ │ │ └── notification_list_item.dart # Віджет для одного сповіщення
│ │ │
│ │ ├── profile/ # Фіча профілю користувача (відображення)
│ │ │ └── presentation/
│ │ │ ├── cubit/ # Cubit та State для профілю користувача
│ │ │ │ ├── user_profile_cubit.dart
│ │ │ │ └── user_profile_state.dart
│ │ │ └── screens/
│ │ │ └── profile_screen.dart # Екран відображення профілю
│ │ │
│ │ ├── profile_setup/ # Фіча початкового налаштування профілю
│ │ │ ├── data/
│ │ │ │ └── repositories/
│ │ │ │ └── user_profile_repository_impl.dart # Реалізація репозиторію профілю
│ │ │ └── presentation/
│ │ │ ├── cubit/ # Cubit та State для налаштування профілю
│ │ │ │ ├── profile_setup_cubit.dart
│ │ │ │ └── profile_setup_state.dart
│ │ │ └── screens/
│ │ │ └── profile_setup_screen.dart # Екран форми налаштування
│ │ │
│ │ ├── routines/ # Фіча керування рутинами тренувань
│ │ │ ├── data/
│ │ │ │ └── repositories/
│ │ │ │ └── routine_repository_impl.dart
│ │ │ └── presentation/
│ │ │ ├── cubit/ # Cubits та States для рутин
│ │ │ │ ├── manage_routine_cubit.dart # Для створення/редагування
│ │ │ │ ├── manage_routine_state.dart
│ │ │ │ ├── user_routines_cubit.dart # Для списку рутин
│ │ │ │ └── user_routines_state.dart
│ │ │ ├── screens/
│ │ │ │ ├── create_edit_routine_screen.dart # Екран створення/редагування
│ │ │ │ └── user_routines_screen.dart # Екран списку рутин
│ │ │ └── widgets/
│ │ │ ├── add_exercise_to_routine_dialog.dart # Діалог додавання вправи
│ │ │ └── routine_list_item.dart # Віджет для однієї рутини
│ │ │
│ │ └── workout_tracking/ # Фіча трекінгу тренувань
│ │ ├── data/
│ │ │ └── repositories/
│ │ │ └── workout_log_repository_impl.dart
│ │ └── presentation/
│ │ ├── cubit/ # Cubit та State для активного тренування
│ │ │ ├── active_workout_cubit.dart
│ │ │ └── active_workout_state.dart
│ │ ├── screens/
│ │ │ ├── active_workout_screen.dart # Екран активного тренування
│ │ │ └── workout_complete_screen.dart # Екран завершення тренування
│ │ └── widgets/
│ │ └── current_set_display.dart # Віджет для логування сету з RPE
│ │
│ ├── utils/ # Допоміжні утиліти
│ │ └── duration_formatter.dart # Функція для форматування тривалості
│ │
│ └── widgets/ # Загальні віджети, що використовуються в кількох місцях
│ └── lava_lamp_background.dart # Анімований фон для LoginPage
│
├── pubspec.yaml # Конфігурація проєкту, залежності, ресурси
├── README.md # Цей файл
└── ... # Інші файли конфігурації (.firebaserc, firebase.json)


## 6. Детальний Опис Ключових Компонентів та UX

### 6.1. Автентифікація та Налаштування Профілю

*   **`LoginPage`**: Початковий екран для неавтентифікованих користувачів. Має привабливий анімований фон "лавової лампи" (`LavaLampBackground`). Надає форми для входу та реєстрації через Email/Password, а також кнопку "Sign in with Google".
*   **`AuthGate`**: Відстежує зміни стану автентифікації Firebase Auth. Якщо користувач автентифікований, `AuthGate` завантажує його профіль з Firestore через `UserProfileRepository` (використовуючи стрім `getUserProfileStream`).
    *   Якщо профіль ще не існує в Firestore (повертається `null`), `AuthGate` показує індикатор завантаження, очікуючи, поки Firebase Function `createUserProfile` створить початковий документ.
    *   Після завантаження профілю, якщо `profileSetupComplete == false`, користувач направляється на `ProfileSetupScreen`.
    *   Якщо `profileSetupComplete == true`, користувач направляється на `HomePage`.
    *   `AuthGate` надає `UserProfileCubit` для `HomePage` та її дочірніх віджетів.
*   **Firebase Function `createUserProfile`**: Автоматично спрацьовує при створенні нового користувача в Firebase Authentication. Створює відповідний документ у колекції `users` Firestore з початковими даними, включаючи `email`, `displayName` (якщо доступно з Auth), `profilePictureUrl` (якщо доступно), `xp: 0`, `level: 1`, та `profileSetupComplete: false`.
*   **`ProfileSetupScreen`**: Дозволяє користувачеві ввести детальну інформацію про себе: унікальний `username` (обов'язково), `displayName`, стать, дату народження, зріст, вагу, фітнес-ціль та рівень активності. Використовує `ProfileSetupCubit` для управління станом форми та збереження даних. Після успішного збереження, `profileSetupComplete` встановлюється в `true`.
*   **Firebase Function `checkProfileSetupCompletionAchievements`**: Спрацьовує при будь-якому записі (створенні або оновленні) документа в колекції `users`. Якщо поле `profileSetupComplete` змінилося з `false` на `true`, ця функція додає ID ачівки `AchievementId.EARLY_BIRD` до масиву `achievedRewardIds` користувача та створює відповідне сповіщення.
*   **`UserProfileCubit`**: Глобальний кубіт, доступний в `HomePage` та її дочірніх віджетах. Відповідає за завантаження та надання даних `UserProfile` з Firestore, а також слухає зміни профілю в реальному часі для оновлення UI.

### 6.2. Головний Екран (`HomePage` та `DashboardScreen`)

*   **`HomePage`**: Центральний екран додатку після успішної автентифікації та налаштування профілю.
    *   **`AppBar`**: Відображає назву "MuscleUP" (клікабельна для переходу на дашборд) та назву поточної активної вкладки.
    *   **`BottomNavigationBar`**: Дозволяє перемикатися між розділами: "ROUTINES" (`UserRoutinesScreen`), "EXPLORE" (`ExerciseExplorerScreen`), "PROGRESS" (наразі плейсхолдер), "PROFILE" (`ProfileScreen`).
    *   **`FloatingActionButton`**: "START WORKOUT". При натисканні перевіряє наявність активної сесії тренування через `WorkoutLogRepository`. Якщо є – переходить до `ActiveWorkoutScreen` для продовження. Якщо немає – пропонує розпочати з рутини або порожнє тренування.
    *   Надає `NotificationsCubit` для дочірніх віджетів, щоб дашборд міг показувати сповіщення.
*   **`DashboardScreen`**: Вміст для головної вкладки "MuscleUP" (`_selectedIndex = -1` в `HomePage`).
    *   Відображає персоналізоване привітання (використовуючи ім'я з `UserProfileCubit`) та іконку "вогника" зі стріком тренувань. Клік по привітанню переводить на екран Профілю, клік по вогнику - на екран Прогресу.
    *   Секція "STATS": Плейсхолдер для графіка "Total Volume" та картки зі статистикою "WEIGHT", "STREAK", "ADHERENCE" (дані частково з `UserProfileCubit`).
    *   **Секція "NOTIFICATIONS"**: Динамічно відображає останні сповіщення, лічильник непрочитаних, кнопки "READ ALL" та для генерації тестових сповіщень. Використовує `NotificationsCubit`.

### 6.3. Сповіщення (`features/notifications`)

*   **Модель `AppNotification`**: Описує структуру сповіщення (ID, тип, заголовок, повідомлення, час, статус прочитання, пов'язані дані, назва іконки). `NotificationType` є `enum` (напр., `achievementUnlocked`, `workoutReminder`).
*   **`NotificationRepositoryImpl`**: Реалізує взаємодію з підколекцією `users/{userId}/notifications` в Firestore для отримання, оновлення (позначення як прочитане) та видалення сповіщень.
*   **`NotificationsCubit`**: Керує станом списку сповіщень для поточного користувача, підписується на зміни в Firestore та оновлює UI. Надає методи для взаємодії зі сповіщеннями (позначити як прочитане, прочитати всі, видалити).
*   **`NotificationListItem`**: Віджет для відображення одного сповіщення у списку. Підтримує свайп для видалення.
*   **`NotificationDetailScreen`**: Екран для детального перегляду одного сповіщення. При відкритті, якщо сповіщення не було прочитане, воно позначається як прочитане.

### 6.4. Бібліотека Вправ (`features/exercise_explorer`)

*   **Модель `PredefinedExercise`**: Описує стандартизовану вправу (назва, група м'язів, обладнання, опис, URL відео, складність, теги).
*   **`PredefinedExerciseRepositoryImpl`**: Завантажує список вправ з колекції `predefinedExercises` Firestore.
*   **Firebase Function `seedPredefinedExercises`**: HTTP-функція, яку можна викликати (опціонально, захищено ключем) для початкового заповнення колекції `predefinedExercises` даними з масиву `predefinedExercisesData` в `functions/src/index.ts`.
*   **`ExerciseExplorerCubit`**: Завантажує та кешує список вправ для відображення.
*   **`ExerciseExplorerScreen`**: Відображає список вправ. Може працювати в режимі вибору (`isSelectionMode: true`), коли потрібно обрати вправу для додавання до рутини. В цьому режимі повертає обраний `PredefinedExercise` назад.

### 6.5. Керування Рутинами Тренувань (`features/routines`)

*   **Моделі `UserRoutine`, `RoutineExercise`**: Описують структуру користувацької рутини та вправ у ній (ID вправи, назва-знімок, кількість сетів, нотатки).
*   **`RoutineRepositoryImpl`**: Реалізує CRUD-операції для рутин у колекції `userRoutines` Firestore, пов'язаних з конкретним `userId`.
*   **`UserRoutinesCubit`**: Завантажує та надає список усіх рутин поточного користувача.
*   **`ManageRoutineCubit`**: Керує станом створення нової або редагування існуючої рутини. Зберігає проміжні зміни (назва, опис, дні, список вправ) та фіналізує збереження/оновлення в Firestore.
*   **`UserRoutinesScreen`**: Відображає список рутин користувача. Має FAB для переходу на `CreateEditRoutineScreen`.
*   **`CreateEditRoutineScreen`**: Форма для створення/редагування рутини. Дозволяє вказати назву, опис, обрати дні тижня. Вправи додаються за допомогою `AddExerciseToRoutineDialog`. Кожну вправу в рутині можна редагувати (кількість сетів, нотатки) або видаляти.
*   **`AddExerciseToRoutineDialog`**: Кастомний діалог, що використовує `ExerciseExplorerScreen` в режимі вибору для додавання вправи, після чого користувач вказує кількість сетів та нотатки для цієї вправи в рутині.

### 6.6. Трекінг Тренувань (`features/workout_tracking`)

*   **Сутності**: `WorkoutSession`, `LoggedExercise`, `LoggedSet`.
    *   `WorkoutSession`: Головна сутність, що представляє сесію тренування (ID, ID користувача, ID рутини (опціонально), знімок назви рутини, час початку/кінця, тривалість, список виконаних вправ, нотатки, статус, загальний об'єм).
    *   `LoggedExercise`: Вправа, виконана в рамках сесії (ID з `predefinedExercises`, знімок назви, цільова кількість сетів, список виконаних сетів, нотатки).
    *   `LoggedSet`: Один виконаний сет (номер, вага, повторення, статус завершення, нотатки, що включають дані RPE).
*   **`WorkoutLogRepositoryImpl`**: Керує сесіями тренувань у підколекції `users/{userId}/workoutLogs`. Реалізує логіку старту нової сесії, оновлення даних сетів/вправ, завершення та скасування сесій. Надає стрім для відстеження активної сесії.
*   **`ActiveWorkoutCubit`**:
    *   При ініціалізації підписується на стрім активної сесії з `WorkoutLogRepository`.
    *   `startNewWorkout`: Створює нову `WorkoutSession`. Якщо передано `UserRoutine`, копіює вправи та структуру сетів з неї. Зберігає сесію в Firestore зі статусом `inProgress`.
    *   `updateLoggedSet`: Оновлює дані конкретного сету (вага, повторення, RPE, нотатки) в локальному стані кубіта та синхронізує зміни з Firestore.
    *   `addSetToExercise`: Дозволяє користувачу додати новий (додатковий) порожній сет до поточної вправи під час тренування.
    *   `completeWorkout`: Змінює статус сесії на `completed`, розраховує тривалість, загальний об'єм та зберігає дані в Firestore. Це спрацьовує Firebase Function.
    *   `cancelWorkout`: Змінює статус сесії на `cancelled` в Firestore.
    *   Керує таймером тривалості тренування, що відображається в UI.
*   **Firebase Function `calculateAndAwardXpAndStreak`**: Спрацьовує, коли документ у `workoutLogs` оновлюється і його поле `status` змінюється на `completed`.
    *   Розраховує XP на основі тривалості та загального об'єму тренування.
    *   Оновлює `currentStreak` та `longestStreak` користувача.
    *   Оновлює `lastWorkoutTimestamp`.
    *   Оновлює загальну кількість `xp` та `level` користувача.
    *   Якщо це перше завершene тренування користувача (перевіряючи `achievedRewardIds`), додає `AchievementId.FIRST_WORKOUT` до `achievedRewardIds` та створює відповідне сповіщення.
*   **`ActiveWorkoutScreen`**:
    *   При відкритті, якщо передано `routineForNewWorkout`, ініціює створення нової сесії через кубіт. В іншому випадку, кубіт сам завантажить активну сесію, якщо вона існує.
    *   Відображає назву рутини (або "Active Workout"), таймер тривалості.
    *   Центральний елемент – `CurrentSetDisplay`.
    *   Кнопки навігації "PREV. SET" / "NEXT SET" / "NEXT EXERCISE" та кнопка "FINISH WORKOUT".
*   **`CurrentSetDisplay`**:
    *   Відображає назву поточної вправи, номер сету, цільову кількість сетів (з рутини).
    *   Поле для введення ваги (редагується через діалог).
    *   Кнопки "+"/"-" для зміни кількості виконаних повторень.
    *   **Унікальна UX фіча: RPE слайдери.** Після встановлення кількості повторень з'являється відповідна кількість вертикальних RPE слайдерів (шкала 0-10). Користувач оцінює складність кожного окремого повторення. Дані RPE зберігаються у полі `notes` відповідного `LoggedSet` у форматі "RPE_DATA:val1,val2,...".
    *   Збереження даних сету (вага, повторення, RPE) відбувається при переході до іншого сету/вправи або при завершенні тренування.
*   **`WorkoutCompleteScreen`**:
    *   Відображається автоматично після успішного завершення тренування (навігація ініціюється `ActiveWorkoutCubit` при переході в стан `ActiveWorkoutSuccessfullyCompleted`).
    *   Анімація "трофею" з Lottie та ефект конфетті.
    *   Сумарна інформація про тренування: назва рутини, тривалість, загальний об'єм.
    *   Відображення нарахованого XP (отриманого з `ActiveWorkoutCubit`, який, в свою чергу, може отримати його з Firebase Function або розрахувати локально для UI) та анімований прогрес-бар XP до наступного рівня.
    *   Інформація про перехід на новий рівень, якщо такий відбувся (на основі даних з оновленого `UserProfile`, переданого в екран).
    *   Кнопка "Awesome!" для повернення на головний екран (`HomePage` через `AuthGate`).

### 6.7. Якість Життя (Quality of Life) та UX Деталі

*   **Анімований фон `LavaLampBackground`** на `LoginPage` для приємного першого враження.
*   **Деталізована тема** в `main.dart` з використанням кастомних шрифтів `Inter` (для основного тексту) та `IBMPlexMono` (для акцентів, статистики, коду), що створює узгоджений та сучасний вигляд.
*   **Інтуїтивна навігація** між сетами та вправами в `ActiveWorkoutScreen`.
*   **Чіткі діалоги підтвердження** для критичних дій (видалення, скасування, завершення).
*   **Візуальний фідбек** (через `SnackBar`) при збереженні даних, помилках, успішних діях.
*   **Обробка станів завантаження** з `CircularProgressIndicator` у відповідних місцях.
*   **RPE слайдери** для кожного повторення – ключова фіча, що дозволяє користувачам детально аналізувати навантаження та суб'єктивні відчуття від кожного повторення.
*   **Яскраві анімації на екрані завершення тренування** (`confetti`, `lottie`, анімований XP бар) для позитивного підкріплення та гейміфікації.
*   **Логування дій** за допомогою `dart:developer` для полегшення налагодження та моніторингу.
*   **Іконки запуску** налаштовані через `flutter_launcher_icons` для Android та iOS.
*   **Автоматичне оновлення UI** завдяки Flutter BLoC/Cubit та стрімам з Firestore для профілю, сповіщень, активного тренування.
*   **Режим вибору вправ** в `ExerciseExplorerScreen` для зручного додавання в рутини.
*   **Форматування тривалості** тренування за допомогою `duration_formatter.dart` для зрозумілого відображення.

## 7. Структура Бекенду (Firebase Cloud Firestore)

База даних Firestore організована наступним чином:

*   **`users/{userId}`**: Колекція документів користувачів. Кожен документ містить:
    *   Поля з `UserProfile`: `uid`, `email`, `displayName`, `profilePictureUrl`, `username`, `gender`, `dateOfBirth`, `heightCm`, `weightKg`, `fitnessGoal`, `activityLevel`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastWorkoutTimestamp`, `followersCount`, `followingCount`, `achievedRewardIds` (масив String ID ачівок), `profileSetupComplete`, `createdAt`, `updatedAt`.
    *   **Підколекція `notifications/{notificationId}`**:
        *   Документи, що представляють `AppNotification` (type, title, message, timestamp, isRead, iconName, relatedEntityId, relatedEntityType).
    *   **Підколекція `workoutLogs/{sessionId}`**:
        *   Документи, що представляють `WorkoutSession` (userId, routineId, routineNameSnapshot, startedAt, endedAt, durationSeconds, completedExercises (масив об'єктів `LoggedExercise`), notes, status (inProgress, completed, cancelled), totalVolume).
        *   Вкладені об'єкти `LoggedExercise` містять: `predefinedExerciseId`, `exerciseNameSnapshot`, `targetSets`, `notes` та масив `completedSets`.
        *   Вкладені об'єкти `LoggedSet` містять: `setNumber`, `weightKg`, `reps`, `isCompleted`, `notes` (може містити дані RPE у форматі "RPE_DATA:x,y,z").
*   **`predefinedExercises/{exerciseId}`**: Колекція документів стандартизованих вправ.
    *   Поля з `PredefinedExercise`: `name`, `normalizedName` (для пошуку без урахування регістру), `primaryMuscleGroup`, `secondaryMuscleGroups`, `equipmentNeeded`, `description`, `videoDemonstrationUrl`, `difficultyLevel`, `tags`.
*   **`userRoutines/{routineId}`**: Колекція документів користувацьких рутин.
    *   Поля з `UserRoutine`: `userId`, `name`, `description`, `exercises` (масив об'єктів `RoutineExercise`), `scheduledDays`, `isPublic`, `createdAt`, `updatedAt`.
    *   Вкладені об'єкти `RoutineExercise` містять: `predefinedExerciseId`, `exerciseNameSnapshot`, `numberOfSets`, `notes`.

## 8. Логіка Firebase Functions (`functions/src/index.ts`)

Хмарні функції Firebase використовуються для автоматизації певних бекенд-процесів:

*   **`createUserProfile` (Auth v1 Trigger - `onCreate`):**
    *   Спрацьовує автоматично, коли новий користувач реєструється в Firebase Authentication.
    *   Створює відповідний документ для цього користувача в колекції `users` Firestore.
    *   Заповнює початкові поля профілю: `uid`, `email` (якщо доступний), `displayName` (якщо доступний з Auth провайдера), `profilePictureUrl` (якщо доступний), встановлює `xp = 0`, `level = 1`, `profileSetupComplete = false`, та `createdAt`, `updatedAt` як серверні позначки часу.
*   **`calculateAndAwardXpAndStreak` (Firestore v2 Trigger - `onDocumentUpdated` на `users/{userId}/workoutLogs/{sessionId}`):**
    *   Спрацьовує, коли документ логу тренування оновлюється.
    *   Перевіряє, чи поле `status` змінилося на `"completed"`.
    *   Якщо так, розраховує:
        *   `xpGained`: Базове XP (50) + XP за об'єм (загальний об'єм / 100) + XP за тривалість (тривалість у секундах / 300). Максимум 200 XP.
    *   Отримує поточний профіль користувача.
    *   Оновлює `currentStreak` (збільшує, якщо тренування в послідовний день, інакше скидає на 1) та `longestStreak`.
    *   Оновлює `lastWorkoutTimestamp`.
    *   Додає `xpGained` до загального `xp` користувача.
    *   Перераховує `level` користувача на основі нового `xp` (формула: `xpPerLevelBase + (level - 1) * 50` для кожного рівня).
    *   **Ачівка "First Workout"**: Якщо `AchievementId.FIRST_WORKOUT` ще немає в `achievedRewardIds` користувача, додає її та створює сповіщення типу `achievementUnlocked` з відповідним повідомленням.
    *   Зберігає оновлений профіль користувача.
*   **`checkProfileSetupCompletionAchievements` (Firestore v2 Trigger - `onDocumentWritten` на `users/{userId}`):**
    *   Спрацьовує при створенні або оновленні документа користувача.
    *   Перевіряє, чи поле `profileSetupComplete` змінилося з `false` (або не існувало) на `true`.
    *   **Ачівка "Early Bird"**: Якщо умова виконана і `AchievementId.EARLY_BIRD` ще немає в `achievedRewardIds`, додає її та створює сповіщення типу `achievementUnlocked`.
*   **`seedPredefinedExercises` (HTTPS v2 Trigger - `onRequest`):**
    *   Дозволяє заповнити колекцію `predefinedExercises` початковим набором вправ.
    *   Дані вправ зберігаються безпосередньо у коді функції (`predefinedExercisesData`).
    *   **Захист (опціонально):** Може перевіряти параметр `key` у запиті та порівнювати його зі значенням змінної середовища `APP_ADMIN_KEY` або `ADMIN_KEY` для авторизації. Якщо ключ не надано або невірний, запит відхиляється (якщо змінна середовища встановлена). Якщо змінна середовища не встановлена, функція виконується без перевірки ключа (з попередженням у логах).
    *   Перед додаванням перевіряє наявність вправи з таким же `normalizedName`, щоб уникнути дублікатів.

## 9. Налаштування та Запуск Проєкту

1.  **Встановлення Flutter:** Переконайтеся, що у вас встановлено Flutter SDK актуальної версії (згідно `environment: sdk: ^3.8.0` в `pubspec.yaml`).
2.  **Клонування Репозиторію:** Склонуйте цей репозиторій на ваш локальний комп'ютер.
3.  **Налаштування Проєкту Firebase:**
    *   Створіть новий проєкт у [Firebase Console](https://console.firebase.google.com/).
    *   Додайте Android та/або iOS додатки до вашого Firebase проєкту.
        *   **Android:** Використовуйте `com.example.muscle_up` як Package Name (або змініть його в `android/app/build.gradle.kts` та Firebase). Завантажте `google-services.json` та розмістіть його в `android/app/`.
        *   **iOS:** Використовуйте `com.example.muscleUp` як Bundle ID (або змініть його в Xcode та Firebase). Завантажте `GoogleService-Info.plist` та розмістіть його в `ios/Runner/`.
    *   **Автентифікація:** У Firebase Console увімкніть методи входу: Email/Password та Google.
    *   **Cloud Firestore:** Увімкніть Cloud Firestore. На початковому етапі можна використовувати тестові правила безпеки, але для продакшену їх потрібно посилити:
        ```firestore.rules
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            match /users/{userId} {
              allow read, write: if request.auth != null && request.auth.uid == userId;
              match /notifications/{notificationId} {
                allow read, write: if request.auth != null && request.auth.uid == userId;
              }
              match /workoutLogs/{sessionId} {
                allow read, write: if request.auth != null && request.auth.uid == userId;
              }
            }
            match /predefinedExercises/{exerciseId} {
              allow read: if true; // Дозволити читання для всіх (або if request.auth != null;)
              allow write: if false; // Заборона запису з клієнта (керується адмінкою/функціями)
            }
            match /userRoutines/{routineId} {
              allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
              // Для публічних рутин правила можуть бути складнішими
            }
          }
        }
        ```
    *   **Firebase Functions:**
        *   Перейдіть у директорію `functions`.
        *   Встановіть Firebase CLI: `npm install -g firebase-tools` (якщо ще не встановлено).
        *   Увійдіть: `firebase login`.
        *   Виберіть проєкт: `firebase use muscle-up-8c275` (замість `muscle-up-8c275` вкажіть ID вашого Firebase проєкту).
        *   Встановіть залежності: `cd functions && npm install && cd ..`.
        *   Для розгортання функцій: `firebase deploy --only functions`.
        *   **Важливо:** Для роботи функцій, що взаємодіють з Firestore від імені адміністратора, Firebase автоматично використовує сервісний акаунт. Файл `muscle-up-8c275-firebase-adminsdk-fbsvc-11c7f57ecf.json` (або схожий) у директорії `functions/` є ключем сервісного акаунту. **Ніколи не публікуйте цей файл у відкритому доступі!** Для `populatedb.js` (якщо використовується локально) шлях до нього має бути правильним. Для розгорнутих функцій, цей ключ не потрібен у коді, Firebase використовує стандартний сервісний акаунт середовища виконання функцій.
        *   Для HTTP-функції `seedPredefinedExercises` (якщо використовується захист ключем), встановіть змінну середовища: `firebase functions:config:set app.admin_key="YOUR_SECRET_KEY"` та розгорніть функції.
4.  **Залежності Flutter:** Виконайте `flutter pub get` в кореневій директорії проєкту.
5.  **Іконки Запуску:** (Опціонально) Якщо ви змінили `assets/images/app_icon.png`, згенеруйте нові іконки: `flutter pub run flutter_launcher_icons`.
6.  **Запуск Додатку:** Запустіть додаток на емуляторі або фізичному пристрої: `flutter run`.
7.  **Початкове Заповнення Бази Даних Вправ:**
    *   Після розгортання функції `seedPredefinedExercises`, ви можете викликати її через браузер або `curl`, додавши параметр `?key=YOUR_SECRET_KEY` (якщо ключ налаштовано). Наприклад: `https://<region>-<project-id>.cloudfunctions.net/seedPredefinedExercises?key=YOUR_SECRET_KEY`.

## 10. Подальший Розвиток

Плани на майбутнє включають розширення функціоналу для створення повноцінної соціальної фітнес-платформи:

*   **Повноцінна реалізація екранів "Posts", "Progress", "Profile"** згідно з дизайн-документом (графіки прогресу, стрічка активності, детальна статистика).
*   **Соціальні Функції:** Система підписок, коментарі, лайки, приватні повідомлення.
*   **Система Публічних Рекордів:** Механізм подачі заявок на рекорди, валідація спільнотою.
*   **Розширена Гейміфікація:** Більше ачівок, ліги, змагання, лідерборди.
*   **Деталізоване Налаштування Цілей:** Різні типи цілей (наприклад, на вагу, на кількість повторень, на об'єм) з автоматичним відстеженням прогресу.
*   **Push-сповіщення** через Firebase Cloud Messaging для нагадувань, нових ачівок, соціальних взаємодій.
*   **Розширене тестування**: Unit, Widget та Integration тести для всіх ключових компонентів.
*   **Покращення UI/UX** на основі відгуків користувачів.
*   **Адміністративна панель** для керування контентом (`predefinedExercises`, модерація тощо).
*   **Інтеграція з wearable-пристроями.**