# MuscleUP: Фітнес-застосунок нового покоління

**Motto:** Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

## 1. Вступ

**MuscleUP** – це мобільний фітнес-застосунок, розроблений для вирішення проблеми високого відсотку відмов користувачів від фітнес-додатків. Наша мета – створити надзвичайно мотивуюче, соціально інтерактивне та гейміфіковане середовище, яке сприятиме довгостроковій залученості. MuscleUP дає користувачам змогу детально відстежувати тренування, встановлювати та досягати персоналізовані фітнес-цілі, ділитися своїм прогресом та отримувати підтримку від спільноти.

Цей документ описує поточний стан проєкту, ключову бізнес-логіку, архітектуру програмного забезпечення та дизайн бекенду, з акцентом на модульність, масштабованість та простоту підтримки.

## 2. Поточний стан проєкту (Версія ~0.3.x - з трекінгом тренувань та RPE)

На даному етапі реалізовано наступний ключовий функціонал:

*   **Автентифікація та Профіль:**
    *   Реєстрація та вхід за допомогою Email/Password та Google Sign-In.
    *   Створення початкового профілю користувача в Cloud Firestore (`profileSetupComplete: false`).
    *   Екран "Profile Setup" (`ProfileSetupScreen`) для введення детальної інформації (username, стать, дата народження, зріст, вага, фітнес-цілі, рівень активності).
    *   Динамічне оновлення профілю користувача в реальному часі за допомогою `UserProfileCubit`.
*   **Головний Екран та Навігація (`HomePage`):**
    *   Центральний AppBar з назвою "MuscleUP".
    *   BottomNavigationBar для навігації між розділами: Routines, Explore (зараз показує ExerciseExplorerScreen), Progress (плейсхолдер), Profile (плейсхолдер).
    *   FloatingActionButton "START WORKOUT" на вкладці Dashboard для початку нового або продовження активного тренування.
*   **Дашборд (`DashboardScreen`):**
    *   Привітання користувача (з `UserProfileCubit`).
    *   Відображення базової статистики (вага, стрік тренувань - частково плейсхолдери).
    *   **Секція Сповіщень:**
        *   Заголовок "NOTIFICATIONS" з лічильником непрочитаних сповіщень.
        *   Список останніх сповіщень (`NotificationListItem`) з іконкою типу, заголовком, текстом, часом.
        *   Візуальне виділення непрочитаних сповіщень.
        *   Можливість видалення сповіщення свайпом.
        *   Кнопка "READ ALL" для позначення всіх сповіщень як прочитаних.
        *   Перехід на детальний екран сповіщення (`NotificationDetailScreen`) при тапі, з позначенням як прочитане.
        *   Можливість генерації тестових сповіщень.
*   **Бібліотека Вправ (`ExerciseExplorerScreen`):**
    *   Перегляд списку стандартизованих вправ з Firestore.
    *   Можливість використання в режимі вибору вправи (наприклад, для додавання в рутину).
*   **Керування Рутинами Тренувань:**
    *   Екран `UserRoutinesScreen` для перегляду списку користувацьких рутин.
    *   Створення (`CreateEditRoutineScreen`), редагування та видалення рутин.
    *   Додавання вправ до рутини з `ExerciseExplorerScreen` через діалог `AddExerciseToRoutineDialog`.
    *   Встановлення назви, опису, днів тижня для рутини.
    *   Редагування кількості сетів та нотаток для кожної вправи в рутині.
*   **Трекінг Тренувань (`ActiveWorkoutScreen`):**
    *   **Початок тренування:** Можливість почати тренування на основі обраної рутини або як порожнє тренування.
    *   **Активна сесія:** Якщо є незавершене тренування, воно автоматично завантажується.
    *   **Інтерфейс логування сету (`CurrentSetDisplay`):**
        *   Відображення назви поточної вправи, номеру сету.
        *   Введення ваги для сету (з можливістю редагування через діалог).
        *   Кнопки "+"/"-" для зміни кількості виконаних повторень.
        *   **Унікальна фіча: RPE (Rate of Perceived Exertion) слайдери для кожного повторення.** Користувач може оцінити складність кожного окремого повторення в сеті за шкалою 0-10.
        *   Навігація "PREV. SET" / "NEXT SET" / "NEXT EXERCISE".
    *   **Завершення/Скасування тренування:**
        *   Можливість скасувати тренування (з підтвердженням).
        *   Можливість завершити тренування (з підтвердженням).
    *   **Екран Завершення Тренування (`WorkoutCompleteScreen`):**
        *   Відображається після успішного завершення тренування.
        *   Анімація з Lottie (трофей) та конфетті.
        *   Відображення назви рутини, тривалості, загального об'єму.
        *   **Нарахування XP:** Розрахунок та відображення отриманого досвіду (XP).
        *   **Прогрес-бар XP:** Анімоване заповнення шкали XP до наступного рівня.
        *   Відображення інформації про перехід на новий рівень (якщо відбувся).
        *   Оновлення стріку тренувань та `lastWorkoutTimestamp` в профілі користувача.
*   **Модуль Сповіщень (`features/notifications`):**
    *   Модель `AppNotification` та `NotificationType`.
    *   `NotificationRepository` для взаємодії з Firestore (отримання, позначення як прочитаних, видалення).
    *   `NotificationsCubit` для управління станом сповіщень та оновленням UI.
*   **Архітектура та Стан:**
    *   Використання Flutter BLoC/Cubit для управління станом.
    *   Чітке розділення на шари (Domain, Data, Presentation) в рамках модулів.
    *   Репозиторії для взаємодії з джерелами даних.
    *   Використання `equatable` для моделей та станів.

## 3. Ключові Архітектурні Принципи

Проєкт дотримується принципів, описаних в Дизайн-Документі (Версія 2):

*   **Модульність:** Розробка за принципом "feature-first".
*   **Чітке Розділення Відповідальностей:** Використання шарів (Domain, Data, Presentation).
*   **Управління Станом:** Застосування Flutter BLoC/Cubit.
*   **Залежності:** Використання `RepositoryProvider` для надання залежностей.
*   **Масштабованість:** Архітектура передбачає легке додавання нових функцій.

## 4. Технологічний Стек

*   **Фронтенд:**
    *   **Framework:** Flutter (`^3.8.0` Dart SDK, згідно `pubspec.yaml`)
    *   **Мова:** Dart
    *   **Управління станом:** Flutter BLoC/Cubit (`flutter_bloc: ^9.1.1`, `bloc: ^9.0.0`)
    *   **Порівняння об'єктів:** Equatable (`equatable: ^2.0.5`)
    *   **Форматування дати/часу:** `intl: ^0.19.0`
    *   **Анімації:**
        *   `animated_background: ^2.0.0` (для сторінки логіну `LavaLampBackground`)
        *   `confetti: ^0.7.0` (для екрану завершення тренування)
        *   `lottie: ^3.1.2` (для екрану завершення тренування - анімація трофею)
    *   **Навігація:** Стандартна Flutter навігація (`MaterialPageRoute`, `Navigator.push/pop/pushAndRemoveUntil`).
*   **Бекенд (Firebase):**
    *   **Firebase Core:** `firebase_core: ^3.13.1`
    *   **Firebase Authentication:** `firebase_auth: ^5.5.4` (Email/Password, Google Sign-In)
    *   **Google Sign-In:** `google_sign_in: ^6.2.1`
    *   **Cloud Firestore:** `cloud_firestore: ^5.6.8` (База даних для профілів, рутин, вправ, сповіщень, логів тренувань).
*   **Інструменти розробки:**
    *   **Лінтер:** `flutter_lints: ^5.0.0`
    *   **Іконки запуску:** `flutter_launcher_icons: ^0.13.1`

## 5. Структура Проєкту (`lib/`)

Структура проєкту організована за принципом "feature-first", де кожна основна функціональність винесена в окремий модуль.

```
muscle_up/
├── lib/
│   ├── main.dart                     # Точка входу, ініціалізація Firebase, MaterialApp, RepositoryProviders
│   ├── auth_gate.dart                # Керує потоком автентифікації та перевіркою profileSetupComplete
│   ├── firebase_options.dart         # Конфігурація Firebase (згенеровано)
│   ├── home_page.dart                # ГОЛОВНИЙ ЕКРАН: AppBar, BottomNavigationBar, FAB, керування вкладками. Надає NotificationsCubit.
│   ├── login_page.dart               # Екран входу/реєстрації, анімований фон
│   │
│   ├── core/                         # Спільна бізнес-логіка, моделі та інтерфейси
│   │   └── domain/
│   │       ├── entities/             # Об'єкти домену (POJO/PODO)
│   │       │   ├── app_notification.dart # Модель для сповіщення
│   │       │   ├── logged_exercise.dart  # Модель для залогованої вправи в сесії
│   │       │   ├── logged_set.dart       # Модель для залогованого сету
│   │       │   ├── predefined_exercise.dart # Модель для стандартизованої вправи
│   │       │   ├── routine.dart          # Моделі UserRoutine та RoutineExercise
│   │       │   ├── user_profile.dart   # Модель для профілю користувача
│   │       │   └── workout_session.dart  # Модель для сесії тренування
│   │       └── repositories/           # Абстрактні інтерфейси для репозиторіїв
│   │           ├── notification_repository.dart
│   │           ├── predefined_exercise_repository.dart
│   │           ├── routine_repository.dart
│   │           ├── user_profile_repository.dart
│   │           └── workout_log_repository.dart
│   │
│   ├── features/                     # Кожен модуль фічі
│   │   ├── dashboard/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── dashboard_screen.dart # UI для дашборду (вміст для HomePage). Відображає сповіщення.
│   │   │
│   │   ├── exercise_explorer/
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── predefined_exercise_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── exercise_explorer_cubit.dart
│   │   │       │   └── exercise_explorer_state.dart
│   │   │       ├── screens/
│   │   │       │   └── exercise_explorer_screen.dart
│   │   │       └── widgets/
│   │   │           └── exercise_list_item.dart
│   │   │
│   │   ├── notifications/
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── notification_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── notifications_cubit.dart
│   │   │       │   └── notifications_state.dart
│   │   │       ├── screens/
│   │   │       │   └── notification_detail_screen.dart # Детальний екран сповіщення
│   │   │       └── widgets/
│   │   │           └── notification_list_item.dart # Віджет для одного сповіщення
│   │   │
│   │   ├── profile/                  # Модуль, що відповідає за відображення профілю (поки що лише UserProfileCubit)
│   │   │   └── presentation/
│   │   │       └── cubit/
│   │   │           ├── user_profile_cubit.dart
│   │   │           └── user_profile_state.dart
│   │   │
│   │   ├── profile_setup/            # Модуль налаштування профілю після реєстрації
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── user_profile_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── profile_setup_cubit.dart
│   │   │       │   └── profile_setup_state.dart
│   │   │       └── screens/
│   │   │           └── profile_setup_screen.dart
│   │   │
│   │   ├── routines/                 # Модуль керування рутинами
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── routine_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── manage_routine_cubit.dart # Для створення/редагування
│   │   │       │   ├── manage_routine_state.dart
│   │   │       │   ├── user_routines_cubit.dart  # Для списку рутин
│   │   │       │   └── user_routines_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── create_edit_routine_screen.dart
│   │   │       │   └── user_routines_screen.dart
│   │   │       └── widgets/
│   │   │           ├── add_exercise_to_routine_dialog.dart
│   │   │           └── routine_list_item.dart
│   │   │
│   │   └── workout_tracking/         # Модуль трекінгу тренувань
│   │       ├── data/
│   │       │   └── repositories/
│   │       │       └── workout_log_repository_impl.dart
│   │       └── presentation/
│   │           ├── cubit/
│   │           │   ├── active_workout_cubit.dart
│   │           │   └── active_workout_state.dart
│   │           ├── screens/
│   │           │   ├── active_workout_screen.dart
│   │           │   └── workout_complete_screen.dart
│   │           └── widgets/
│   │               └── current_set_display.dart # Віджет для логування сету з RPE
│   │
│   ├── utils/                        # Утиліти
│   │   └── duration_formatter.dart   # Форматування тривалості
│   │
│   └── widgets/                      # Загальні віджети
│       └── lava_lamp_background.dart # Анімований фон для LoginPage
│
├── assets/
│   ├── animations/
│   │   └── trophy_animation.json     # Lottie анімація для WorkoutCompleteScreen
│   ├── fonts/                        # Шрифти (Inter, IBMPlexMono)
│   └── images/                       # Зображення (google_logo.png, app_icon.png)
│
├── android/                          # Специфічний для Android код
├── ios/                              # Специфічний для iOS код
└── web/                              # Специфічний для Web код (базовий)
```

## 6. Детальний Опис Ключових Компонентів та UX

### 6.1. Автентифікація та Налаштування Профілю

*   **`LoginPage`**: Перший екран для неавтентифікованих користувачів. Має анімований фон "лавової лампи" (`LavaLampBackground`). Надає форми для входу та реєстрації через Email/Password, а також кнопку "Sign in with Google". При успішній новій реєстрації викликає `_createInitialUserProfile` для створення базового документа користувача в Firestore з `profileSetupComplete: false`.
*   **`AuthGate`**: Слухає зміни стану автентифікації. Якщо користувач автентифікований, перевіряє поле `profileSetupComplete` з Firestore через `UserProfileRepository`.
    *   Якщо `profileSetupComplete == false`, користувач направляється на `ProfileSetupScreen`.
    *   Якщо `profileSetupComplete == true`, користувач направляється на `HomePage`.
    *   Для вже автентифікованих користувачів, `AuthGate` надає `UserProfileCubit` для `HomePage`.
*   **`ProfileSetupScreen`**: Форма для введення детальної інформації: username (обов'язково), display name, стать, дата народження, зріст, вага, фітнес-ціль, рівень активності. Використовує `ProfileSetupCubit` для управління даними форми та збереження їх в Firestore. Після успішного збереження `profileSetupComplete` встановлюється в `true`, і користувач перенаправляється на `HomePage`.
*   **`UserProfileCubit`**: Глобальний кубіт, доступний в `HomePage` та її дочірніх віджетах. Завантажує та надає дані `UserProfile`, слухає зміни профілю в реальному часі.

### 6.2. Головний Екран (`HomePage` та `DashboardScreen`)

*   **`HomePage`**: Є Stateful віджетом, що містить `AppBar`, `BottomNavigationBar` та `FloatingActionButton`.
    *   `AppBar`: Заголовок "MuscleUP", клікабельний для переходу на дашборд.
    *   `BottomNavigationBar`: Дозволяє перемикатися між основними розділами: "ROUTINES" (`UserRoutinesScreen`), "EXPLORE" (`ExerciseExplorerScreen`), "PROGRESS" (плейсхолдер), "PROFILE" (плейсхолдер).
    *   `FloatingActionButton`: Текст "START WORKOUT" з іконкою. Відображається тільки на вкладці дашборду. При натисканні:
        *   Перевіряє наявність активної сесії тренування через `WorkoutLogRepository`.
        *   Якщо є активна сесія, переходить на `ActiveWorkoutScreen` для її продовження.
        *   Якщо немає, показує діалог з опціями "From Routine" (перехід на `UserRoutinesScreen`) або "Empty Workout" (перехід на `ActiveWorkoutScreen` без рутини).
    *   Надає `NotificationsCubit` для дочірніх віджетів.
*   **`DashboardScreen`**: Вміст для головної вкладки `HomePage`.
    *   Відображає персоналізоване привітання та іконку "вогника" зі стріком тренувань (дані з `UserProfileCubit`).
    *   Секція "STATS": Плейсхолдер для графіка "Total Volume" та відображення статистики "WEIGHT", "STREAK", "ADHERENCE" (частково плейсхолдери).
    *   **Секція "NOTIFICATIONS"**:
        *   Заголовок та лічильник непрочитаних сповіщень.
        *   Кнопка "READ ALL" (шрифт IBM Plex Mono), якщо є непрочитані.
        *   Список останніх сповіщень (`NotificationListItem`). Кожен елемент можна свайпнути для видалення. При тапі – перехід на `NotificationDetailScreen` та позначення як прочитане.
        *   Кнопка для генерації тестових сповіщень.
    *   Навігаційні елементи (привітання, вогник) можуть переводити на відповідні екрани (Profile, Progress) при тапі.

### 6.3. Сповіщення (`features/notifications`)

*   **`AppNotification`**: Модель даних для сповіщення (id, тип, заголовок, повідомлення, час, чи прочитано, пов'язані сутності, іконка). `NotificationType` – enum (досягнення, нагадування, системне тощо).
*   **`NotificationRepositoryImpl`**: Реалізація для Firestore. Сповіщення зберігаються в підколекції `users/{userId}/notifications`.
*   **`NotificationsCubit`**: Керує списком сповіщень, лічильником непрочитаних. Підписується на зміни в Firestore. Методи: `markNotificationAsRead`, `markAllNotificationsAsRead`, `deleteNotification`.
*   **`NotificationListItem`**: Віджет для відображення одного сповіщення. Використовує `Dismissible` для видалення.
*   **`NotificationDetailScreen`**: Детальний перегляд сповіщення.

### 6.4. Бібліотека Вправ (`features/exercise_explorer`)

*   **`PredefinedExercise`**: Модель стандартизованої вправи.
*   **`PredefinedExerciseRepositoryImpl`**: Завантажує список вправ з колекції `predefinedExercises` в Firestore.
*   **`ExerciseExplorerCubit`**: Завантажує та надає список вправ.
*   **`ExerciseExplorerScreen`**: Відображає список вправ (`ExerciseListItem`). Має режим `isSelectionMode` для вибору вправи (наприклад, при додаванні до рутини), в якому повертає обрану `PredefinedExercise`.

### 6.5. Керування Рутинами (`features/routines`)

*   **`UserRoutine`, `RoutineExercise`**: Моделі для рутин та вправ у них.
*   **`RoutineRepositoryImpl`**: CRUD операції для рутин в колекції `userRoutines` Firestore.
*   **`UserRoutinesCubit`**: Завантажує та надає список рутин користувача.
*   **`ManageRoutineCubit`**: Керує створенням та редагуванням окремої рутини.
*   **`UserRoutinesScreen`**: Відображає список рутин користувача (`RoutineListItem`). Має FAB для створення нової рутини.
*   **`CreateEditRoutineScreen`**: Форма для створення/редагування рутини. Дозволяє вказати назву, опис, дні тижня. Вправи додаються через `AddExerciseToRoutineDialog`. Кількість сетів та нотатки для вправ можна редагувати.
*   **`RoutineListItem`**: Відображає рутину. Має PopupMenu для опцій "Start Workout", "Edit", "Delete".
*   **`AddExerciseToRoutineDialog`**: Діалог, що використовує `ExerciseExplorerScreen` в режимі вибору для додавання вправи до рутини, з наступним введенням кількості сетів та нотаток.

### 6.6. Трекінг Тренувань (`features/workout_tracking`)

*   **Сутності**: `WorkoutSession`, `LoggedExercise`, `LoggedSet`.
*   **`WorkoutLogRepositoryImpl`**: Керує сесіями тренувань в підколекції `users/{userId}/workoutLogs`. Реалізує логіку старту, оновлення, завершення, скасування сесій. Надає стрім для активної сесії.
*   **`ActiveWorkoutCubit`**:
    *   При ініціалізації підписується на активну сесію.
    *   `startNewWorkout`: Створює нову `WorkoutSession`. Якщо передано `UserRoutine`, копіює вправи та сети з неї. Зберігає в Firestore.
    *   `updateLoggedSet`: Оновлює дані конкретного сету (вага, повторення, RPE, нотатки) в локальному стані та в Firestore.
    *   `addSetToExercise`: Додає новий порожній сет до вправи.
    *   `completeWorkout`: Завершує сесію, розраховує тривалість, загальний об'єм. Оновлює XP та стрік користувача в `UserProfile`.
    *   `cancelWorkout`: Скасовує сесію.
    *   Керує таймером тривалості тренування.
*   **`ActiveWorkoutScreen`**:
    *   При відкритті, якщо передано `routineForNewWorkout`, ініціює створення нової сесії через кубіт. В іншому випадку, кубіт сам завантажить активну сесію, якщо вона є.
    *   Відображає назву рутини (або "Active Workout"), таймер.
    *   Центральний елемент – `CurrentSetDisplay`.
    *   Кнопки навігації між сетами/вправами та кнопка завершення тренування.
*   **`CurrentSetDisplay`**:
    *   Відображає назву поточної вправи, номер сету, цільову кількість сетів.
    *   Поле для введення ваги (редагується через діалог).
    *   **Унікальна UX фіча: RPE слайдери.** Після встановлення кількості повторень (кнопки "+"/"-") з'являється відповідна кількість вертикальних RPE слайдерів (0-10). Користувач оцінює складність кожного повторення. Це дозволяє детально аналізувати навантаження.
    *   Збереження даних сету відбувається при переході до наступного/попереднього сету або при завершенні тренування.
*   **`WorkoutCompleteScreen`**:
    *   Відображається після успішного завершення тренування (навігація з `ActiveWorkoutScreen` через `ActiveWorkoutCubit` стан `ActiveWorkoutSuccessfullyCompleted`).
    *   Lottie анімація "трофею" та конфетті.
    *   Сумарна інформація: назва рутини, тривалість, об'єм.
    *   Відображення нарахованого XP та анімований прогрес-бар XP до наступного рівня.
    *   Якщо відбувся Level Up, це також відображається.
    *   Кнопка "Awesome!" для повернення на головний екран (`AuthGate` -> `HomePage`).

### 6.7. Якість Життя (Quality of Life) та UX Деталі

*   **Анімований фон `LavaLampBackground`** на `LoginPage` для приємного першого враження.
*   **Деталізована тема** в `main.dart` з використанням кастомних шрифтів `Inter` та `IBMPlexMono` для різних елементів UI, що створює узгоджений вигляд.
*   **Інтуїтивна навігація** між сетами та вправами в `ActiveWorkoutScreen`.
*   **Чіткі діалоги підтвердження** для видалення або скасування дій.
*   **Візуальний фідбек** при збереженні, помилках (через `SnackBar`).
*   **Обробка станів завантаження** з `CircularProgressIndicator`.
*   **RPE слайдери** для кожного повторення – унікальна фіча, що дозволяє глибоко аналізувати тренування.
*   **Анімації на екрані завершення тренування** (`confetti`, `lottie`, анімований XP бар) для позитивного підкріплення.
*   **Логування дій розробника** за допомогою `dart:developer` для полегшення налагодження.
*   **Іконки запуску** налаштовані через `flutter_launcher_icons`.
*   **Автоматичне оновлення UI** завдяки Flutter BLoC та стрімам з Firestore.
*   **Режим вибору вправ** в `ExerciseExplorerScreen` для зручного додавання в рутини.
*   **Форматування тривалості** тренування за допомогою `duration_formatter.dart`.

## 7. Структура Бекенду (Firebase Cloud Firestore)

Базуючись на реалізованих сутностях та репозиторіях:

*   **`users/{userId}`**:
    *   Зберігає дані з `UserProfile` (uid, email, displayName, profilePictureUrl, username, gender, dateOfBirth, heightCm, weightKg, fitnessGoal, activityLevel, xp, level, currentStreak, longestStreak, lastWorkoutTimestamp, profileSetupComplete, createdAt, updatedAt).
    *   **Підколекція `notifications/{notificationId}`**:
        *   Зберігає дані `AppNotification` (type, title, message, timestamp, isRead, iconName, relatedEntityId, relatedEntityType).
    *   **Підколекція `workoutLogs/{sessionId}`**:
        *   Зберігає дані `WorkoutSession` (userId, routineId, routineNameSnapshot, startedAt, endedAt, durationSeconds, completedExercises, notes, status, totalVolume).
        *   `completedExercises`: список мап, кожна з яких представляє `LoggedExercise` (predefinedExerciseId, exerciseNameSnapshot, targetSets, completedSets, notes).
        *   `completedSets`: список мап, кожна з яких представляє `LoggedSet` (setNumber, weightKg, reps, isCompleted, notes - включаючи RPE_DATA).
*   **`predefinedExercises/{exerciseId}`**:
    *   Зберігає дані `PredefinedExercise` (name, normalizedName, primaryMuscleGroup, secondaryMuscleGroups, equipmentNeeded, description, videoDemonstrationUrl, difficultyLevel, tags).
*   **`userRoutines/{routineId}`**:
    *   Зберігає дані `UserRoutine` (userId, name, description, exercises, scheduledDays, isPublic, createdAt, updatedAt).
    *   `exercises`: список мап, кожна з яких представляє `RoutineExercise` (predefinedExerciseId, exerciseNameSnapshot, numberOfSets, notes).

## 8. Налаштування та Запуск Проєкту

1.  Переконайтеся, що у вас встановлено Flutter SDK актуальної версії (збігається з `environment: sdk: ^3.8.0` в `pubspec.yaml`).
2.  Склонуйте репозиторій.
3.  Налаштуйте проєкт Firebase:
    *   Створіть проєкт в Firebase Console.
    *   Додайте Android та/або iOS додатки до вашого Firebase проєкту.
    *   Завантажте конфігураційні файли `google-services.json` (для Android) та `GoogleService-Info.plist` (для iOS) та розмістіть їх у відповідних директоріях (`android/app/` та `ios/Runner/`).
    *   Переконайтеся, що Bundle ID (для iOS) та Package Name (для Android) у вашому Flutter проєкті співпадають з тими, що вказані в Firebase.
    *   Увімкніть Firebase Authentication (Email/Password, Google).
    *   Увімкніть Cloud Firestore та налаштуйте правила безпеки (на початковому етапі можна використовувати тестові правила, але для продакшену їх потрібно посилити).
4.  Виконайте `flutter pub get` для завантаження залежностей.
5.  Для генерації іконок запуску (якщо потрібно змінити `app_icon.png`): `flutter pub run flutter_launcher_icons`.
6.  Запустіть додаток на емуляторі або фізичному пристрої: `flutter run`.

## 9. Подальший Розвиток (згідно Дизайн-Документу та поточного стану)

*   **Повноцінна реалізація екранів "Posts", "Progress", "Profile"** згідно з дизайн-документом.
*   **Розширений Дашборд**: інтеграція реальних графіків та статистики.
*   **Соціальні Функції**: система підписок, стрічка активності, коментарі, лайки.
*   **Система Публічних Рекордів**: механізм заявки, валідації спільнотою.
*   **Гейміфікація**: розширення системи досягнень, ліги, лідерборди.
*   **Деталізоване Налаштування Цілей**: з типами цілей та автоматичним трекінгом.
*   **Firebase Cloud Functions**: для автоматизації розрахунків (об'єми, середнє RPE), оновлення статистики, генерації сповіщень.
*   **Push-сповіщення** через Firebase Cloud Messaging.
*   **Розширене тестування**: Unit, Widget, Integration тести.
*   **Покращення UI/UX** на основі фідбеку.
*   **Адмін-панель** для керування `predefinedExercises` та іншим контентом.
