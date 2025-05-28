Чудово! Давай оновимо README.md, щоб відобразити реалізований функціонал сповіщень. Я постараюся бути максимально детальним.

Оновлений README.md:

# MuscleUP: Фітнес-застосунок для справжніх атлетів

**Motto:** Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

## 1. Вступ

**MuscleUP** – це мобільний фітнес-застосунок, розроблений для підвищення мотивації та довгострокової залученості користувачів до тренувального процесу. Застосунок дозволяє відстежувати тренування, встановлювати фітнес-цілі, отримувати сповіщення, ділитися прогресом (в майбутньому) та отримувати підтримку від спільноти (в майбутньому).

**Поточний стан (розширена версія 0.2.x - з функціоналом сповіщень):**
На даному етапі реалізовано наступний функціонал:
*   Автентифікація користувачів (Email/Password та Google Sign-In).
*   Створення початкового профілю користувача в Cloud Firestore після першої реєстрації.
*   Екран "Profile Setup" для введення додаткових даних (username, стать, вага, зріст, цілі тощо) після першого входу, якщо профіль не завершено (`profileSetupComplete: false`).
*   Оновлений `HomePage` як центральний хаб з AppBar, BottomNavigationBar та FloatingActionButton (для "Start Workout", відображається тільки на дашборді).
*   Інтерактивний `DashboardScreen` як головний екран, що відображає:
    *   Вітання користувача.
    *   Статистику (вага, стрік тренувань - плейсхолдери для деяких значень).
    *   **Секцію сповіщень:**
        *   Заголовок "NOTIFICATIONS" з **лічильником непрочитаних сповіщень** (помаранчевий кружечок з числом).
        *   Список **останніх 3-5 сповіщень** з їх заголовком, текстом, часом отримання та іконкою типу.
        *   Візуальне виділення **непрочитаних сповіщень** (жирний шрифт, індикатор-крапка, яскравіша рамка).
        *   Можливість **видалення сповіщення свайпом** вліво або вправо.
        *   Кнопка "**READ ALL**" (шрифтом IBM Plex Mono) для позначення всіх сповіщень як прочитаних, якщо є непрочитані.
        *   При тапі на сповіщення воно позначається як прочитане.
*   Перегляд бібліотеки стандартизованих вправ (`ExerciseExplorerScreen`).
*   Створення, перегляд, редагування та видалення користувацьких тренувальних рутин (`UserRoutinesScreen`, `CreateEditRoutineScreen`).
*   Розширена модель користувача `UserProfile` для зберігання додаткових даних.
*   **Новий модуль "Notifications"** для управління сповіщеннями:
    *   Модель `AppNotification` для представлення даних сповіщення.
    *   `NotificationRepository` та його імплементація для взаємодії з Firestore (отримання сповіщень, лічильника непрочитаних, позначення як прочитаних, видалення).
    *   `NotificationsCubit` для управління станом сповіщень, підпискою на зміни в Firestore та оновленням UI в реальному часі.
*   Репозиторії та Cubit'и для управління профілем, вправами та рутинами.

## 2. Ключові Архітектурні Принципи

*   **Модульність:** Застосунок розроблено за принципом "feature-first", де кожна функціональна частина є окремим модулем (наприклад, `auth`, `profile_setup`, `exercise_explorer`, `routines`, `dashboard`, **`notifications`**).
*   **Чітке Розділення Відповідальностей:** Використання шарів (Domain, Data, Presentation) в межах кожного модуля.
*   **Управління Станом:** Застосування Flutter BLoC/Cubit для управління станом UI та бізнес-логіки.
*   **Залежності:** Використання `RepositoryProvider` для надання залежностей репозиторіїв (та `FirebaseAuth`) віджетам.
*   **Масштабованість:** Архітектура передбачає легке додавання нових функцій та розширення існуючих.

## 3. Технологічний Стек

*   **Фронтенд:**
    *   **Framework:** Flutter (`^3.8.0` Dart SDK, згідно `pubspec.yaml`)
    *   **Мова:** Dart
    *   **Управління станом:** Flutter BLoC/Cubit (`flutter_bloc: ^9.1.1`)
    *   **Порівняння об'єктів:** Equatable (`equatable: ^2.0.5`)
    *   **Форматування дати:** `intl: ^0.19.0`
    *   **Анімації:** `animated_background: ^2.0.0` (для сторінки логіну)
    *   **Навігація:** Стандартна Flutter навігація (`MaterialPageRoute`, `Navigator.push/pop/pushAndRemoveUntil`).
*   **Бекенд (Firebase):**
    *   **Firebase Core:** `firebase_core: ^3.13.1`
    *   **Firebase Authentication:** `firebase_auth: ^5.5.4` (Email/Password, Google Sign-In)
    *   **Google Sign-In:** `google_sign_in: ^6.2.1`
    *   **Cloud Firestore:** `cloud_firestore: ^5.6.8` (NoSQL база даних для профілів, рутин, вправ та **сповіщень користувачів**).
    *   **Firebase Storage:** (Планується) для медіафайлів.
    *   **Cloud Functions:** (Планується) для серверної логіки, включаючи потенційну генерацію деяких типів сповіщень.
*   **Інструменти розробки:**
    *   **Лінтер:** `flutter_lints: ^5.0.0`

## 4. Структура Проєкту (`lib/`)


muscle_up/
├── lib/
│ ├── main.dart             # Точка входу, ініціалізація Firebase, MaterialApp, RepositoryProviders
│ ├── auth_gate.dart        # Керування потоком автентифікації та перевіркою `profileSetupComplete`
│ ├── firebase_options.dart # Конфігурація Firebase (згенеровано)
│ ├── home_page.dart        # ГОЛОВНИЙ ЕКРАН: AppBar, BottomNavigationBar, FAB, керування вкладками. Надає NotificationsCubit.
│ ├── login_page.dart       # Екран входу/реєстрації, анімований фон
│ │
│ ├── core/
│ │ └── domain/
│ │   ├── entities/
│ │   │ ├── app_notification.dart    # Модель для сповіщення (НОВА)
│ │   │ ├── predefined_exercise.dart # Модель для стандартизованої вправи
│ │   │ ├── routine.dart             # Моделі UserRoutine та RoutineExercise
│ │   │ └── user_profile.dart      # Модель для профілю користувача
│ │   └── repositories/
│ │     ├── notification_repository.dart      # Абстракція репозиторію сповіщень (НОВА)
│ │     ├── predefined_exercise_repository.dart # Абстракція репозиторію вправ
│ │     ├── routine_repository.dart             # Абстракція репозиторію рутин
│ │     └── user_profile_repository.dart      # Абстракція репозиторію профілю
│ │
│ └── features/ # Кожен модуль фічі
│   ├── dashboard/
│   │ └── presentation/
│   │   └── screens/
│   │     └── dashboard_screen.dart # UI для головного екрану/дашборду (вміст для HomePage). Відображає сповіщення.
│   │
│   ├── notifications/              # НОВИЙ МОДУЛЬ
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── notification_repository_impl.dart # Імплементація репозиторію сповіщень
│   │   ├── presentation/
│   │   │   ├── cubit/
│   │   │   │   ├── notifications_cubit.dart   # Cubit для управління станом сповіщень
│   │   │   │   └── notifications_state.dart   # Стани для NotificationsCubit
│   │   │   └── widgets/
│   │   │       └── notification_list_item.dart # Віджет для відображення одного сповіщення (з Dismissible)
│   │
│   ├── exercise_explorer/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── predefined_exercise_repository_impl.dart
│   │   └── presentation/
│   │     ├── cubit/
│   │     │   ├── exercise_explorer_cubit.dart
│   │     │   └── exercise_explorer_state.dart
│   │     ├── screens/
│   │     │   └── exercise_explorer_screen.dart
│   │     └── widgets/
│   │       └── exercise_list_item.dart
│   │
│   ├── routines/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── routine_repository_impl.dart
│   │   └── presentation/
│   │     ├── cubit/ # ... (кубіти для рутин)
│   │     ├── screens/ # ... (екрани для рутин)
│   │     └── widgets/ # ... (віджети для рутин)
│   │
│   └── profile_setup/
│     ├── data/ # ... (репозиторій профілю)
│     └── presentation/ # ... (кубіт та екран налаштування профілю)
│
│ # Інші екрани (PostsScreen, ProgressScreen, ProfileScreen) - плейсхолдери
│
├── assets/
│ ├── images/
│ │ └── google_logo.png
│ └── fonts/
│   ├── Inter_...ttf
│   └── IBMPlexMono_...ttf
│
├── android/
├── ios/
└── web/

5. Детальний Опис Ключових Компонентів
5.1. Автентифікація та Налаштування Профілю

(Цей розділ залишається переважно без змін, оскільки основна логіка не змінювалася)

main.dart: Ініціалізує Firebase. Надає репозиторії (включаючи NotificationRepository) та FirebaseAuth через MultiRepositoryProvider. Визначає MaterialApp.

LoginPage: UI для входу/реєстрації. Створює початковий документ користувача з profileSetupComplete: false.

AuthGate: Керує потоком на основі стану автентифікації та profileSetupComplete.

ProfileSetupScreen: Екран для завершення налаштування профілю.

UserProfileCubit: Завантажує та надає дані UserProfile, слухає зміни в реальному часі.

5.2. Головний Екран (HomePage та DashboardScreen)

HomePage (home_page.dart):

StatelessWidget, який надає NotificationsCubit для дочірніх віджетів (зокрема, _HomePageContent).

_HomePageContent (StatefulWidget):

Централізований AppBar (з назвою "MuscleUP"). Раніше мав іконку сповіщень, тепер лічильник інтегрований в DashboardScreen.

BottomNavigationBar для навігації між основними розділами.

FloatingActionButton ("START WORKOUT") відображається, коли активний дашборд.

Керує відображенням контенту залежно від обраної вкладки (_selectedIndex = -1 для DashboardScreen).

DashboardScreen (features/dashboard/.../dashboard_screen.dart):

Відображає вітальне повідомлення (використовуючи дані з UserProfileCubit).

Плейсхолдери для основної статистики (вага, стрік).

Інтегрована секція сповіщень:

Використовує BlocBuilder<NotificationsCubit, ...> для отримання списку сповіщень та кількості непрочитаних.

Відображає заголовок "NOTIFICATIONS" з лічильником непрочитаних.

Якщо є непрочитані сповіщення, відображає кнопку "READ ALL" (шрифт IBM Plex Mono), яка позначає всі сповіщення як прочитані.

Відображає список останніх N (наприклад, 5) сповіщень за допомогою віджета NotificationListItem.

Кожне сповіщення в списку можна видалити свайпом вліво/вправо.

При тапі на сповіщення воно позначається як прочитане (оновлення відбувається через NotificationsCubit).

Не має власного Scaffold чи AppBar, оскільки є частиною HomePage.

Містить тимчасову кнопку "Send Test Notifications" для генерації сповіщень через бекенд (Firestore) під час розробки.

5.3. Модуль "Notifications" (features/notifications/) - НОВИЙ

AppNotification (core/domain/entities/app_notification.dart):

Сутність, що представляє сповіщення з полями: id, type (enum NotificationType), title, message, timestamp, isRead, relatedEntityId, relatedEntityType, iconName.

Включає фабричний конструктор fromFirestore та метод toMap.

NotificationRepository (core/domain/repositories/notification_repository.dart):

Абстрактний клас, що визначає контракт для роботи зі сповіщеннями:

getUserNotificationsStream(String userId): Потік списку сповіщень користувача.

getUnreadNotificationsCountStream(String userId): Потік кількості непрочитаних сповіщень.

markNotificationAsRead(String userId, String notificationId): Позначити сповіщення як прочитане.

markAllNotificationsAsRead(String userId): Позначити всі сповіщення як прочитані.

deleteNotification(String userId, String notificationId): Видалити сповіщення.

NotificationRepositoryImpl (features/notifications/data/repositories/notification_repository_impl.dart):

Імплементація NotificationRepository для взаємодії з Cloud Firestore.

Зберігає сповіщення в підколекції users/{userId}/notifications.

Включає метод createTestNotification для зручного створення сповіщень під час розробки.

NotificationsCubit (features/notifications/presentation/cubit/notifications_cubit.dart):

Керує станом списку сповіщень та лічильником непрочитаних.

Підписується на потоки з NotificationRepository при вході користувача та оновлює стан NotificationsLoaded або NotificationsError.

Надає методи для позначення сповіщень як прочитаних (markNotificationAsRead, markAllNotificationsAsRead) та видалення (deleteNotification).

Використовує FirebaseAuth для отримання userId поточного користувача.

NotificationListItem (features/notifications/presentation/widgets/notification_list_item.dart):

Віджет для відображення одного елемента сповіщення.

Обгорнутий у Dismissible для підтримки видалення свайпом.

Відображає іконку типу сповіщення, заголовок, повідомлення, час та індикатор непрочитаності.

При тапі позначає сповіщення як прочитане.

5.4. Модуль "Exercise Explorer" (features/exercise_explorer/)

(Без значних змін у цьому оновленні)

5.5. Модуль "Routines" (features/routines/)

(Без значних змін у цьому оновленні)

6. Структура Бекенду (Firebase)
6.1. Firebase Authentication

Управління користувачами (Email/Password, Google Sign-In).

6.2. Cloud Firestore

users/{userId}:

Поля: uid, email, displayName?, ..., profileSetupComplete, createdAt, updatedAt, та інші.

Підколекція: notifications/{notificationId} (НОВА СТРУКТУРА)

type: (String) наприклад, "achievementUnlocked", "workoutReminder", "systemMessage"

title: (String) Заголовок сповіщення

message: (String) Текст сповіщення

timestamp: (Timestamp) Час створення

isRead: (Boolean) false або true

iconName: (String, optional) Назва іконки для відображення (наприклад, "emoji_events")

relatedEntityId: (String, optional) ID пов'язаної сутності

relatedEntityType: (String, optional) Тип пов'язаної сутності

predefinedExercises: (Структура без змін)

userRoutines: (Структура без змін)

7. Налаштування та Запуск Проєкту

(Без змін)

8. Подальший Розвиток

Повноцінна реалізація генерації сповіщень:

Клієнтська генерація: при отриманні досягнень, завершенні тренувань тощо.

Серверна генерація (Cloud Functions): для нагадувань про тренування, новин, оновлень.

Навігація зі сповіщень: При тапі на сповіщення переходити до відповідного екрану (наприклад, екран досягнень, деталі рутини).

Push-сповіщення: Інтеграція Firebase Cloud Messaging (FCM) для надсилання push-сповіщень, коли додаток не активний.

Завершення екранів "Posts", "Progress", "Profile".

Логування Тренувань.

Розширений Дашборд з реальною статистикою.

Гейміфікація (XP, рівні, стріки).

Соціальні Функції.

Firebase Storage для зображень.

Тестування.

Покращення UI/UX.