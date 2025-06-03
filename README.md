Нижче наведена розширена та деталізована документація для проєкту MuscleUP, створена на основі наданого файлу README.md та аналізу кодової бази.

---

# MuscleUP: Детальна Документація Проєкту

**Девіз:** Піднімай Свої Ваги, Об'єднуй Команду, Досягай Цілей. Будуй Свою Силу, Разом.

## Зміст

1.  [Вступ](#1-вступ)
2.  [Поточний Стан Проєкту (Версія 0.4.x - Фаза Соціальних Функцій 3 Розпочата)](#2-поточний-стан-проекту-версія-04x---фаза-соціальних-функцій-3-розпочата)
3.  [Ключові Архітектурні Принципи](#3-ключові-архітектурні-принципи)
4.  [Технологічний Стек](#4-технологічний-стек)
5.  [Структура Проєкту](#5-структура-проекту)
6.  [Глибоке Занурення в Ключові Компоненти та UX](#6-глибоке-занурення-в-ключові-компоненти-та-ux)
    *   [6.1. Автентифікація та Налаштування Профілю](#61-автентифікація-та-налаштування-профілю)
    *   [6.2. Основна Навігація: `HomePage` та `DashboardScreen`](#62-основна-навігація-homepage-та-dashboardscreen)
    *   [6.3. Система Сповіщень](#63-система-сповіщень)
    *   [6.4. Бібліотека Вправ](#64-бібліотека-вправ)
    *   [6.5. Управління Тренувальними Рутинами](#65-управління-тренувальними-рутинами)
    *   [6.6. Відстеження Тренувань](#66-відстеження-тренувань)
    *   [6.7. Відстеження Прогресу (`ProgressScreen` та `ProgressCubit`)](#67-відстеження-прогресу-progressscreen-та-progresscubit)
    *   [6.8. Система Досягнень](#68-система-досягнень)
    *   [6.9. Соціальні Функції (Вкладка "Explore")](#69-соціальні-функції-вкладка-explore)
    *   [6.10. Якість Життя та Деталі UX](#610-якість-життя-та-деталі-ux)
7.  [Бекенд: Структура Firebase Cloud Firestore](#7-бекенд-структура-firebase-cloud-firestore)
8.  [Логіка Firebase Cloud Functions (`functions/src/index.ts`)](#8-логіка-firebase-cloud-functions-functionssrcindexts)
9.  [Налаштування та Запуск Проєкту](#9-налаштування-та-запуск-проекту)
10. [Дорожня Карта та Майбутній Розвиток](#10-дорожня-карта-та-майбутній-розвиток)

---

## 1. Вступ

MuscleUP — це інноваційний мобільний фітнес-додаток, розроблений для революціонізації вашого підходу до тренувань. Як зазначено в `pubspec.yaml`, це "Next-gen Fitness App. New height, New companions." Наша місія — створити високомотивуюче, соціально інтерактивне та гейміфіковане середовище, яке не тільки допомагає користувачам досягати своїх фітнес-цілей, але й робить процес приємним, сприяючи довгостроковій залученості. MuscleUP дозволяє детальне відстеження тренувань, персоналізоване встановлення цілей, аналіз прогресу за допомогою унікальних метрик (таких як RPE для кожного повторення), підтримку спільноти через обмін досягненнями та соціальну взаємодію через різні типи постів.

Цей документ надає всебічний огляд проєкту MuscleUP, деталізуючи його поточні функції, основну бізнес-логіку, програмну архітектуру, дизайн бекенду з Firebase та функціональність його компонентів. Він наголошує на модульності, масштабованості та легкості підтримки.

## 2. Поточний Стан Проєкту (Версія 0.4.x - Фаза Соціальних Функцій 3 Розпочата)

MuscleUP інкорпорував надійний набір ключових функцій і активно впроваджує розширені соціальні можливості, причому Фаза 3 (Розширені Типи Постів) вже розпочата. Поточна версія додатку, згідно з `pubspec.yaml`, — `0.1.0`.

**Ключові Реалізовані Функції:**

*   **Автентифікація та Профіль Користувача:**
    *   Безпечний вхід за допомогою Email/Пароль та Google Sign-In (забезпечується пакетами `firebase_auth: ^5.5.4` та `google_sign_in: ^6.2.1`). Реалізовано в `lib/login_page.dart`.
    *   Автоматичне створення початкового профілю (`profileSetupComplete: false`) через Firebase Function `createUserProfile` (тригер `onAuthUserCreate` в `functions/src/index.ts`).
    *   Спеціалізований екран `ProfileSetupScreen` (в `lib/features/profile_setup/presentation/screens/profile_setup_screen.dart`) для введення детальної інформації користувача (ім'я користувача, відображуване ім'я, стать, дата народження, зріст, вага, цілі, рівень активності) з можливістю редагування. Стан керується `ProfileSetupCubit`.
    *   Оновлення профілю користувача в реальному часі через `UserProfileCubit` (в `lib/features/profile/presentation/cubit/user_profile_cubit.dart`), який використовує `UserProfileRepository`.
    *   Автоматичне нагородження досягненням "Early Bird" після завершення налаштування профілю, кероване Firebase Function `checkProfileSetupCompletionAchievements` (тригер `onDocumentWritten` на `users/{userId}` в `functions/src/index.ts`).

*   **Основна Навігація та Панель Інструментів (`HomePage` та `DashboardScreen`):**
    *   Центральна панель AppBar в `lib/home_page.dart` з динамічними заголовками (наприклад, "MuscleUP | My Routines").
    *   `BottomNavigationBar` для навігації: Рутини, Explore (Пости), Прогрес, Профіль.
    *   FloatingActionButton "START WORKOUT" на `DashboardScreen` (в `lib/features/dashboard/presentation/screens/dashboard_screen.dart`) з інтелектуальною навігацією: відновлює активні сесії, переходить до списку рутин, якщо вони існують, або до створення рутини, якщо їх немає. Логіка використовує `WorkoutLogRepository` та `RoutineRepository`.
    *   `DashboardScreen`: Персоналізоване привітання, іконка серії тренувань, картки базової статистики (вага, серія, дотримання графіку), інтерактивна секція сповіщень та майбутній розклад на наступні 7 днів (`UpcomingScheduleWidget`). Статистика завантажується `DashboardStatsCubit`.

*   **Соціальні Функції (`lib/features/social` та `ExploreScreen`):**
    *   **Система Постів:**
        *   Сутність `Post` (в `lib/core/domain/entities/post.dart`) з деталями автора, часовою позначкою, переліком `PostType` (`standard`, `recordClaim`, `routineShare`), контентом, медіа (в майбутньому), масивом `likedBy`, лічильником `commentsCount`, `isCommentsEnabled`, `relatedRoutineId`, `routineSnapshot`, `recordDetails`, `isRecordVerified`.
        *   Колекція Firestore `posts` для всіх постів користувачів.
        *   `PostRepository` (інтерфейс в `lib/core/domain/repositories/post_repository.dart`, реалізація в `lib/features/social/data/repositories/post_repository_impl.dart`) для CRUD операцій та взаємодій.
    *   **Створення Стандартних Постів:**
        *   `CreatePostScreen` (в `lib/features/social/presentation/screens/create_post_screen.dart`) дозволяє користувачам писати та публікувати текстові пости.
        *   `CreatePostCubit` (в `lib/features/social/presentation/cubit/create_post_cubit.dart`) керує станом створення поста, вбудовуючи дані профілю автора.
        *   Автори можуть вмикати/вимикати коментарі до своїх постів під час створення.
    *   **НОВЕ: Створення Постів "Поділитися Рутиною":**
        *   Користувачі можуть ділитися рутинами з `RoutineListItem` через опцію "Share Routine", яка перенаправляє на `CreatePostScreen`.
        *   `CreatePostScreen` попередньо заповнює текст та встановлює тип поста на `routineShare`, додаючи `relatedRoutineId` та `routineSnapshot`.
    *   **НОВЕ: Створення Постів "Заявка на Рекорд":**
        *   `CreatePostScreen` дозволяє обрати тип поста "Record Claim".
        *   Інтерфейс для вибору вправи (через `ExerciseExplorerScreen`), введення ваги, повторень та опціонального URL відео.
        *   Дані зберігаються в полі `recordDetails` сутності `Post`.
        *   Функція `onRecordClaimPostCreated` (в `functions/src/index.ts`) встановлює дедлайн для голосування та початковий статус.
    *   **Стрічка "Explore" (`ExploreScreen`):**
        *   Основна стрічка на вкладці "Explore" (в `lib/features/social/presentation/screens/explore_screen.dart`), що відображає пости всіх користувачів (відсортовані за новизною).
        *   `ExploreFeedCubit` (в `lib/features/social/presentation/cubit/explore_feed_cubit.dart`) керує завантаженням та відображенням постів.
        *   Віджет `PostListItem` (в `lib/features/social/presentation/widgets/post_list_item.dart`) відображає окремі пости, динамічно адаптуючись для типів `standard`, `routineShare` та `recordClaim` за допомогою `PostCardContentWidget`.
    *   **Взаємодія з Постами (Лайки та Коментарі):**
        *   **Лайки:** Користувачі можуть лайкати/дизлайкати пости. Кількість лайків та статус лайка користувача керуються `PostInteractionCubit` (в `lib/features/social/presentation/cubit/post_interaction_cubit.dart`) та оновлюються в реальному часі.
        *   **Коментарі:**
            *   Сутність `Comment` (в `lib/core/domain/entities/comment.dart`) з деталями автора, текстом, часовою позначкою. Зберігаються в підколекції `comments` під кожним постом.
            *   `PostDetailScreen` (в `lib/features/social/presentation/screens/post_detail_screen.dart`) відображає повний пост та коментарі. Користувачі можуть додавати нові коментарі, якщо ввімкнено.
            *   `PostInteractionCubit` керує завантаженням, надсиланням, редагуванням та видаленням коментарів для конкретного поста.
            *   Автори можуть вмикати/вимикати коментарі до власних постів через `CreatePostScreen` або `PostDetailScreen` (меню дій).
            *   Cloud Functions `onCommentCreated` та `onCommentDeleted` (в `functions/src/index.ts`) оновлюють `commentsCount` на батьківському пості.
    *   **НОВЕ: Додавання Спільної Рутини до "Моїх Рутин":**
        *   `PostListItem` для постів типу `routineShare` містить кнопку "Add to My Routines".
        *   Використовує `RoutineRepository.copyRoutineFromSnapshot` для створення приватної копії спільної рутини для поточного користувача.

*   **НОВЕ: Голосування за Заявки на Рекорд:**
    *   `PostListItem` для постів `recordClaim` відображає поточний статус верифікації.
    *   Користувачі (крім автора поста) можуть голосувати "Validate" або "Unvalidate" (Dispute) на `PostDetailScreen` (якщо голосування активне).
    *   Логіка голосування керується `PostInteractionCubit`, який викликає `PostRepository.castVote` або `PostRepository.retractVote`.
    *   Firestore тригер `onRecordClaimVoteCasted` (в `functions/src/index.ts`) нараховує XP за голосування, якщо користувач ще не був нагороджений за голос під цим постом (зберігається в `votedAndRewardedUserIds` масиві в документі поста).
    *   Запланована функція `processRecordClaimDeadlines` (в `functions/src/index.ts`, запускається щогодини) перевіряє пости з типом `recordClaim`, у яких вийшов термін голосування (`recordVerificationDeadline`). Вона визначає результат голосування (на основі `MIN_VOTE_PERCENTAGE_FOR_VERIFICATION`), оновлює `recordVerificationStatus` та `isRecordVerified`. Якщо рекорд верифіковано, автору нараховується XP (`XP_FOR_RECORD_BASE` + бонус за об'єм) та видається досягнення `personalRecordSet`.

*   **Бібліотека Вправ (`ExerciseExplorerScreen`):**
    *   Перегляд стандартизованих вправ з колекції Firestore `predefinedExercises`. Кожна вправа представлена сутністю `PredefinedExercise` (в `lib/core/domain/entities/predefined_exercise.dart`).
    *   Використовується контекстно, наприклад, для додавання вправ до рутин або вибору вправи для поста `recordClaim`.
    *   Керується `ExerciseExplorerCubit` (в `lib/features/exercise_explorer/presentation/cubit/exercise_explorer_cubit.dart`). Дані завантажуються через `PredefinedExerciseRepository`.
    *   Початкове наповнення бази даних вправ можливе через HTTPS-тригер `seedPredefinedExercises` (в `functions/src/index.ts`).

*   **Управління Тренувальними Рутинами (`features/routines`):**
    *   `UserRoutinesScreen` (в `lib/features/routines/presentation/screens/user_routines_screen.dart`): Перегляд, створення, редагування, видалення та **спільний доступ** до власних рутин. Сутність `UserRoutine` (в `lib/core/domain/entities/routine.dart`).
    *   `CreateEditRoutineScreen` (в `lib/features/routines/presentation/screens/create_edit_routine_screen.dart`): Визначення назви рутини, опису, розкладу та додавання вправ через `AddExerciseToRoutineDialog`.

*   **Відстеження Тренувань (`ActiveWorkoutScreen`):**
    *   Початок тренувань з рутин або як порожніх сесій (в `lib/features/workout_tracking/presentation/screens/active_workout_screen.dart`).
    *   Автоматичне відновлення незавершених сесій при запуску додатку або через потік "START WORKOUT".
    *   `CurrentSetDisplay` (в `lib/features/workout_tracking/presentation/widgets/current_set_display.dart`): Логування ваги, повторень та унікальних повзунків RPE для кожного повторення (0-10).

*   **Завершення Тренування (`WorkoutCompleteScreen`):**
    *   Святковий екран (в `lib/features/workout_tracking/presentation/screens/workout_complete_screen.dart`) з анімацією трофею Lottie (`assets/animations/trophy_animation.json`) та ефектом конфетті (пакет `confetti: ^0.7.0`).
    *   Відображає зведення тренування, отриманий XP та інформацію про підвищення рівня.
    *   Автоматичне нагородження досягненням "First Workout" через Firebase Function `calculateAndAwardXpAndStreak` (тригер `onDocumentUpdated` на `users/{userId}/workoutLogs/{sessionId}` в `functions/src/index.ts`).

*   **Відстеження Прогресу (`ProgressScreen` та `ProgressCubit`):**
    *   `ProgressCubit` (в `lib/features/progress/presentation/cubit/progress_cubit.dart`) організовує дані для ліг, XP/рівня, карти м'язів та статистики тренувань.
    *   `LeagueTitleWidget` та `XPProgressBarWidget` (з анімованим заповненням).
    *   `MuscleMapWidget` (в `lib/features/progress/presentation/widgets/muscle_map_widget.dart`): Візуалізація об'єму м'язів на SVG-зображеннях, специфічних для статі (чоловіча: `assets/images/male_front.svg`, `assets/images/male_back.svg`; жіноча: `assets/images/female_front.svg`, `assets/images/female_back.svg`). Інтенсивність кольору залежить від кількості сетів за останні 7 днів.
    *   Статистика Тренувань: Тренд RPE та Тренд Робочої Ваги для кожної вправи за останні N тренувань (N = 15).

*   **Система Сповіщень (`features/notifications`):**
    *   Модель `AppNotification` (в `lib/core/domain/entities/app_notification.dart`) та перелік `NotificationType` (включаючи `advice`).
    *   `NotificationsCubit` (в `lib/features/notifications/presentation/cubit/notifications_cubit.dart`) керує оновленнями в реальному часі, лічильником непрочитаних сповіщень та сповіщеннями в додатку для досягнень та порад.
    *   `NotificationListItem` та `NotificationDetailScreen`.

*   **Firebase Cloud Functions (TypeScript, Node.js v20):**
    *   `createUserProfile`: Auth тригер (створення нового користувача).
    *   `calculateAndAwardXpAndStreak`: Firestore тригер (оновлення `workoutLogs`, коли статус стає "completed").
    *   `checkProfileSetupCompletionAchievements`: Firestore тригер (запис до `users`, коли `profileSetupComplete` стає true).
    *   `seedPredefinedExercises`: HTTPS тригер (для наповнення `predefinedExercises`).
    *   `onCommentCreated`: Firestore тригер (збільшує `commentsCount` на батьківському пості).
    *   `onCommentDeleted`: Firestore тригер (зменшує `commentsCount` на батьківському пості).
    *   **НОВЕ**: `onRecordClaimPostCreated`: Firestore тригер (встановлює дедлайн та статус для заявок на рекорд).
    *   **НОВЕ**: `onRecordClaimVoteCasted`: Firestore тригер (нараховує XP за голосування).
    *   **НОВЕ**: `processRecordClaimDeadlines`: Запланована функція (обробляє заявки на рекорд, що пройшли дедлайн).

*   **Система Досягнень:**
    *   Реалізовано "Early Bird" (налаштування профілю) та "First Workout". "Personal Record Set" (`personalRecordSet`) також додано до `AchievementId` та функції `processRecordClaimDeadlines`.
    *   Фреймворк для додавання нових досягнень (сутність `Achievement` в `lib/core/domain/entities/achievement.dart`).

## 3. Ключові Архітектурні Принципи

Проєкт MuscleUP дотримується сучасних найкращих практик розробки програмного забезпечення для забезпечення надійної, масштабованої та легкої в підтримці кодової бази:

*   **Модульність (Feature-First):** Додаток організовано у вигляді модулів, специфічних для функцій (наприклад, `profile`, `routines`, `social` всередині `lib/features/`), що сприяє розділенню відповідальностей та полегшує командну співпрацю.
*   **Чиста Архітектура (Багатошаровий підхід):** Хоча не суворо дотримується жорстких шарів, проєкт слідує концептуальному розділенню:
    *   **Презентація (Presentation):** Віджети, Екрани, Cubits/Blocs (наприклад, `ProfileScreen`, `UserProfileCubit`).
    *   **Домен (Domain):** Сутності (моделі даних, наприклад, `UserProfile` в `lib/core/domain/entities/user_profile.dart`), абстрактні Репозиторії (інтерфейси, наприклад, `UserProfileRepository` в `lib/core/domain/repositories/user_profile_repository.dart`), Варіанти Використання (Use Cases) (неявно через методи Cubit).
    *   **Дані (Data):** Реалізації Репозиторіїв (наприклад, `UserProfileRepositoryImpl` в `lib/features/profile_setup/data/repositories/user_profile_repository_impl.dart`), джерела даних (Firebase).
*   **Управління Станом (BLoC/Cubit):** `flutter_bloc` (`^9.1.1`) широко використовується для управління станом UI та бізнес-логікою, забезпечуючи передбачувані зміни стану та відокремлення від коду UI. Кожен модуль має свої Cubits (наприклад, `lib/features/routines/presentation/cubit/`).
*   **Впровадження Залежностей (DI):** `RepositoryProvider` (з `flutter_bloc`) використовується для надання екземплярів репозиторіїв вниз по дереву віджетів. Це конфігурується в `lib/main.dart`.
*   **Абстракція Даних (Репозиторії):** Репозиторії визначають контракти для операцій з даними, абстрагуючи джерела даних від доменного та презентаційного шарів.
*   **Масштабованість та Легкість Підтримки:** Модульна структура та чітке розділення відповідальностей розроблені для підтримки майбутнього зростання та полегшення розуміння та модифікації кодової бази.
*   **Тестованість:** Використання BLoC/Cubit та репозиторіїв полегшує модульне та віджетне тестування (хоча деталі тестів не включені в цей знімок).

## 4. Технологічний Стек

*   **Фронтенд:**
    *   **Фреймворк:** Flutter (версія SDK `^3.8.0` згідно `pubspec.yaml` та `.metadata`)
    *   **Мова:** Dart (версія SDK `^3.8.0` згідно `pubspec.yaml`)
    *   **Управління Станом:** `flutter_bloc: ^9.1.1`, `bloc: ^9.0.0`
    *   **Порівняння Об'єктів:** `equatable: ^2.0.5` (використовується в сутностях та станах BLoC)
    *   **Інтернаціоналізація та Форматування:** `intl: ^0.19.0` (для форматування дат, чисел)
    *   **Графіка та UI:**
        *   `flutter_svg: ^2.0.10+1` (для відображення SVG, наприклад, карт м'язів в `MuscleMapWidget`)
        *   `animated_background: ^2.0.0` (для анімованого фону `LavaLampBackground` на `LoginPage`)
        *   `confetti: ^0.7.0` (для ефекту конфетті на `WorkoutCompleteScreen`)
        *   `lottie: ^3.1.2` (для відтворення анімацій Lottie, наприклад, трофею на `WorkoutCompleteScreen`)
*   **Бекенд (Firebase):**
    *   **Ядро:** `firebase_core: ^3.13.1`
    *   **Автентифікація:** `firebase_auth: ^5.5.4`, `google_sign_in: ^6.2.1`
    *   **База Даних:** `cloud_firestore: ^5.6.8`
    *   **Безсерверні Функції:** Firebase Cloud Functions (TypeScript, середовище виконання Node.js 20, конфігурація в `functions/package.json` та `functions/tsconfig.json`)
*   **Розробка та Інструменти:**
    *   **ЛІнтинг:** `flutter_lints: ^5.0.0` (правила в `analysis_options.yaml`)
    *   **Іконки Додатку:** `flutter_launcher_icons: ^0.13.1` (конфігурація в `pubspec.yaml`)
    *   **Логування:** `dart:developer` (використовується в багатьох файлах для `developer.log`)
    *   **Ідентифікатор Проєкту Firebase:** `muscle-up-8c275` (з `.firebaserc` та `firebase.json`)

## 5. Структура Проєкту

Проєкт дотримується структури каталогів "feature-first" всередині папки `lib`.

```
muscle_up/
├── android/                            # Файли, специфічні для Android
├── assets/                             # Ресурси додатку
│   ├── animations/                     # Анімації Lottie (e.g., trophy_animation.json)
│   ├── fonts/                          # Власні шрифти (Inter, IBMPlexMono)
│   └── images/                         # Зображення (app_icon.png, SVG м'язів, etc.)
│       ├── app_icon.png
│       ├── male_front.svg
│       ├── male_back.svg
│       ├── female_front.svg
│       └── female_back.svg
├── functions/                          # Firebase Cloud Functions
│   ├── src/
│   │   └── index.ts                    # Основний файл Cloud Functions
│   ├── lib/                            # Скомпільований JavaScript (ігнорується git)
│   ├── .eslintrc.js
│   ├── package.json
│   ├── package-lock.json
│   └── tsconfig.json
├── ios/                                # Файли, специфічні для iOS
├── lib/
│   ├── auth_gate.dart                  # Обробляє стан автентифікації та перенаправлення на налаштування профілю
│   ├── firebase_options.dart           # Конфігурація проєкту Firebase (згенеровано)
│   ├── home_page.dart                  # Головний екран додатку з BottomNavigationBar
│   ├── login_page.dart                 # Екран автентифікації
│   ├── main.dart                       # Точка входу в додаток, ThemeData, RepositoryProviders
│   │
│   ├── core/                           # Основна бізнес-логіка та сутності
│   │   └── domain/
│   │       ├── entities/               # Моделі даних (Achievement, AppNotification, Comment, Post, UserProfile, UserRoutine etc.)
│   │       └── repositories/           # Абстрактні інтерфейси репозиторіїв
│   │
│   ├── features/                       # Модулі, специфічні для функцій
│   │   ├── dashboard/                  # Екран панелі інструментів та його специфічні віджети/кубіти
│   │   ├── exercise_explorer/          # Браузер бібліотеки вправ (використовується контекстно)
│   │   ├── notifications/              # Система сповіщень (кубіт, UI)
│   │   ├── profile/                    # Екран профілю користувача
│   │   ├── profile_setup/              # Екран створення/редагування профілю
│   │   ├── progress/                   # Екран відстеження прогресу (ліги, XP, статистика)
│   │   ├── routines/                   # Управління тренувальними рутинами
│   │   ├── social/                     # Соціальні функції (пости, коментарі, стрічка)
│   │   │   ├── data/
│   │   │   │   └── repositories/       # PostRepositoryImpl
│   │   │   └── presentation/
│   │   │       ├── cubit/              # CreatePostCubit, ExploreFeedCubit, PostInteractionCubit
│   │   │       ├── screens/            # CreatePostScreen, ExploreScreen, PostDetailScreen
│   │   │       └── widgets/            # PostListItem, CommentListItem, PostCardContentWidget
│   │   └── workout_tracking/           # Активна тренувальна сесія, екран завершення
│   │
│   ├── utils/                          # Утилітні функції (e.g., duration_formatter.dart)
│   └── widgets/                        # Загальні спільні віджети (e.g., lava_lamp_background.dart)
│
├── pubspec.yaml                        # Залежності проєкту та декларація ресурсів
├── README.md                           # Цей файл (вихідний)
└──                                     # Інші конфігураційні файли проєкту (.firebaserc, .gitignore)
```

## 6. Глибоке Занурення в Ключові Компоненти та UX

### 6.1. Автентифікація та Налаштування Профілю

*   **`LoginPage` (`lib/login_page.dart`):** Надає можливість реєстрації/входу за допомогою Email/Пароль та Google Sign-In. Використовує `LavaLampBackground` (з `lib/widgets/lava_lamp_background.dart`) для візуальної привабливості. Обробка форм та автентифікації відбувається всередині `_LoginPageState`.
*   **`AuthGate` (`lib/auth_gate.dart`):** Прослуховує зміни стану Firebase Auth (`FirebaseAuth.instance.authStateChanges()`).
    *   Якщо не автентифіковано, перенаправляє на `LoginPage`.
    *   Якщо автентифіковано, використовує `_ProfileCheckGate` для потокового отримання профілю користувача з Firestore за допомогою `UserProfileRepository.getUserProfileStream(userId)`.
    *   Якщо `profileSetupComplete` в профілі `false` (або профіль ще не існує після створення автентифікації, наприклад, через затримку Firestore), перенаправляє на `ProfileSetupScreen`.
    *   Якщо `profileSetupComplete` `true`, перенаправляє на `HomePage` і надає `UserProfileCubit`.
*   **`createUserProfile` (Cloud Function в `functions/src/index.ts`):** Спрацьовує при створенні нового користувача Firebase Auth. Ініціалізує базовий документ користувача в Firestore (`users/{userId}`) з `profileSetupComplete: false` та значеннями за замовчуванням (email, uid, createdAt, updatedAt).
*   **`ProfileSetupScreen` (`lib/features/profile_setup/presentation/screens/profile_setup_screen.dart`):** Дозволяє новим користувачам вводити основні дані профілю (ім'я користувача, відображуване ім'я, стать, дата народження, зріст, вага, фітнес-цілі, рівень активності). Також використовується для редагування існуючих профілів. Стан керується `ProfileSetupCubit`.
*   **`UserProfileCubit` (`lib/features/profile/presentation/cubit/user_profile_cubit.dart`):** Керує станом профілю поточного користувача, надаючи його відповідним частинам UI (наприклад, `DashboardScreen`, `ProfileScreen`). Підписується на оновлення в реальному часі через `UserProfileRepository.getUserProfileStream()`.
*   **`checkProfileSetupCompletionAchievements` (Cloud Function в `functions/src/index.ts`):** Спрацьовує при записі в документ `users/{userId}`. Якщо `profileSetupComplete` змінюється на `true`, нагороджує досягненням "Early Bird" (`AchievementId.earlyBird`) та надсилає сповіщення.

### 6.2. Основна Навігація: `HomePage` та `DashboardScreen`

*   **`HomePage` (`lib/home_page.dart`):** Головний екран після входу та налаштування профілю.
    *   **AppBar:** Динамічно відображає "MuscleUP" або "MuscleUP | НазваЕкрану" залежно від активної вкладки. Натискання на "MuscleUP" перенаправляє на `DashboardScreen`.
    *   **`BottomNavigationBar`:** Забезпечує навігацію до:
        1.  **Routines:** `UserRoutinesScreen`
        2.  **Explore:** `ExploreScreen` (Стрічка соціальних постів)
        3.  **Progress:** `ProgressScreen`
        4.  **Profile:** `ProfileScreen`
*   **`DashboardScreen` (`lib/features/dashboard/presentation/screens/dashboard_screen.dart`):** Вигляд за замовчуванням всередині `HomePage`.
    *   **FloatingActionButton ("START WORKOUT"):**
        *   Перевіряє наявність активної (незавершеної) тренувальної сесії за допомогою `WorkoutLogRepository.getActiveWorkoutSessionStream()`. Якщо знайдено, перенаправляє на `ActiveWorkoutScreen` для відновлення.
        *   Якщо немає активної сесії, перевіряє, чи є у користувача рутини за допомогою `RoutineRepository.getUserRoutines()`. Якщо так, перенаправляє на вкладку "Routines" (`UserRoutinesScreen`).
        *   Якщо рутин немає, перенаправляє безпосередньо на `CreateEditRoutineScreen`.
    *   **Вміст:**
        *   Персоналізоване привітання (наприклад, "Welcome, John").
        *   Відображення серії тренувань (іконка + число) з `UserProfileCubit`.
        *   Ключові картки статистики: поточна вага, серія тренувань, відсоток дотримання графіку запланованих рутин (розраховується в `DashboardStatsCubit`).
        *   Графік Тренда Об'єму (`VolumeTrendChartWidget` в `lib/features/dashboard/presentation/widgets/volume_trend_chart_widget.dart`), що відображає загальний об'єм за останні 7 завершених тренувань. Дані з `DashboardStatsCubit`.
        *   Майбутній Розклад (`UpcomingScheduleWidget` в `lib/features/dashboard/presentation/widgets/upcoming_schedule_widget.dart`) на наступні 7 днів, показуючи заплановані рутини. Дані з `UpcomingScheduleCubit`.
        *   Секція сповіщень, що відображає останні непрочитані сповіщення з `NotificationsCubit`.

### 6.3. Система Сповіщень

*   **Сутність `AppNotification` (`lib/core/domain/entities/app_notification.dart`):** Визначає структуру сповіщення (id, type, title, message, timestamp, isRead, relatedEntityId, iconName).
*   **Перелік `NotificationType` (`lib/core/domain/entities/app_notification.dart`):** Категоризує сповіщення (наприклад, `achievementUnlocked`, `workoutReminder`, `advice`, `systemMessage`).
*   **`NotificationRepository` та `NotificationRepositoryImpl` (`lib/features/notifications/data/repositories/notification_repository_impl.dart`):** Обробляє операції Firestore для отримання, позначення як прочитаних та видалення сповіщень, що зберігаються в `users/{userId}/notifications`.
*   **`NotificationsCubit` (`lib/features/notifications/presentation/cubit/notifications_cubit.dart`):**
    *   Керує списком сповіщень та лічильником непрочитаних у реальному часі.
    *   Надає потоки для сповіщень в додатку (наприклад, для нових досягнень або спливаючих вікон з порадами).
*   **UI:**
    *   `NotificationListItem` (в `lib/features/notifications/presentation/widgets/notification_list_item.dart`): Відображає зведення одного сповіщення.
    *   `NotificationDetailScreen` (в `lib/features/notifications/presentation/screens/notification_detail_screen.dart`): Показує повний вміст сповіщення.
    *   Непрочитані сповіщення візуально виділяються. Користувачі можуть позначити всі як прочитані або видалити окремі сповіщення.

### 6.4. Бібліотека Вправ

*   **Сутність `PredefinedExercise` (`lib/core/domain/entities/predefined_exercise.dart`):** Стандартизовані дані про вправи (назва, групи м'язів, обладнання, опис, URL відео, складність, теги). Зберігаються в колекції Firestore `predefinedExercises`.
*   **`PredefinedExerciseRepository` та `PredefinedExerciseRepositoryImpl` (`lib/features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart`):** Отримує вправи з Firestore.
*   **`seedPredefinedExercises` (Cloud Function в `functions/src/index.ts`):** HTTPS-тригер для наповнення колекції `predefinedExercises` початковими даними.
*   **`ExerciseExplorerScreen` (`lib/features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart`):**
    *   Дозволяє переглядати бібліотеку вправ.
    *   Використовується контекстно в режимі "вибору" (наприклад, при додаванні вправи до рутини через `AddExerciseToRoutineDialog` або виборі вправи для поста `recordClaim`).
*   **`ExerciseExplorerCubit` (`lib/features/exercise_explorer/presentation/cubit/exercise_explorer_cubit.dart`):** Керує завантаженням та відображенням вправ.

### 6.5. Управління Тренувальними Рутинами

*   **Сутності (в `lib/core/domain/entities/routine.dart`):**
    *   `UserRoutine`: Представляє створену користувачем тренувальну рутину (назва, опис, список `RoutineExercise`, заплановані дні, публічний статус, часові позначки).
    *   `RoutineExercise`: Вправа в межах рутини (predefinedExerciseId, знімок назви, кількість сетів, нотатки).
*   **`RoutineRepository` та `RoutineRepositoryImpl` (`lib/features/routines/data/repositories/routine_repository_impl.dart`):** Обробляє CRUD операції для рутин користувача в колекції Firestore `userRoutines`. Включає логіку для `copyRoutineFromSnapshot`.
*   **Кубіти:**
    *   `UserRoutinesCubit` (`lib/features/routines/presentation/cubit/user_routines_cubit.dart`): Керує списком рутин користувача для `UserRoutinesScreen`.
    *   `ManageRoutineCubit` (`lib/features/routines/presentation/cubit/manage_routine_cubit.dart`): Керує станом однієї рутини під час створення або редагування в `CreateEditRoutineScreen`.
*   **Екрани UI:**
    *   `UserRoutinesScreen` (`lib/features/routines/presentation/screens/user_routines_screen.dart`): Відображає список рутин користувача. Дозволяє розпочинати, редагувати, видаляти та ділитися рутинами.
    *   `CreateEditRoutineScreen` (`lib/features/routines/presentation/screens/create_edit_routine_screen.dart`): Форма для створення або зміни деталей та вправ рутини.
    *   `AddExerciseToRoutineDialog` (`lib/features/routines/presentation/widgets/add_exercise_to_routine_dialog.dart`): Спливаюче вікно для вибору вправи з `ExerciseExplorerScreen` та вказівки сетів/нотаток для неї в межах рутини.

### 6.6. Відстеження Тренувань

*   **Сутності:**
    *   `WorkoutSession` (`lib/core/domain/entities/workout_session.dart`): Відстежує активне або завершене тренування (пов'язана рутина, час початку/кінця, тривалість, список `LoggedExercise`, загальні нотатки, статус, загальний об'єм).
    *   `LoggedExercise` (`lib/core/domain/entities/logged_exercise.dart`): Вправа, виконана під час сесії (знімок назви вправи, цільові сети, список `LoggedSet`, нотатки).
    *   `LoggedSet` (`lib/core/domain/entities/logged_set.dart`): Один виконаний сет (номер сету, вага, повторення, статус завершення, нотатки RPE для кожного повторення).
*   **`WorkoutLogRepository` та `WorkoutLogRepositoryImpl` (`lib/features/workout_tracking/data/repositories/workout_log_repository_impl.dart`):** Керує даними тренувальних сесій в `users/{userId}/workoutLogs`.
*   **`ActiveWorkoutCubit` (`lib/features/workout_tracking/presentation/cubit/active_workout_cubit.dart`):**
    *   Керує станом поточної тренувальної сесії.
    *   Обробляє початок нових тренувань (порожніх або з рутини), відновлення активних.
    *   Оновлює залоговані сети вагою, повтореннями та RPE.
    *   Керує завершенням або скасуванням тренувань.
*   **`calculateAndAwardXpAndStreak` (Cloud Function в `functions/src/index.ts`):** Спрацьовує, коли статус `WorkoutSession` змінюється на "completed". Розраховує XP на основі об'єму та тривалості, оновлює XP користувача, рівень, серію тренувань (для запланованих рутин) та нагороджує досягненням "First Workout".
*   **Екрани UI:**
    *   `ActiveWorkoutScreen` (`lib/features/workout_tracking/presentation/screens/active_workout_screen.dart`): Основний інтерфейс для поточного тренування.
        *   Відображає поточну вправу та сет.
        *   `CurrentSetDisplay` (в `lib/features/workout_tracking/presentation/widgets/current_set_display.dart`): Дозволяє вводити вагу, повторення та RPE для кожного повторення за допомогою повзунків.
        *   Навігація між сетами та вправами.
    *   `WorkoutCompleteScreen` (`lib/features/workout_tracking/presentation/screens/workout_complete_screen.dart`): Святковий екран, що відображається після завершення тренування.
        *   Містить анімацію трофею Lottie та ефект `confetti`.
        *   Відображає зведення тренування, отриманий XP та інформацію про підвищення рівня.

### 6.7. Відстеження Прогресу (`ProgressScreen` та `ProgressCubit`)

*   **`ProgressCubit` (`lib/features/progress/presentation/cubit/progress_cubit.dart`):** Організовує дані з декількох джерел для `ProgressScreen`.
*   **Система Ліг:**
    *   Сутність `LeagueInfo` (`lib/core/domain/entities/league_info.dart`): Визначає рівні ліг (назва, мінімальний/максимальний рівні, діапазон XP, градієнтні кольори, опис). Зберігається в колекції Firestore `leagues`.
    *   `LeagueRepository` (`lib/features/progress/data/repositories/league_repository_impl.dart`): Отримує дані ліг.
    *   `LeagueTitleWidget` (в `lib/features/progress/presentation/widgets/league_title_widget.dart`): Відображає поточну назву ліги користувача та рівень з градієнтом.
*   **XP та Підвищення Рівня:**
    *   `XPProgressBarWidget` (в `lib/features/progress/presentation/widgets/xp_progress_bar_widget.dart`): Показує прогрес користувача до наступного рівня з анімованим заповненням.
*   **Карта М'язів:**
    *   `MuscleMapWidget` (в `lib/features/progress/presentation/widgets/muscle_map_widget.dart`): Відображає SVG-зображення передньої та задньої частини тіла, специфічні для статі (чоловіча: `assets/images/male_front.svg`, `assets/images/male_back.svg`; жіноча: `assets/images/female_front.svg`, `assets/images/female_back.svg`). Активи визначені в `pubspec.yaml`.
    *   Групи м'язів забарвлюються залежно від кількості виконаних для них сетів за останні 7 днів (вища інтенсивність для більшої кількості сетів).
*   **Статистика Тренувань:**
    *   **Тренд RPE:** Показує середнє RPE для кожної вправи за останні N (наприклад, 15) тренувань, де ця вправа виконувалася.
    *   **Тренд Робочої Ваги:** Показує середню робочу вагу для кожної вправи за останні N тренувань.
    *   Відображається у вигляді міні-графіків (sparkline charts, реалізовано в `ValueSparkline` всередині `lib/features/progress/presentation/screens/progress_screen.dart`) для швидкої візуальної оцінки.

### 6.8. Система Досягнень

*   **`AchievementId` (перелік) та `Achievement` (сутність) (`lib/core/domain/entities/achievement.dart`):** Визначають доступні досягнення (ID, назва, опис, іконка, опціональний перевіряльник умов).
*   **Логіка Нагородження:** В основному обробляється Firebase Cloud Functions (`checkProfileSetupCompletionAchievements`, `calculateAndAwardXpAndStreak`, `processRecordClaimDeadlines`) на основі конкретних тригерів (завершення профілю, завершення тренування, верифікація рекорду).
*   **Відображення:** Отримані нагороди перераховані на `ProfileScreen`.
*   **Реалізовано:** "Early Bird" (налаштування профілю), "First Workout" (перше тренування), "Personal Record Set" (встановлення особистого рекорду).

### 6.9. Соціальні Функції (Вкладка "Explore")

*   **`ExploreScreen` (`lib/features/social/presentation/screens/explore_screen.dart`):**
    *   Замінює попередній `ExerciseExplorerScreen` на вкладці "Explore" в `HomePage`.
    *   Відображає стрічку постів від усіх користувачів, відсортовану за часом (найновіші спочатку).
    *   Використовує `ExploreFeedCubit` для завантаження та відображення постів.
    *   Містить FloatingActionButton для переходу на `CreatePostScreen`.
*   **`CreatePostScreen` (`lib/features/social/presentation/screens/create_post_screen.dart`):**
    *   Дозволяє користувачам створювати та публікувати пости.
    *   **Типи Постів:** Користувачі можуть обирати тип поста за допомогою `SegmentedButton`:
        *   **Standard:** Текстові пости.
        *   **Routine Share:** Дозволяє обрати рутину (переходить на `UserRoutinesScreen` в режимі вибору, якщо рутина не була передана спочатку). Додає `routineSnapshot` та `relatedRoutineId` до поста.
        *   **Record Claim:** Надає поля для вибору вправи (через `ExerciseExplorerScreen`), введення ваги, повторень та опціонального URL відео. Зберігає це в `recordDetails`.
    *   Включає перемикач для ввімкнення/вимкнення коментарів до нового поста.
    *   Використовує `CreatePostCubit` для логіки надсилання.
*   **Віджет `PostListItem` (`lib/features/social/presentation/widgets/post_list_item.dart`):**
    *   Відображає вміст окремого поста: аватар та ім'я користувача автора, часову позначку поста.
    *   **Динамічний Вміст (реалізовано через `PostCardContentWidget`):**
        *   Для постів `standard`: показує текстовий вміст та медіа (якщо є, в майбутньому).
        *   Для постів `routineShare`: відображає картку з деталями рутини (назва, опис, кількість вправ, розклад) та кнопку "Add to My Routines".
        *   Для постів `recordClaim`: відображає картку з деталями рекорду (вправа, вага, повторення, посилання на відео) та статус верифікації. Включає функціональні кнопки "Validate" / "Unvalidate" (Dispute), якщо користувач може голосувати.
    *   **Взаємодії:**
        *   **Лайки:** Показує кількість лайків та інтерактивну кнопку лайка. Керується `PostInteractionCubit`.
        *   **Коментарі:** Показує кількість коментарів та іконку. Переходить на `PostDetailScreen`.
*   **`PostDetailScreen` (`lib/features/social/presentation/screens/post_detail_screen.dart`):**
    *   Відображає повний вміст обраного поста, включаючи його специфічний тип картки (standard, routine, record).
    *   Отримує та відображає список коментарів за допомогою `PostInteractionCubit` та віджетів `CommentListItem`.
    *   Дозволяє додавати нові коментарі, якщо ввімкнено для поста та користувач автентифікований.
    *   **Налаштування Поста (лише для автора):** Автор поста може перемикати `isCommentsEnabled` за допомогою кнопки на AppBar.
    *   **Модерація Коментарів:** Автори коментарів можуть редагувати або видаляти власні коментарі.
*   **`PostInteractionCubit` (`lib/features/social/presentation/cubit/post_interaction_cubit.dart`):**
    *   Керує станом для одного поста: статус лайка, коментарі, налаштування `isCommentsEnabled`, статус голосування користувача для `recordClaim`.
    *   Обробляє `toggleLike()`, `addComment()`, `fetchComments()`, `updateComment()`, `deleteComment()`, `toggleCommentsEnabled()`, та `castVote()`.
    *   Підписується на оновлення в реальному часі для конкретного поста та його коментарів.
*   **Структура Firestore для Соціальних Функцій:** (Детально в Секції 7)
*   **Cloud Functions для Соціальних Функцій:** `onCommentCreated`, `onCommentDeleted` оновлюють `commentsCount` на батьківському пості. `onRecordClaimPostCreated`, `onRecordClaimVoteCasted`, `processRecordClaimDeadlines` керують життєвим циклом та верифікацією заявок на рекорд.

### 6.10. Якість Життя та Деталі UX

*   **Анімований Фон:** `LavaLampBackground` (з `lib/widgets/lava_lamp_background.dart`) на `LoginPage`.
*   **Власна Тема:** Узгоджена колірна схема та типографіка в усьому додатку (визначено в `lib/main.dart` `ThemeData`).
*   **Інтуїтивна Навігація:** Чітка навігація на основі вкладок та логічний потік між екранами.
*   **Діалоги Підтвердження:** Для критичних дій, таких як видалення рутин або скасування тренувань.
*   **Візуальний Зворотний Зв'язок:** Індикатори завантаження, SnackBars успіху/помилки.
*   **Повзунки RPE:** Унікальне введення RPE для кожного повторення для детального відстеження зусиль в `CurrentSetDisplay`.
*   **Святкові Анімації:** `Confetti` та анімації Lottie для досягнень та завершення тренування (`WorkoutCompleteScreen`).
*   **Автоматичні Оновлення UI:** Оновлення в реальному часі для сповіщень, статистики профілю та вмісту соціальної стрічки через BLoC та Streams.
*   **Адаптивні Поля Вводу:** Поля форм адаптуються до фокусу та надають чітку валідацію.

## 7. Бекенд: Структура Firebase Cloud Firestore

База даних Firestore структурована для підтримки даних, специфічних для користувача, спільних ресурсів та соціальних взаємодій:

*   **`users/{userId}`:** Зберігає індивідуальну інформацію профілю користувача.
    *   **Поля:** Відповідають сутності `UserProfile` (в `lib/core/domain/entities/user_profile.dart`): `uid`, `email`, `displayName`, `profilePictureUrl`, `username`, `gender`, `dateOfBirth`, `heightCm`, `weightKg`, `fitnessGoal`, `activityLevel`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastWorkoutTimestamp`, `lastScheduledWorkoutCompletionTimestamp`, `lastScheduledWorkoutDayKey`, `followersCount`, `followingCount`, `achievedRewardIds` (List<String>), `profileSetupComplete` (bool), `createdAt` (Timestamp), `updatedAt` (Timestamp).
    *   **Підколекція `notifications/{notificationId}`:** Сповіщення, специфічні для користувача (схема визначена сутністю `AppNotification`).
    *   **Підколекція `workoutLogs/{sessionId}`:** Детальні логи кожної тренувальної сесії (схема визначена сутністю `WorkoutSession`).

*   **`predefinedExercises/{exerciseId}`:** Бібліотека стандартизованих вправ.
    *   **Поля:** Відповідають сутності `PredefinedExercise` (наприклад, `name`, `primaryMuscleGroup`, `description`, `normalizedName`, `videoDemonstrationUrl`).

*   **`userRoutines/{routineId}`:** Створені користувачем тренувальні рутини.
    *   **Поля:** Відповідають сутності `UserRoutine`: `userId` (для зв'язку з власником), `name`, `description`, `exercises` (List of Maps, схема з `RoutineExercise`), `scheduledDays` (List<String>), `isPublic` (bool), `createdAt`, `updatedAt`.

*   **`leagues/{leagueId}`:** Інформація про різні фітнес-ліги.
    *   **Поля:** Відповідають сутності `LeagueInfo` (наприклад, `name`, `minLevel`, `maxLevel`, `gradientColors`).

*   **`posts/{postId}`:** Згенеровані користувачем соціальні пости.
    *   **Поля:** Відповідають сутності `Post` (в `lib/core/domain/entities/post.dart`): `userId`, `authorUsername`, `authorProfilePicUrl`, `timestamp`, `type` (String: "standard", "routineShare", "recordClaim"), `textContent`, `mediaUrl` (String, optional), `likedBy` (List<String> ID користувачів), `commentsCount` (int), `isCommentsEnabled` (bool), `relatedRoutineId` (String, optional, для routineShare), `routineSnapshot` (Map, optional, для routineShare), `recordDetails` (Map, optional, для recordClaim: `exerciseId`, `exerciseName`, `weightKg`, `reps`, `videoUrl`), `recordVerificationStatus` (String, enum: "pending", "verified", "rejected", "expired"), `recordVerificationDeadline` (Timestamp, optional), `isRecordVerified` (bool, optional, для recordClaim), `updatedAt` (Timestamp), `votedAndRewardedUserIds` (List<String>).
    *   **Підколекція `comments/{commentId}`:** Коментарі, пов'язані з конкретним постом.
        *   **Поля:** Відповідають сутності `Comment`: `postId` (String), `userId`, `authorUsername`, `authorProfilePicUrl`, `text`, `timestamp`.

## 8. Логіка Firebase Cloud Functions (`functions/src/index.ts`)

Серверна логіка обробляється Firebase Cloud Functions (написані на TypeScript, розгорнуті на середовищі виконання Node.js 20):

*   **`createUserProfile`** (Auth Trigger - `onAuthUserCreate`, v1 функція):
    *   Створює новий документ в колекції `users` у Firestore при створенні нового користувача Firebase Auth.
    *   Ініціалізує поля профілю за замовчуванням, включаючи `profileSetupComplete: false`, `email`, `uid`, `createdAt` та `updatedAt`.
*   **`calculateAndAwardXpAndStreak`** (Firestore Trigger - `onDocumentUpdated` на `users/{userId}/workoutLogs/{sessionId}`, v2 функція):
    *   Спрацьовує, коли статус тренувального логу (`WorkoutSession.status`) змінюється на "completed".
    *   Розраховує XP на основі тривалості тренування (`durationSeconds`) та загального об'єму (`totalVolume`). XP обмежено (мінімум 50, максимум 200).
    *   Оновлює `xp`, `level`, `lastWorkoutTimestamp` користувача.
    *   Розраховує та оновлює `currentStreak` та `longestStreak` на основі дотримання запланованих днів рутини. Це враховує `routineId` завершеного тренування, `scheduledDays` відповідної рутини та `lastScheduledWorkoutCompletionTimestamp`, `lastScheduledWorkoutDayKey` користувача.
    *   Нагороджує досягненням "First Workout" (`AchievementId.FIRST_WORKOUT`), якщо воно ще не отримане, та надсилає відповідне сповіщення.
*   **`checkProfileSetupCompletionAchievements`** (Firestore Trigger - `onDocumentWritten` на `users/{userId}`, v2 функція):
    *   Спрацьовує при створенні або оновленні документа профілю користувача.
    *   Якщо `profileSetupComplete` змінюється з `false` на `true`, нагороджує досягненням "Early Bird" (`AchievementId.EARLY_BIRD`) та надсилає сповіщення.
*   **`seedPredefinedExercises`** (HTTPS Trigger, v1 функція):
    *   Викликається або HTTPS-тригером для наповнення колекції `predefinedExercises` стандартним набором вправ. (В основному для розробки/початкового налаштування).
*   **`onCommentCreated`** (Firestore Trigger - `onDocumentCreated` на `posts/{postId}/comments/{commentId}`, v2 функція):
    *   Збільшує поле `commentsCount` на батьківському документі поста.
    *   Оновлює часову позначку `updatedAt` на батьківському документі поста.
*   **`onCommentDeleted`** (Firestore Trigger - `onDocumentDeleted` на `posts/{postId}/comments/{commentId}`, v2 функція):
    *   Зменшує поле `commentsCount` на батьківському документі поста.
    *   Оновлює часову позначку `updatedAt` на батьківському документі поста.
*   **`onRecordClaimPostCreated`** (Firestore Trigger - `onDocumentCreated` на `posts/{postId}`, v2 функція):
    *   Якщо тип поста `recordClaim`, встановлює `recordVerificationDeadline` (поточний час + `RECORD_VOTE_DURATION_HOURS`, що дорівнює 24 годинам) та `recordVerificationStatus` на `PENDING`.
*   **`onRecordClaimVoteCasted`** (Firestore Trigger - `onDocumentUpdated` на `posts/{postId}`, v2 функція):
    *   Якщо пост є `recordClaim` і його статус `PENDING`.
    *   Перевіряє, чи змінилося поле `verificationVotes`. Якщо так, ідентифікує виборця.
    *   Якщо виборець ще не був нагороджений за голосування під цим постом (перевірка масиву `votedAndRewardedUserIds` в документі поста), то:
        *   Нараховує `XP_FOR_VOTING` (15 XP) користувачеві.
        *   Додає ID користувача до `votedAndRewardedUserIds` в документі поста.
        *   Надсилає сповіщення користувачеві про отримання XP.
*   **`processRecordClaimDeadlines`** (Scheduled Function - `onSchedule` "every 1 hours", v2 функція):
    *   Запитує всі пости типу `recordClaim` зі статусом `PENDING`, у яких `recordVerificationDeadline` менше або дорівнює поточному часу.
    *   Для кожного такого поста:
        *   Підраховує голоси "verify" та "dispute" з поля `verificationVotes`.
        *   Якщо загальна кількість голосів > 0:
            *   Якщо співвідношення голосів "verify" до загальної кількості голосів >= `MIN_VOTE_PERCENTAGE_FOR_VERIFICATION` (0.55), статус змінюється на `VERIFIED`, `isRecordVerified` стає `true`. Автору нараховується XP (`XP_FOR_RECORD_BASE` (500) + бонус за об'єм, максимум 1500 XP) та досягнення `personalRecordSet`. Надсилаються відповідні сповіщення.
            *   Інакше статус змінюється на `REJECTED`. Надсилається сповіщення автору.
        *   Якщо загальна кількість голосів == 0, статус змінюється на `EXPIRED`. Надсилається сповіщення автору.
    *   Оновлює відповідні поля в документі поста.

## 9. Налаштування та Запуск Проєкту

1.  **Flutter SDK:** Переконайтеся, що у вас встановлено Flutter SDK (версія `^3.8.0` або сумісна, як зазначено в `pubspec.yaml` та `.metadata`).
2.  **Налаштування Проєкту Firebase:**
    *   Створіть проєкт Firebase на [console.firebase.google.com](https://console.firebase.google.com/).
    *   Додайте додатки Android та iOS до вашого проєкту Firebase.
    *   Завантажте `google-services.json` (для Android, вже є в `android/app/google-services.json`) та `GoogleService-Info.plist` (для iOS) і розмістіть їх у відповідних каталогах `android/app` та `ios/Runner`.
    *   Увімкніть **Автентифікацію** (методи Email/Пароль та Google Sign-In).
    *   Увімкніть базу даних **Firestore** в режимі Native.
    *   Увімкніть **Cloud Functions**.
    *   (Опціонально для завантаження медіа пізніше) Увімкніть **Firebase Storage**.
3.  **Firebase CLI:**
    *   Встановіть Firebase CLI: `npm install -g firebase-tools` або дотримуйтесь офіційних інструкцій.
    *   Увійдіть: `firebase login`.
    *   Налаштуйте Firebase для вашого проєкту Flutter: `flutterfire configure`. Це згенерує `lib/firebase_options.dart` (вже присутній).
    *   Ініціалізуйте Firebase в каталозі `functions`: `cd functions && firebase init functions` (оберіть TypeScript). Замініть згенеровані файли тими, що є у знімку проєкту, якщо налаштовуєте з нуля, або адаптуйте існуючі.
4.  **Залежності:**
    *   Перейдіть до кореневого каталогу проєкту та виконайте `flutter pub get`.
    *   Перейдіть до каталогу `functions` та виконайте `npm install`.
5.  **Іконки Додатку:**
    *   Розмістіть зображення іконки вашого додатку за шляхом `assets/images/app_icon.png`.
    *   Виконайте `flutter pub run flutter_launcher_icons` для генерації іконок для конкретних платформ (конфігурація в `pubspec.yaml`).
6.  **Запуск Додатку:**
    *   Підключіть пристрій або запустіть емулятор/симулятор.
    *   Виконайте `flutter run` з кореневого каталогу проєкту.
7.  **Розгортання Cloud Functions:**
    *   З каталогу `functions` зберіть ваші функції: `npm run build`.
    *   Розгорніть їх: `firebase deploy --only functions`.
8.  **Наповнення `predefinedExercises`:**
    *   Cloud Function `seedPredefinedExercises` потрібно викликати (наприклад, через HTTPS-запит або власний скрипт) для наповнення колекції `predefinedExercises`, якщо вона порожня.
9.  **Правила Безпеки Firestore:**
    *   Оновіть ваші правила безпеки Firestore в консолі Firebase. Нижче наведено комплексний приклад (адаптуйте за потребою, особливо для прав запису на `predefinedExercises` та `leagues`, якщо потрібен запис лише для адміністратора). Надані правила відповідають описаній функціональності:
        *   `users/{userId}`: читання/запис дозволено лише автентифікованому власнику. Це ж стосується підколекцій `notifications` та `workoutLogs`.
        *   `predefinedExercises/{exerciseId}`: читання дозволено автентифікованим користувачам, запис заборонений (або лише для адміністратора/функцій).
        *   `userRoutines/{routineId}`: читання дозволено власнику або якщо рутина публічна. Створення, оновлення, видалення – лише власнику.
        *   `leagues/{leagueId}`: публічне читання, запис заборонений.
        *   `posts/{postId}`:
            *   Читання: автентифікованим користувачам.
            *   Створення: лише автору.
            *   Оновлення:
                *   Автор може оновлювати певні поля (`textContent`, `mediaUrl`, `isCommentsEnabled`, `type`, `relatedRoutineId`, `routineSnapshot`, `recordDetails`, `isRecordVerified`, `updatedAt`). Критичні поля (як `userId`, `timestamp`) змінювати не можна.
                *   Будь-який користувач може лайкати/дизлайкати (змінюються лише `likedBy` та `updatedAt`). Правило перевіряє, що змінюються лише ці два поля і що `likedBy` змінюється коректно (додається/видаляється UID поточного користувача).
            *   Видалення: лише автору.
        *   `posts/{postId}/comments/{commentId}`:
            *   Читання: автентифікованим користувачам.
            *   Створення: лише автору коментаря, якщо коментарі до поста ввімкнено (`get(/databases/$(database)/documents/posts/$(postId)).data.isCommentsEnabled == true`).
            *   Оновлення, видалення: лише автору коментаря.

    ```firestore
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
          allow read: if request.auth != null;
          allow write: if false; // Або лише для адміністратора/функцій
        }
        match /userRoutines/{routineId} {
          // Дозволити читання, якщо автентифіковано і це їхня рутина АБО якщо рутина публічна
          allow read: if request.auth != null && (resource.data.userId == request.auth.uid || resource.data.isPublic == true);
          // Дозволити створення, якщо автентифіковано і userId нової рутини відповідає їхньому uid
          allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
          // Дозволити оновлення та видалення, якщо автентифіковано і це їхня рутина (на основі існуючих даних)
          allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
        }
        match /leagues/{leagueId} {
          allow read: if true; // Ліги публічні
          allow write: if false; // Зазвичай керуються через консоль або адмін-інструменти
        }

        match /posts/{postId} {
          allow read: if request.auth != null;
          allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;

          allow update: if request.auth != null &&
                          (
                            // Автор може оновлювати певні поля свого власного поста
                            (resource.data.userId == request.auth.uid &&
                               !request.resource.data.diff(resource.data).affectedKeys().hasAny(['likedBy', 'commentsCount', 'userId', 'authorUsername', 'authorProfilePicUrl', 'timestamp', 'recordVerificationStatus', 'recordVerificationDeadline', 'votedAndRewardedUserIds']) && // Забороняємо змінювати поля, що керуються сервером або іншими користувачами
                               (request.resource.data.diff(resource.data).affectedKeys().hasOnly(['textContent', 'mediaUrl', 'isCommentsEnabled', 'type', 'relatedRoutineId', 'routineSnapshot', 'recordDetails', 'isRecordVerified', 'updatedAt']) ||
                                request.resource.data.diff(resource.data).affectedKeys().hasOnly(['updatedAt']) // Дозволяємо лише оновлення 'updatedAt' для тригерів функцій
                               )
                            ) ||
                            // Будь-який користувач може лайкати/дизлайкати (змінюються лише 'likedBy' та 'updatedAt')
                            (
                               request.resource.data.diff(resource.data).affectedKeys().hasAll(['likedBy', 'updatedAt']) &&
                               request.resource.data.diff(resource.data).affectedKeys().size() == 2 &&
                               (
                                 (request.resource.data.likedBy.toSet().difference(resource.data.likedBy.toSet()).hasOnly([request.auth.uid])) || // Додавання лайка
                                 (resource.data.likedBy.toSet().difference(request.resource.data.likedBy.toSet()).hasOnly([request.auth.uid]))  // Видалення лайка
                               ) &&
                               // Переконатися, що інші критичні поля не змінюються під час операції лайка
                               request.resource.data.userId == resource.data.userId &&
                               request.resource.data.type == resource.data.type &&
                               request.resource.data.textContent == resource.data.textContent &&
                               request.resource.data.mediaUrl == resource.data.mediaUrl &&
                               request.resource.data.isCommentsEnabled == resource.data.isCommentsEnabled &&
                               request.resource.data.commentsCount == resource.data.commentsCount &&
                               request.resource.data.recordVerificationStatus == resource.data.recordVerificationStatus // Голоси оновлюються іншим шляхом
                            ) ||
                            // Будь-який користувач може голосувати (змінюються 'verificationVotes', 'votedAndRewardedUserIds' та 'updatedAt')
                            (
                              request.resource.data.diff(resource.data).affectedKeys().hasAll(['verificationVotes', 'updatedAt']) && // 'votedAndRewardedUserIds' оновлюється функцією
                              (request.resource.data.diff(resource.data).affectedKeys().size() == 2 || request.resource.data.diff(resource.data).affectedKeys().size() == 3 && request.resource.data.diff(resource.data).affectedKeys().has('votedAndRewardedUserIds')) && // Дозволяємо 3, якщо функція додає votedAndRewardedUserIds
                              request.resource.data.userId == resource.data.userId && // Не можна змінювати автора
                              request.resource.data.recordVerificationStatus == resource.data.recordVerificationStatus && // Статус не змінюється тут
                              request.resource.data.type == "recordClaim" // Тільки для заявок на рекорд
                            )
                          );
          allow delete: if request.auth != null && resource.data.userId == request.auth.uid;

          match /comments/{commentId} {
            allow read: if request.auth != null;
            allow create: if request.auth != null &&
                          request.resource.data.userId == request.auth.uid &&
                          request.resource.data.postId == postId && // Переконатися, що postId коментаря відповідає батьківському
                          get(/databases/$(database)/documents/posts/$(postId)).data.isCommentsEnabled == true; // Дозволити коментар, лише якщо ввімкнено
            allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
          }
        }
      }
    }
    ```

## 10. Дорожня Карта та Майбутній Розвиток

MuscleUP прагне стати всеосяжною соціальною фітнес-платформою.

**Фаза 1: Базові Пости та Стрічка (Завершено)**
*   [✔️] Модель `Post` та структура Firestore
*   [✔️] Створення стандартних текстових постів
*   [✔️] Базовий UI стрічки "Explore"
*   [✔️] Вбудування профілю автора в пости

**Фаза 2: Взаємодія з Постами - Лайки та Коментарі (Завершено)**
*   [✔️] Система лайків (оновлення моделі, UI, методи `PostRepository`)
*   [✔️] Система коментарів (модель, підколекція, UI для додавання/перегляду, методи `PostRepository`)
*   [✔️] Cloud Functions для `commentsCount` (`onCommentCreated`, `onCommentDeleted`)
*   [✔️] Редагування/видалення власних коментарів автором
*   [✔️] Ввімкнення/вимкнення коментарів автором поста (під час створення та з `PostDetailScreen`)

**Фаза 3: Розширені Типи Постів (В Прогресі)**
*   **Пост "Поділитися Рутиною" (`routineShare`):**
    *   [✔️] Оновлено модель `Post` полями `relatedRoutineId`, `routineSnapshot`.
    *   [✔️] UI для ініціювання спільного доступу до рутини з `RoutineListItem` на `CreatePostScreen`.
    *   [✔️] `CreatePostScreen` обробляє тип `routineShare`, додає знімок та ID.
    *   [✔️] `PostListItem` (через `PostCardContentWidget`) відображає картку `routineShare` з деталями.
    *   [✔️] Кнопка "Add to My Routines" та логіка з використанням `RoutineRepository.copyRoutineFromSnapshot`.
*   **Пост "Заявка на Рекорд" (`recordClaim`):**
    *   [✔️] Розширено модель `Post` полями `recordDetails`, `isRecordVerified`, `recordVerificationStatus`, `recordVerificationDeadline`, `verificationVotes`, `votedAndRewardedUserIds`.
    *   [✔️] UI в `CreatePostScreen` для створення постів `recordClaim` (вибір вправи, вага, повторення, URL відео).
    *   [✔️] `PostListItem` (через `PostCardContentWidget`) відображає картку `recordClaim` з деталями, статусом верифікації та кнопками для голосування.
    *   [✔️] Логіка для подання голосу та зберігання в документі `Post` (поле `verificationVotes` як мапа `userId: voteTypeString`).
    *   [✔️] Cloud Function `onRecordClaimVoteCasted` для нарахування XP за голосування.
    *   [✔️] Cloud Function `processRecordClaimDeadlines` для підрахунку голосів, оновлення `isRecordVerified` та нарахування XP/досягнень автору.

**Фаза 4: Основний Соціальний Граф**
*   **Підписки Користувачів (Followers/Following):**
    *   [ ] Оновити сутність `UserProfile` для `following` (List<String>) та `followersCount`, `followingCount`.
    *   [ ] UI для кнопок Follow/Unfollow (на профілях користувачів, в заголовках/підвалах постів).
    *   [ ] Cloud Functions для управління відносинами підписки та оновлення лічильників у профілях обох користувачів.
*   **Персоналізована Стрічка (В майбутньому для "Explore" або нової вкладки "Feed"):**
    *   [ ] Логіка для отримання та відображення постів переважно від підписаних користувачів.

**Фаза 5: Покращення та Шліфування**
*   **Медіа в Постах:**
    *   [ ] Функціонал завантаження зображень/відео (інтеграція з Firebase Storage).
    *   [ ] UI для додавання медіа під час створення поста.
    *   [ ] Відображення медіа в `PostListItem` та `PostDetailScreen`.
*   **Сповіщення для Соціальних Взаємодій:**
    *   [ ] Новий лайк на вашому пості.
    *   [ ] Новий коментар на вашому пості.
    *   [ ] Новий підписник.
*   **Покращення UI/UX для Соціальних Функцій:**
    *   [ ] Меню опцій поста (редагувати/видалити власний пост, поскаржитися на пост).
    *   [ ] Опції фільтрації/сортування в стрічці "Explore" (за типом, популярністю тощо).
    *   [ ] Сторінки профілів користувачів для перегляду (показують їхні пости, статистику, досягнення).
*   **Повна Реалізація Інших Екранів:**
    *   [ ] Завершити секцію деталей "Profile" з розширеною статистикою, особистою стрічкою активності (включаючи соціальні взаємодії).

**Довгострокове Бачення (Поза поточним обсягом):**
*   Прямі повідомлення між користувачами.
*   Публічні рекорди та таблиці лідерів (валідовані спільнотою).
*   Розширена гейміфікація (більше досягнень, викликів, сезонних ліг, віртуальних нагород).
*   Більш гранульоване персоналізоване встановлення цілей.
*   Push-сповіщення через Firebase Cloud Messaging (FCM) для всіх типів сповіщень.
*   Комплексний набір тестів (Unit, Widget, Integration tests).
*   Адмін-панель для модерації контенту та управління користувачами.
*   Інтеграція з носимими пристроями (наприклад, для пульсу, автоматичного визначення тренувань).
*   Офлайн-підтримка для ключових функціональностей.

---