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
  String get authGateFinalizingAccountSetup =>
      'Завершення налаштування облікового запису...';

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

  @override
  String get userRoutinesScreenTitle => 'Мої Програми';

  @override
  String userRoutinesErrorLoad(String message) {
    return 'Помилка завантаження програм: $message';
  }

  @override
  String get userRoutinesEmptyTitle => 'У вас ще немає програм.';

  @override
  String get userRoutinesEmptySubtitle =>
      'Створіть програму, щоб почати організовувати свої тренування!';

  @override
  String get userRoutinesButtonCreateFirst => 'Створити Першу Програму';

  @override
  String get userRoutinesFabNewRoutine => 'НОВА ПРОГРАМА';

  @override
  String get routineListItemMenuStartWorkout => 'Почати Тренування';

  @override
  String get routineListItemMenuEditRoutine => 'Редагувати Програму';

  @override
  String get routineListItemMenuShareRoutine => 'Поділитися Програмою';

  @override
  String get routineListItemMenuDeleteRoutine => 'Видалити Програму';

  @override
  String get routineListItemDeleteConfirmTitle => 'Підтвердити Видалення';

  @override
  String routineListItemDeleteConfirmMessage(String routineName) {
    return 'Ви впевнені, що хочете видалити \"$routineName\"? Цю дію неможливо буде скасувати.';
  }

  @override
  String get routineListItemDeleteConfirmButtonCancel => 'Скасувати';

  @override
  String get routineListItemDeleteConfirmButtonDelete => 'Видалити';

  @override
  String routineListItemSnackbarDeleted(String routineName) {
    return 'Програму \"$routineName\" видалено.';
  }

  @override
  String routineListItemSnackbarErrorDelete(String errorDetails) {
    return 'Помилка видалення програми: $errorDetails';
  }

  @override
  String get createEditRoutineScreenTitleEdit => 'Редагувати Програму';

  @override
  String get createEditRoutineScreenTitleCreate => 'Створити Програму';

  @override
  String get createEditRoutineTooltipDelete => 'Видалити Програму';

  @override
  String get createEditRoutineSnackbarFormErrors =>
      'Будь ласка, виправте помилки у формі.';

  @override
  String createEditRoutineSuccessMessage(String message) {
    return '$message';
  }

  @override
  String createEditRoutineErrorMessage(String errorDetails) {
    return 'Помилка: $errorDetails';
  }

  @override
  String get createEditRoutineStatusUpdated => 'Програму оновлено успішно!';

  @override
  String get createEditRoutineStatusCreated => 'Програму створено успішно!';

  @override
  String get createEditRoutineStatusDeleted => 'Програму видалено успішно!';

  @override
  String get createEditRoutineErrorNameEmpty =>
      'Назва програми не може бути порожньою.';

  @override
  String get createEditRoutineErrorNoExercises =>
      'Програма повинна містити хоча б одну вправу.';

  @override
  String get createEditRoutineErrorDeleteNew =>
      'Неможливо видалити нову або незбережену програму.';

  @override
  String get createEditRoutineLoadingMessageSaving => 'Збереження програми...';

  @override
  String get createEditRoutineLoadingMessageDeleting => 'Видалення програми...';

  @override
  String get createEditRoutineNameLabel => 'Назва Програми*';

  @override
  String get createEditRoutineNameErrorEmpty => 'Назва не може бути порожньою';

  @override
  String get createEditRoutineDescriptionLabel => 'Опис (необов\'язково)';

  @override
  String get createEditRoutineScheduledDaysLabel => 'Заплановані дні:';

  @override
  String createEditRoutineExercisesLabel(int count) {
    return 'Вправи ($count):';
  }

  @override
  String get createEditRoutineButtonAddExercise => 'Додати';

  @override
  String get createEditRoutineNoExercisesPlaceholder =>
      'Ще не додано жодної вправи. Натисніть \"Додати\", щоб почати.';

  @override
  String get createEditRoutineButtonSaveChanges => 'Зберегти Зміни';

  @override
  String get createEditRoutineButtonCreateRoutine => 'Створити Програму';

  @override
  String addExerciseDialogTitle(String exerciseName) {
    return 'Додати \"$exerciseName\"';
  }

  @override
  String get addExerciseDialogSetsLabel => 'Кількість підходів';

  @override
  String get addExerciseDialogSetsErrorEmpty => 'Не може бути порожнім';

  @override
  String get addExerciseDialogSetsErrorInvalid => 'Має бути позитивним числом';

  @override
  String get addExerciseDialogNotesLabel => 'Нотатки (необов\'язково)';

  @override
  String get addExerciseDialogNotesHint =>
      'Напр., фокус на формі, пірамідні підходи';

  @override
  String get addExerciseDialogButtonCancel => 'Скасувати';

  @override
  String get addExerciseDialogButtonAdd => 'Додати Вправу';

  @override
  String editExerciseDialogTitle(String exerciseName) {
    return 'Редагувати \"$exerciseName\"';
  }

  @override
  String get editExerciseDialogButtonUpdate => 'Оновити';

  @override
  String get exerciseExplorerScreenTitleSelect => 'Обрати Вправу';

  @override
  String get exerciseExplorerScreenTitleLibrary => 'Бібліотека Вправ';

  @override
  String exerciseExplorerErrorLoad(String message) {
    return 'Помилка завантаження вправ: $message';
  }

  @override
  String get exerciseExplorerEmpty =>
      'У бібліотеці ще немає вправ. Вміст додається!';

  @override
  String get exerciseExplorerButtonTryAgain => 'Спробувати Ще Раз';

  @override
  String get exerciseExplorerLoading => 'Завантаження вправ...';

  @override
  String get dashboardButtonSendTestNotifications =>
      'Надіслати тестові сповіщення';

  @override
  String get leagueScreenButtonBackTooltip => 'Назад';

  @override
  String get leagueScreenLeaderboardTitle => 'ТАБЛИЦЯ ЛІДЕРІВ';

  @override
  String leagueScreenErrorLoad(String errorMessage) {
    return 'Помилка: $errorMessage';
  }

  @override
  String get leagueScreenNoPlayers => 'У цій лізі ще немає гравців.';

  @override
  String get leagueScreenButtonTryAgain => 'Спробувати ще';

  @override
  String get notificationDetailRelatedInfoTitle => 'Пов\'язана інформація:';

  @override
  String get notificationDetailRelatedInfoTypeLabel => 'Тип:';

  @override
  String get notificationDetailRelatedInfoIdLabel => 'ID:';

  @override
  String get notificationDetailStatusRead => 'Прочитано';

  @override
  String notificationListItemSnackbarRemoved(String notificationTitle) {
    return 'Сповіщення \"$notificationTitle\" видалено.';
  }

  @override
  String get notificationListItemSnackbarUndo => 'ВІДМІНИТИ';

  @override
  String get notificationListItemDismissDelete => 'Видалити';

  @override
  String get profileScreenLogoutConfirmTitle => 'Підтвердити вихід';

  @override
  String get profileScreenLogoutConfirmMessage =>
      'Ви впевнені, що хочете вийти?';

  @override
  String get profileScreenLogoutConfirmButtonCancel => 'Скасувати';

  @override
  String get profileScreenLogoutConfirmButtonLogOut => 'Вийти';

  @override
  String profileScreenLogoutErrorSnackbar(String errorDetails) {
    return 'Помилка виходу: $errorDetails';
  }

  @override
  String get profileScreenNameFallbackUser => 'Користувач';

  @override
  String get profileScreenStatLabelFollowers => 'ПІДПИСНИКИ';

  @override
  String get profileScreenStatLabelFollowing => 'ПІДПИСКИ';

  @override
  String get profileScreenStatLabelBestStreak => 'КРАЩИЙ СТРІК';

  @override
  String get profileScreenStatLabelWeight => 'ВАГА';

  @override
  String get profileScreenUnitKg => 'КГ';

  @override
  String get profileScreenGoalLabel => 'ЦІЛЬ: ';

  @override
  String get profileScreenLastTrainingLabel => 'ОСТАННЄ ТРЕНУВАННЯ: ';

  @override
  String get profileScreenRewardsTitle => 'НАГОРОДИ';

  @override
  String get profileScreenNoRewards =>
      'Нагород ще не розблоковано. Продовжуйте тренуватися!';

  @override
  String get profileScreenMyPostsTitle => 'МОЇ ДОПИСИ';

  @override
  String get profileScreenNoPosts => 'Ви ще не зробили жодного допису.';

  @override
  String get profileScreenButtonEditProfile => 'РЕДАГУВАТИ ПРОФІЛЬ';

  @override
  String get profileScreenButtonLogOut => 'ВИЙТИ';

  @override
  String profileScreenErrorLoadProfile(String errorMessage) {
    return 'Помилка завантаження профілю: $errorMessage';
  }

  @override
  String get profileScreenErrorUnexpected =>
      'Сталася неочікувана помилка під час завантаження вашого профілю.';

  @override
  String createPostScreenLabelPostType(String postType) {
    return 'Тип допису: $postType';
  }

  @override
  String get createPostSegmentStandard => 'Стандартний';

  @override
  String get createPostSegmentRoutine => 'Програма';

  @override
  String get createPostSegmentRecord => 'Рекорд';

  @override
  String get createPostLabelSharedRoutine => 'Поширена програма:';

  @override
  String get createPostErrorRoutineUnavailable => 'Деталі програми недоступні';

  @override
  String get createPostRoutineExerciseCountSuffix => ' вправ(и)';

  @override
  String get createPostLabelRecordDetailsReadOnly =>
      'Деталі рекорду (тільки для читання):';

  @override
  String get createPostLabelRecordExercise => 'Вправа: ';

  @override
  String get createPostLabelRecordWeight => 'Вага: ';

  @override
  String get createPostUnitKgSuffix => ' кг';

  @override
  String get createPostLabelRecordReps => 'Повтори: ';

  @override
  String get createPostLabelRecordVideo => 'Відео: ';

  @override
  String get createPostLabelRecordDetails => 'Деталі рекорду:';

  @override
  String get createPostHintSelectExercise => 'Оберіть вправу*';

  @override
  String get createPostHintRecordWeight => 'Вага (кг)*';

  @override
  String get createPostErrorRecordWeightInvalid => 'Некоректна вага';

  @override
  String get createPostHintRecordReps => 'Повторення*';

  @override
  String get createPostErrorRecordRepsInvalid => 'Некоректні повторення';

  @override
  String get createPostHintRecordVideoUrl => 'URL відео (необов\'язково)';

  @override
  String get createPostErrorRecordVideoUrlInvalid => 'Введіть дійсний URL';

  @override
  String get createPostLabelAttachImageOptionalReplace =>
      'Прикріпити зображення (необов\'язково - замінить існуюче)';

  @override
  String get createPostLabelAttachImageOptional =>
      'Прикріпити зображення (необов\'язково)';

  @override
  String get createPostButtonAddImage => 'Додати зображення';

  @override
  String get createPostTooltipRemoveImage => 'Видалити зображення';

  @override
  String get createPostTooltipRemoveExistingImage =>
      'Видалити існуюче зображення';

  @override
  String get createPostToggleEnableComments => 'Увімкнути коментарі';

  @override
  String get createPostCommentsEnabledSubtitle =>
      'Користувачі можуть коментувати цей допис';

  @override
  String get createPostCommentsDisabledSubtitle => 'Коментарі вимкнені';

  @override
  String get createPostHintTextContent => 'Що у вас на думці?';

  @override
  String get createPostErrorContentOrImageRequired =>
      'Вміст допису або зображення обов\'язкові.';

  @override
  String get createPostAppBarTitleEdit => 'Редагувати допис';

  @override
  String get createPostAppBarTitleShareRoutine => 'Поділитися програмою';

  @override
  String get createPostAppBarTitleCreate => 'Створити допис';

  @override
  String get createPostButtonSaveChanges => 'Зберегти зміни';

  @override
  String get createPostButtonPublish => 'Опублікувати';

  @override
  String createPostSnackbarSuccess(String status) {
    return 'Допис успішно $status!';
  }

  @override
  String createPostSnackbarError(String errorDetails) {
    return 'Помилка: $errorDetails';
  }

  @override
  String get createPostStatusUpdated => 'оновлено';

  @override
  String get createPostStatusPublished => 'опубліковано';

  @override
  String get createPostLoadingUpdating => 'Оновлення допису...';

  @override
  String get createPostLoadingPublishing => 'Публікація допису...';

  @override
  String get createPostErrorUserNotLoggedIn => 'Користувач не увійшов.';

  @override
  String get createPostErrorContentEmptyStandard =>
      'Вміст допису не може бути порожнім для стандартного допису без зображення.';

  @override
  String get createPostErrorFetchProfile =>
      'Не вдалося отримати профіль користувача.';

  @override
  String get createPostErrorUploadMedia => 'Не вдалося завантажити медіа.';

  @override
  String get exploreScreenEmptyTitle => 'Ще нічого немає.';

  @override
  String get exploreScreenEmptySubtitle =>
      'Будьте першим, хто чимось поділиться!';

  @override
  String exploreScreenErrorLoad(String message) {
    return 'Помилка завантаження дописів: $message';
  }

  @override
  String get exploreScreenButtonTryAgain => 'Спробувати ще';

  @override
  String get exploreScreenFabTooltipCreatePost => 'Створити допис';

  @override
  String get followListScreenTitleFollowers => 'Підписники';

  @override
  String get followListScreenTitleFollowing => 'Підписки';

  @override
  String followListScreenErrorLoad(String message) {
    return 'Помилка: $message';
  }

  @override
  String get followListScreenEmptyFollowers =>
      'Цей користувач ще не має підписників.';

  @override
  String get followListScreenEmptyFollowing =>
      'Цей користувач ні на кого не підписаний.';

  @override
  String get followListScreenButtonTryAgain => 'Спробувати ще';

  @override
  String get followListScreenErrorUnexpected => 'Щось пішло не так.';

  @override
  String get postDetailScreenAppBarTitleFallback => 'Допис';

  @override
  String get postDetailMenuEditPost => 'Редагувати допис';

  @override
  String get postDetailMenuDisableComments => 'Вимкнути коментарі';

  @override
  String get postDetailMenuEnableComments => 'Увімкнути коментарі';

  @override
  String get postDetailMenuDeletePost => 'Видалити допис';

  @override
  String get postDetailDeleteConfirmTitle => 'Видалити допис?';

  @override
  String get postDetailDeleteConfirmMessage =>
      'Ви впевнені, що хочете видалити цей допис? Цю дію неможливо буде скасувати, і вона видалить усі пов\'язані коментарі та медіа.';

  @override
  String get postDetailDeleteConfirmButtonCancel => 'Скасувати';

  @override
  String get postDetailDeleteConfirmButtonDelete => 'Видалити';

  @override
  String postDetailSnackbarErrorGeneric(String errorDetails) {
    return 'Помилка: $errorDetails';
  }

  @override
  String postDetailSnackbarPostDeleted(String postId) {
    return 'Допис \"$postId\" видалено.';
  }

  @override
  String get postDetailErrorPostNotFound =>
      'Допис не знайдено або не вдалося завантажити.';

  @override
  String get postDetailLoading => 'Завантаження деталей допису...';

  @override
  String get postDetailLikesSuffixSingular => ' Вподобайка';

  @override
  String get postDetailLikesSuffixPlural => ' Вподобайок';

  @override
  String get postDetailCommentsSuffixSingular => ' Коментар';

  @override
  String get postDetailCommentsSuffixPlural => ' Коментарів';

  @override
  String get postDetailCommentsSectionTitle => 'Коментарі';

  @override
  String get postDetailCommentsDisabledMessage =>
      'Коментарі до цього допису вимкнені.';

  @override
  String get postDetailCommentsEmptyMessage =>
      'Коментарів ще немає. Будьте першим!';

  @override
  String get postDetailCommentInputHint => 'Написати коментар...';

  @override
  String get postDetailButtonValidate => 'ПІДТВЕРДИТИ';

  @override
  String get postDetailButtonDispute => 'ОСКАРЖИТИ';

  @override
  String get recordStatusVerified => 'ПІДТВЕРДЖЕНО';

  @override
  String get recordStatusRejected => 'ВІДХИЛЕНО';

  @override
  String get recordStatusExpired => 'ПРОСРОЧЕНО';

  @override
  String get recordStatusPending => 'ОЧІКУЄ ГОЛОСУВАННЯ';

  @override
  String get recordStatusContested => 'ОСКАРЖЕНО';

  @override
  String get recordStatusUnknown => 'НЕВІДОМО';

  @override
  String get postDetailButtonWatchProof => 'Дивитися доказ';

  @override
  String get viewUserProfileAppBarTitleFallback => 'Профіль користувача';

  @override
  String get viewUserProfileErrorNotAuth => 'Користувач не автентифікований.';

  @override
  String viewUserProfileErrorLoadProfile(String message) {
    return 'Не вдалося завантажити профіль: $message';
  }

  @override
  String viewUserProfileErrorInit(String message) {
    return 'Не вдалося ініціалізувати: $message';
  }

  @override
  String get viewUserProfileErrorFollowInvalidOp =>
      'Не вдалося підписатися/відписатися: Недійсна операція.';

  @override
  String viewUserProfileErrorFollowGeneric(String action, String errorDetails) {
    return 'Не вдалося $action: $errorDetails';
  }

  @override
  String get viewUserProfileErrorFollowActionFollow => 'підписатися';

  @override
  String get viewUserProfileErrorFollowActionUnfollow => 'відписатися';

  @override
  String viewUserProfileErrorInvalidStateFollow(String currentState) {
    return 'Неможливо обробити підписку/відписку в поточному стані: $currentState';
  }

  @override
  String get viewUserProfileStatLabelLevel => 'Рівень';

  @override
  String get viewUserProfileButtonUnfollow => 'ВІДПИСАТИСЯ';

  @override
  String get viewUserProfileButtonFollow => 'ПІДПИСАТИСЯ';

  @override
  String get viewUserProfilePostsTitle => 'Дописи користувача';

  @override
  String viewUserProfileNoPosts(String username) {
    return 'Дописи користувача @$username з\'являться тут.';
  }

  @override
  String get viewUserProfileErrorProfileNotAvailable => 'Профіль недоступний.';

  @override
  String get commentListItemEditDialogTitle => 'Редагувати коментар';

  @override
  String get commentListItemDeleteDialogTitle => 'Видалити коментар?';

  @override
  String get commentListItemEditDialogHint => 'Ваш коментар...';

  @override
  String get commentListItemDeleteDialogMessage =>
      'Ви впевнені, що хочете видалити цей коментар? Цю дію неможливо буде скасувати.';

  @override
  String get commentListItemDialogButtonCancel => 'Скасувати';

  @override
  String get commentListItemDialogButtonSave => 'Зберегти';

  @override
  String get commentListItemDialogButtonDelete => 'Видалити';

  @override
  String get commentListItemSnackbarDeleted => 'Коментар видалено.';

  @override
  String get commentListItemMenuEdit => 'Редагувати';

  @override
  String get commentListItemMenuDelete => 'Видалити';

  @override
  String get activeWorkoutAppBarTitleFallback => 'Активне Тренування';

  @override
  String get activeWorkoutDialogCancelTitle => 'Скасувати тренування?';

  @override
  String get activeWorkoutDialogCompleteTitle => 'Завершити тренування?';

  @override
  String get activeWorkoutDialogCancelMessage =>
      'Ви впевнені, що хочете скасувати це тренування? Прогрес не буде збережено.';

  @override
  String get activeWorkoutDialogCompleteMessage =>
      'Ви впевнені, що хочете завершити та зберегти це тренування?';

  @override
  String get activeWorkoutDialogButtonNo => 'Ні';

  @override
  String get activeWorkoutDialogButtonYesCancel => 'Так, скасувати';

  @override
  String get activeWorkoutDialogButtonNoContinue => 'Ні, продовжити';

  @override
  String get activeWorkoutDialogButtonYesComplete => 'Так, завершити';

  @override
  String get activeWorkoutLoading => 'Завантаження тренування...';

  @override
  String get activeWorkoutLoadingStartingNew => 'Початок нового тренування...';

  @override
  String get activeWorkoutNoneMessage => 'Активного тренування не знайдено.';

  @override
  String get activeWorkoutButtonBackToRoutines => 'Назад до програм';

  @override
  String get activeWorkoutErrorNoExercises => 'Це тренування не містить вправ.';

  @override
  String get activeWorkoutButtonAddFirstExercise => 'Додати першу вправу';

  @override
  String get activeWorkoutButtonFinishEmpty => 'Завершити порожнє тренування';

  @override
  String activeWorkoutErrorExerciseNoSets(String exerciseName) {
    return 'Помилка: Вправа \'\'$exerciseName\'\' не має підходів.';
  }

  @override
  String get activeWorkoutErrorExerciseNoSetsHelp =>
      'Будь ласка, відредагуйте програму або зверніться до підтримки.';

  @override
  String get activeWorkoutButtonGoBack => 'Повернутися назад';

  @override
  String get activeWorkoutErrorUnexpected =>
      'Сталася неочікувана помилка. Будь ласка, перезапустіть.';

  @override
  String get workoutCompleteTitleLevelUp => 'НОВИЙ РІВЕНЬ!';

  @override
  String get workoutCompleteTitleDefault => 'Тренування Завершено!';

  @override
  String workoutCompleteSubtitleLevelUp(int level) {
    return 'Ви досягли $level рівня!';
  }

  @override
  String workoutCompleteStatDuration(int durationMinutes) {
    return 'Тривалість: $durationMinutes хв';
  }

  @override
  String workoutCompleteStatVolume(String volume) {
    return 'Загальний об\'єм: $volume КГ';
  }

  @override
  String workoutCompleteStatXpGained(int xpGained) {
    return '+$xpGained XP НАБУТО';
  }

  @override
  String workoutCompleteXpBarLabelLevel(int level) {
    return 'РІВ $level';
  }

  @override
  String workoutCompleteXpBarText(String currentXp, String totalXp) {
    return '$currentXp/$totalXp XP';
  }

  @override
  String get workoutCompleteButtonAwesome => 'Чудово!';

  @override
  String get currentSetDisplayWeightDialogTitle => 'Встановити вагу (КГ)';

  @override
  String get currentSetDisplayWeightDialogHint => 'Введіть вагу';

  @override
  String get currentSetDisplayWeightDialogButtonCancel => 'Скасувати';

  @override
  String get currentSetDisplayWeightDialogButtonSet => 'Встановити';

  @override
  String get currentSetDisplaySetLabelPrefix => 'ПІДХІД ';

  @override
  String get currentSetDisplayWeightLabelPrefix => 'ВАГА: ';

  @override
  String get currentSetDisplayUnitKgSuffix => ' КГ';

  @override
  String get currentSetDisplayRepsLabelSuffix => ' ПОВТОРЕНЬ';

  @override
  String get currentSetDisplayRpeHelpText =>
      'Оцініть, наскільки важко було виконати повторення\nза шкалою від 0 до 10.';

  @override
  String get currentSetDisplayNoRepsPlaceholder => 'Додайте повторення';

  @override
  String get currentSetDisplayButtonPrevSet => '< ПОПЕРЕД. ПІДХІД';

  @override
  String get currentSetDisplayButtonFinishWorkout => 'ЗАВЕРШИТИ ТРЕНУВАННЯ';

  @override
  String get currentSetDisplayButtonNextExercise => 'НАСТУПНА ВПРАВА >';

  @override
  String get currentSetDisplayButtonNextSet => 'НАСТУПНИЙ ПІДХІД >';

  @override
  String get progressScreenLoadingData => 'Завантаження даних прогресу...';

  @override
  String get progressScreenRefreshingData => 'Оновлення даних прогресу...';

  @override
  String get progressScreenErrorNotAuthRefresh =>
      'Користувач не автентифікований. Неможливо оновити.';

  @override
  String get progressScreenErrorProfileNotFoundRefresh =>
      'Профіль користувача не знайдено під час оновлення.';

  @override
  String progressScreenErrorFailedRefresh(String errorMessage) {
    return 'Не вдалося оновити дані: $errorMessage';
  }

  @override
  String get progressScreenLoadingWorkoutStats =>
      'Завантаження статистики тренувань...';

  @override
  String get progressScreenRefreshingWorkoutStats =>
      'Оновлення статистики тренувань...';

  @override
  String progressScreenErrorFailedProcessWorkoutData(String errorMessage) {
    return 'Не вдалося обробити дані тренувань: $errorMessage';
  }

  @override
  String progressScreenXpToNextLevel(int xp) {
    return '$xp XP ДО НАСТУПНОГО РІВНЯ!';
  }

  @override
  String get progressScreenVolumeTitle => 'ОБ\'ЄМ (ОСТАННІ 7 ДНІВ - ПІДХОДИ)';

  @override
  String get progressScreenNoVolumeData =>
      'Немає даних про тренування за останні 7 днів для відображення на карті м\'язів.';

  @override
  String progressScreenRpeTrendTitle(int maxWorkouts) {
    return 'СЕР. ВИСНАЖЕННЯ (ТРЕНД ЗА ОСТАННІ $maxWorkouts ТРЕНУВАНЬ)';
  }

  @override
  String get progressScreenNoRpeData =>
      'Останнім часом не було зареєстровано даних RPE для жодної вправи.';

  @override
  String get progressScreenAvgRpeLabel => 'СЕР. RPE - ';

  @override
  String progressScreenStrengthTrendTitle(int maxWorkouts) {
    return 'СИЛА (ТРЕНД ВАГИ - ОСТАННІ $maxWorkouts ТРЕНУВАНЬ)';
  }

  @override
  String get progressScreenNoWeightData =>
      'Останнім часом не було зареєстровано даних про вагу для жодної вправи.';

  @override
  String get progressScreenAvgWeightLabel => 'СЕР. ВАГА - ';

  @override
  String get progressScreenAdviceTitle => 'ПОРАДИ';

  @override
  String get progressScreenNoAdvice =>
      'Наразі нових порад немає. Продовжуйте в тому ж дусі!';

  @override
  String progressScreenErrorLoadAdvice(String message) {
    return 'Помилка завантаження порад: $message';
  }

  @override
  String get progressScreenLoadingAdvice => 'Завантаження порад...';

  @override
  String get progressScreenButtonSendTestAdvice => 'Надіслати тестові поради';

  @override
  String get progressScreenButtonTryAgain => 'Спробувати ще';

  @override
  String progressScreenErrorLoadingProfile(String errorMessage) {
    return 'Помилка завантаження профілю: $errorMessage';
  }

  @override
  String get progressScreenNoData =>
      'Даних про прогрес ще немає. Почніть тренуватися!';

  @override
  String progressScreenLevelLabel(int level) {
    return 'РІВ $level';
  }

  @override
  String progressScreenXpProgressText(String currentXp, String totalXp) {
    return '$currentXp/$totalXp XP';
  }

  @override
  String progressScreenExercisePlaceholder(String placeholder) {
    return 'ВПРАВА $placeholder';
  }

  @override
  String get progressScreenKgUnit => 'КГ';

  @override
  String get postCardRoutineShareTitle => 'ПОШИРЕНА ПРОГРАМА';

  @override
  String postCardRoutineAuthorPrefix(String authorUsername) {
    return 'від @$authorUsername';
  }

  @override
  String get postCardRoutineExercisesLabel => 'ВПРАВА';

  @override
  String get postCardRoutineExercisesLabelPlural => 'ВПРАВ';

  @override
  String get postCardRoutineNoSchedule => 'БЕЗ РОЗКЛАДУ';

  @override
  String get postCardRoutineScheduledDaysLabel => 'ЗАПЛАНОВАНІ ДНІ';

  @override
  String get postCardRoutineButtonAddToList => 'ДОДАТИ ДО МОГО СПИСКУ';

  @override
  String get postCardRoutineSnackbarLoginToAdd =>
      'Будь ласка, увійдіть, щоб додавати програми.';

  @override
  String get postCardRoutineSnackbarAlreadyOwn => 'Це вже ваша програма!';

  @override
  String get postCardRoutineSnackbarAdded =>
      'Програму додано до вашого списку!';

  @override
  String postCardRoutineSnackbarErrorAdd(String errorDetails) {
    return 'Не вдалося додати програму: $errorDetails';
  }

  @override
  String get postCardRoutineIsYours => 'Це ваша поширена програма.';

  @override
  String get postCardRoutineLoginToAdd => 'Увійдіть, щоб додати цю програму.';

  @override
  String get postCardRecordClaimTitle => 'ЗАЯВКА НА РЕКОРД';

  @override
  String get postCardRecordExerciseNameFallback => 'РЕКОРД ВПРАВИ';

  @override
  String postCardRecordRepsKgFormat(String reps, String weight) {
    return '$reps ПОВТОРЕНЬ / $weight КГ';
  }

  @override
  String get postCardRecordRepsFallback => 'Н/Д';

  @override
  String get postCardRecordWeightFallback => 'Н/Д';

  @override
  String get achievementEarlyBirdName => 'РАННЯ ПТАШКА';

  @override
  String get achievementEarlyBirdDescription =>
      'Ласкаво просимо до клубу! Дякуємо, що приєдналися до MuscleUP.';

  @override
  String get achievementFirstWorkoutName => 'ПЕРШИЙ КРОК';

  @override
  String get achievementFirstWorkoutDescription =>
      'Ви завершили своє перше тренування! Так тримати!';

  @override
  String get achievementConsistentKing10Name => 'ЗІРКА СТРІКУ (10)';

  @override
  String get achievementConsistentKing10Description =>
      '10-денний стрік тренувань! Ви у вогні!';

  @override
  String get achievementConsistentKing30Name => 'КОРОЛЬ ПОСЛІДОВНОСТІ (30)';

  @override
  String get achievementConsistentKing30Description =>
      '30-денний стрік тренувань! Нестримний!';

  @override
  String get achievementVolumeStarterName => 'СТАРТЕР ОБ\'ЄМУ';

  @override
  String get achievementVolumeStarterDescription =>
      'Піднято понад 10 000 кг загального об\'єму!';

  @override
  String get achievementVolumeProName => 'ПРОФІ ОБ\'ЄМУ';

  @override
  String get achievementVolumeProDescription =>
      'Піднято понад 100 000 кг загального об\'єму! Неймовірна сила!';

  @override
  String get achievementLevel5ReachedName => 'ДОСЯГНУТО 5 РІВЕНЬ';

  @override
  String get achievementLevel5ReachedDescription =>
      'Вітаємо з досягненням 5-го рівня!';

  @override
  String get achievementLevel10ReachedName => 'ДОСЯГНУТО 10 РІВЕНЬ';

  @override
  String get achievementLevel10ReachedDescription =>
      'Ого! 10-й рівень! Ви справжній ентузіаст MuscleUP!';

  @override
  String achievementPersonalRecordSetName(String detail) {
    return 'НОВИЙ РЕКОРД: $detail!';
  }

  @override
  String achievementPersonalRecordSetDescription(String detail) {
    return 'Вітаємо зі встановленням нового особистого рекорду в $detail!';
  }

  @override
  String achievementConditionStreak(int currentStreak, int targetStreak) {
    return 'Поточний найкращий стрік: $currentStreak/$targetStreak днів.';
  }

  @override
  String get achievementConditionVolume =>
      'Потрібне відстеження загального об\'єму в профілі.';

  @override
  String achievementConditionLevel(int currentLevel, int targetLevel) {
    return 'Поточний рівень: $currentLevel/$targetLevel.';
  }

  @override
  String get currentSetDisplayMuscleGroupsLoading =>
      'Завантаження груп м\'язів...';

  @override
  String get leaderboardPlayerNameFallback => 'Гравець';

  @override
  String get xpAbbreviation => 'XP';

  @override
  String get levelAbbreviation => 'РІВ';

  @override
  String get dialogButtonClose => 'Закрити';

  @override
  String get routineListItemExerciseCountSuffix => ' вправ(и)';

  @override
  String get postDetailMenuTooltipOptions => 'Опції допису';

  @override
  String get commentListItemErrorEmpty => 'Коментар не може бути порожнім';

  @override
  String get commentListItemMenuTooltip => 'Опції коментаря';

  @override
  String get testNotificationWelcomeTitle => 'Вітальний бонус!';

  @override
  String get testNotificationWelcomeMessage =>
      'Ви отримали 100 XP за приєднання!';

  @override
  String get testNotificationReminderTitle => 'Заплановано тренування';

  @override
  String get testNotificationReminderMessage =>
      'Ваше тренування \'Full Body Blast\' заплановано на завтра.';

  @override
  String get testNotificationSystemTitle => 'Технічне обслуговування';

  @override
  String get testNotificationSystemMessage =>
      'Заплановане технічне обслуговування в неділю о 2:00.';

  @override
  String get testNotificationAdviceTitle1 => 'Порада щодо гідратації';

  @override
  String get testNotificationAdviceMessage1 =>
      'Не забувайте випивати щонайменше 8 склянок води сьогодні, особливо в дні тренувань!';

  @override
  String get testNotificationAdviceTitle2 => 'Відпочинок та відновлення';

  @override
  String get testNotificationAdviceMessage2 =>
      'М\'язи ростуть під час відпочинку. Переконайтеся, що ви спите 7-9 годин для оптимального відновлення.';

  @override
  String get testNotificationAdviceTitle3 => 'Порада щодо харчування';

  @override
  String get testNotificationAdviceMessage3 =>
      'Надавайте перевагу споживанню білка протягом години після тренування для допомоги у відновленні м\'язів.';

  @override
  String get testNotificationAdviceSentSnackbar =>
      'Тестові поради надіслано! Перевірте ваші сповіщення та розділ ПОРАДИ.';

  @override
  String get notificationNewFollowerTitle => 'Новий підписник!';

  @override
  String notificationNewFollowerMessage(String username) {
    return '$username почав(ла) стежити за вами.';
  }

  @override
  String get notificationXpForVotingTitle => 'XP за голосування!';

  @override
  String notificationXpForVotingMessage(String xp) {
    return 'Ви отримали $xp XP за голосування за заявку на рекорд.';
  }

  @override
  String get notificationRecordVerifiedTitle => 'Рекорд підтверджено!';

  @override
  String notificationRecordVerifiedMessage(
    String exerciseName,
    String weight,
    String reps,
  ) {
    return 'Вітаємо! Ваш рекорд у \"$exerciseName\" ($weightкг x $reps повт.) було підтверджено спільнотою!';
  }

  @override
  String get notificationRecordRejectedTitle => 'Заявку на рекорд відхилено';

  @override
  String notificationRecordRejectedMessage(String exerciseName) {
    return 'Вашу заявку на рекорд у \"$exerciseName\" цього разу не було підтверджено спільнотою.';
  }

  @override
  String get notificationRecordExpiredTitle => 'Термін заявки на рекорд минув';

  @override
  String notificationRecordExpiredMessage(String exerciseName) {
    return 'Голосування за вашу заявку на рекорд у \"$exerciseName\" завершилося без чіткого результату.';
  }

  @override
  String notificationXpForRecordTitle(String exerciseName) {
    return 'Новий рекорд: $exerciseName підтверджено!';
  }

  @override
  String notificationXpForRecordMessage(
    String xp,
    String weight,
    String reps,
    String exerciseName,
  ) {
    return 'Ви заробили $xp XP за ваш підтверджений рекорд $weightкг x $reps повт.!';
  }

  @override
  String get achievement_firstWorkout_title => 'Перший крок';

  @override
  String get achievement_firstWorkout_message =>
      'Ви завершили своє перше тренування! Так тримати!';

  @override
  String get achievement_profileSetup_title => 'Рання пташка';

  @override
  String get achievement_profileSetup_message =>
      'Ласкаво просимо до клубу! Дякуємо, що приєдналися до MuscleUP.';

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Нд';

  @override
  String get loginPageErrorInvalidCredential =>
      'Неправильні дані для входу. Будь ласка, перевірте вашу пошту та пароль.';
}
