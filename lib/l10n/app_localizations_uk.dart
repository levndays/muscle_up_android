// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Muscle UP!';

  @override
  String get loginPageSignInButton => 'Увійти';

  @override
  String get loginPageTitleSignIn => 'Вхід';

  @override
  String get loginPageTitleSignUp => 'Реєстрація';

  @override
  String get loginPageEmailHint => 'Електронна пошта';

  @override
  String get loginPagePasswordHint => 'Пароль';

  @override
  String get loginPageErrorEnterEmail =>
      'Будь ласка, введіть вашу електронну пошту';

  @override
  String get loginPageErrorValidEmail =>
      'Будь ласка, введіть дійсну електронну пошту';

  @override
  String get loginPageErrorEnterPassword => 'Будь ласка, введіть ваш пароль';

  @override
  String get loginPageErrorPasswordLength =>
      'Пароль має містити щонайменше 6 символів';

  @override
  String get loginPageButtonCreateAccount => 'Створити Обліковий Запис';

  @override
  String get loginPageButtonSignInWithGoogle => 'Увійти через Google';

  @override
  String get loginPageToggleSignUp =>
      'Немає облікового запису? Зареєструватися';

  @override
  String get loginPageToggleSignIn => 'Вже є обліковий запис? Увійти';

  @override
  String get loginPageErrorAuthDefault => 'Сталася помилка автентифікації.';

  @override
  String loginPageErrorUnknownDefault(String errorDetails) {
    return 'Сталася невідома помилка: $errorDetails';
  }

  @override
  String get loginPageErrorGoogleSignInDefault => 'Помилка входу через Google.';

  @override
  String loginPageErrorUnknownGoogleDefault(String errorDetails) {
    return 'Невідома помилка під час входу через Google: $errorDetails';
  }

  @override
  String get loginPageErrorInternalForm =>
      'Внутрішня помилка форми. Будь ласка, спробуйте ще раз.';

  @override
  String get profileSetupAppBarTitleEdit => 'Редагувати Профіль';

  @override
  String get profileSetupAppBarTitleCreate => 'Завершіть Ваш Профіль';

  @override
  String get profileSetupUsernameLabel => 'Ім\'я користувача';

  @override
  String get profileSetupUsernameErrorRequired =>
      'Ім\'я користувача обов\'язкове';

  @override
  String get profileSetupDisplayNameLabel => 'Відображуване ім\'я';

  @override
  String get profileSetupGenderLabel => 'Стать';

  @override
  String get profileSetupGenderMale => 'Чоловіча';

  @override
  String get profileSetupGenderFemale => 'Жіноча';

  @override
  String get profileSetupGenderOther => 'Інша';

  @override
  String get profileSetupGenderPreferNotToSay => 'Не вказувати';

  @override
  String get profileSetupDobLabel => 'Дата народження';

  @override
  String get profileSetupDobDatePickerHelpText =>
      'Оберіть вашу дату народження';

  @override
  String get profileSetupHeightLabel => 'Зріст (см)';

  @override
  String get profileSetupHeightErrorInvalid => 'Некоректний зріст (1-300 см)';

  @override
  String get profileSetupWeightLabel => 'Вага (кг)';

  @override
  String get profileSetupWeightErrorInvalid => 'Некоректна вага (1-500 кг)';

  @override
  String get profileSetupFitnessGoalLabel => 'Основна фітнес-ціль';

  @override
  String get profileSetupFitnessGoalLoseWeight => 'Схуднути';

  @override
  String get profileSetupFitnessGoalGainMuscle => 'Набрати м\'язи';

  @override
  String get profileSetupFitnessGoalImproveStamina => 'Покращити витривалість';

  @override
  String get profileSetupFitnessGoalGeneralFitness => 'Загальна фізична форма';

  @override
  String get profileSetupFitnessGoalImproveStrength => 'Покращити силу';

  @override
  String get profileSetupActivityLevelLabel => 'Рівень активності';

  @override
  String get profileSetupActivityLevelSedentary =>
      'Сидячий (мало або без вправ)';

  @override
  String get profileSetupActivityLevelLight =>
      'Легкий (вправи 1-3 дні/тиждень)';

  @override
  String get profileSetupActivityLevelModerate =>
      'Помірний (вправи 3-5 днів/тиждень)';

  @override
  String get profileSetupActivityLevelActive =>
      'Активний (вправи 6-7 днів/тиждень)';

  @override
  String get profileSetupActivityLevelVeryActive =>
      'Дуже активний (важкі вправи або фізична робота)';

  @override
  String get profileSetupButtonSaveChanges => 'Зберегти Зміни';

  @override
  String get profileSetupButtonCompleteProfile => 'Завершити Профіль';

  @override
  String get profileSetupErrorUserNotLoggedIn => 'Користувач не увійшов.';

  @override
  String get profileSetupErrorUsernameEmpty =>
      'Ім\'я користувача не може бути порожнім.';

  @override
  String get profileSetupErrorProfileNotFoundEdit =>
      'Профіль для редагування не знайдено. Будь ласка, спробуйте ще раз.';

  @override
  String profileSetupErrorFailedToLoad(String errorDetails) {
    return 'Не вдалося завантажити дані профілю: $errorDetails';
  }

  @override
  String get profileSetupErrorFailedAvatarUpload =>
      'Не вдалося завантажити аватар. Профіль не збережено.';

  @override
  String profileSetupErrorFailedToSave(String errorDetails) {
    return 'Помилка: $errorDetails';
  }

  @override
  String profileSetupSuccessMessage(String status) {
    return 'Профіль успішно $status!';
  }

  @override
  String get profileSetupStatusSaved => 'збережено';

  @override
  String get profileSetupStatusUpdated => 'оновлено';

  @override
  String get profileSetupCorrectFormErrorsSnackbar =>
      'Будь ласка, виправте помилки у формі.';

  @override
  String get profileSetupOptionalFieldSuffix => '(необов\'язково)';

  @override
  String get dashboardGreetingWelcome => 'Вітаємо,';

  @override
  String get dashboardSectionStats => 'СТАТИСТИКА';

  @override
  String get dashboardStatsWeightLabel => 'ВАГА';

  @override
  String get dashboardStatsStreakLabel => 'СТРІК';

  @override
  String get dashboardStatsAdherenceLabel => 'ДОТРИМАННЯ';

  @override
  String get dashboardSectionNotifications => 'СПОВІЩЕННЯ';

  @override
  String get dashboardNotificationsReadAll => 'ПРОЧИТАТИ ВСІ';

  @override
  String get dashboardNotificationsEmpty => 'Нових сповіщень немає.';

  @override
  String dashboardNotificationsError(String message) {
    return 'Помилка завантаження сповіщень: $message';
  }

  @override
  String get dashboardNotificationsLoading => 'Завантаження сповіщень...';

  @override
  String get dashboardSnackbarAllNotificationsRead =>
      'Усі сповіщення позначено як прочитані!';

  @override
  String get upcomingScheduleTitle => 'МАЙБУТНІЙ РОЗКЛАД (НА 7 ДНІВ)';

  @override
  String get upcomingScheduleRestDay => 'День відпочинку';

  @override
  String upcomingScheduleError(String message) {
    return 'Помилка: $message';
  }

  @override
  String get upcomingScheduleEmpty =>
      'Немає запланованих тренувань на найближчі 7 днів.';

  @override
  String get volumeTrendChartLogWorkouts =>
      'Записуйте тренування, щоб побачити тенденцію об\'єму.';

  @override
  String get volumeTrendChartLogMoreWorkouts =>
      'Запишіть щонайменше два тренування, щоб побачити тенденцію.';

  @override
  String volumeTrendChartSingleWorkoutVolume(String volume) {
    return 'Об\'єм останнього тренування: $volume тис. кг.\nПотрібно більше тренувань для відображення тенденції.';
  }

  @override
  String get volumeTrendChartLoading => 'Завантаження даних об\'єму...';

  @override
  String volumeTrendChartError(String message) {
    return 'Помилка завантаження об\'єму: $message';
  }

  @override
  String get startWorkoutButton => 'ПОЧАТИ ТРЕНУВАННЯ';

  @override
  String get startWorkoutFabErrorLogin =>
      'Будь ласка, увійдіть, щоб почати тренування.';

  @override
  String startWorkoutFabErrorActiveSession(String errorDetails) {
    return 'Помилка перевірки активної сесії: $errorDetails';
  }

  @override
  String startWorkoutFabErrorLoadRoutines(String errorDetails) {
    return 'Не вдалося завантажити розклади. Будь ласка, спробуйте ще раз. Помилка: $errorDetails';
  }

  @override
  String get startWorkoutFabNewRoutineCreatedSnackbar =>
      'Нову програму створено! Оберіть її зі списку, щоб почати.';

  @override
  String get dashboardTabRoutines => 'ПРОГРАМИ';

  @override
  String get dashboardTabExplore => 'ОГЛЯД';

  @override
  String get dashboardTabProgress => 'ПРОГРЕС';

  @override
  String get dashboardTabProfile => 'ПРОФІЛЬ';
}
