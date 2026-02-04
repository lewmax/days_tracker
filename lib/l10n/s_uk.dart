// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class SUk extends S {
  SUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'DaysTracker';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get myVisits => 'Мої візити';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get addVisit => 'Додати візит';

  @override
  String get editVisit => 'Редагувати візит';

  @override
  String get visitDetails => 'Деталі візиту';

  @override
  String get saveVisit => 'Зберегти візит';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get countryLabel => 'Країна *';

  @override
  String get cityLabel => 'Місто *';

  @override
  String get dateRangeLabel => 'Діапазон дат *';

  @override
  String get useCurrentLocation => 'Використати поточне місце';

  @override
  String get visitAddedSuccess => 'Візит успішно додано';

  @override
  String get visitUpdatedSuccess => 'Візит успішно оновлено';

  @override
  String get loading => 'Завантаження...';

  @override
  String get loadingVisit => 'Завантаження візиту...';

  @override
  String get loadingVisits => 'Завантаження візитів...';

  @override
  String get loadingSettings => 'Завантаження налаштувань...';

  @override
  String get loadingStatistics => 'Завантаження статистики...';

  @override
  String get initializing => 'Ініціалізація...';

  @override
  String get noVisitsYet => 'Візитів ще немає';

  @override
  String get noVisitsSubtitle =>
      'Відстежуйте подорожі автоматично або додавайте вручну.';

  @override
  String get locationTracking => 'Відстеження локації';

  @override
  String get backgroundTracking => 'Фоновий трекінг';

  @override
  String get backgroundTrackingSubtitle =>
      'Відстежувати локацію щогодини у фоні';

  @override
  String get testLocationNow => 'Перевірити локацію зараз';

  @override
  String get testLocationSubtitle =>
      'Отримати поточну позицію та зберегти пінг';

  @override
  String get preferences => 'Налаштування';

  @override
  String get dayCountingRule => 'Правило підрахунку днів';

  @override
  String get anyPresence => 'Будь-яка присутність';

  @override
  String get twoOrMorePings => '2+ пінги';

  @override
  String get dataManagement => 'Управління даними';

  @override
  String get exportData => 'Експорт даних';

  @override
  String get exportDataSubtitle => 'Зберегти всі дані у JSON файл';

  @override
  String get exportShareSubject => 'Експорт даних DaysTracker';

  @override
  String get importData => 'Імпорт даних';

  @override
  String get importDataSubtitle => 'Завантажити дані з JSON файлу';

  @override
  String get importConfirmMessage =>
      'Це замінить усі існуючі дані імпортованими. Це не можна скасувати. Продовжити?';

  @override
  String get confirmImport => 'Імпорт';

  @override
  String get clearAllData => 'Очистити всі дані';

  @override
  String get clearAllDataSubtitle => 'Видалити всі візити та статистику';

  @override
  String get clearAllDataConfirmMessage =>
      'Будуть видалені всі візити, пінги та статистика. Це не можна скасувати.';

  @override
  String get deleteEverything => 'Видалити все';

  @override
  String get apiConfiguration => 'Налаштування API';

  @override
  String get googleMapsApiKey => 'Ключ Google Maps API';

  @override
  String get apiKeyConfigured => 'Налаштовано';

  @override
  String get apiKeyNotConfigured => 'Не налаштовано';

  @override
  String get apiKeyDialogDescription =>
      'Введіть ключ Google Maps API для геокодування.';

  @override
  String get apiKeyLabel => 'Ключ API';

  @override
  String get apiKeyHint => 'AIza...';

  @override
  String get apiKeySaved => 'Ключ API збережено';

  @override
  String get about => 'Про додаток';

  @override
  String get version => 'Версія';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get privacy => 'Конфіденційність';

  @override
  String get privacySubtitle =>
      'Усі дані зберігаються локально. Без хмарної синхронізації.';

  @override
  String get sourceCode => 'Вихідний код';

  @override
  String get viewOnGitHub => 'Переглянути на GitHub';

  @override
  String get githubLinkNotConfigured => 'Посилання на GitHub не налаштовано';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get remove => 'Видалити';

  @override
  String get retry => 'Повторити';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get delete => 'Видалити';

  @override
  String get visitNotFound => 'Візит не знайдено';

  @override
  String get timePeriod => 'Період часу';

  @override
  String get timePeriodLabel => 'Період часу';

  @override
  String get viewMode => 'Режим перегляду';

  @override
  String get chronologicalView => 'Хронологічний вигляд';

  @override
  String get noVisitsForDay => 'Немає візитів за цей день.';

  @override
  String get noCountryData => 'Немає даних по країнах';

  @override
  String get noCountryDataSubtitle =>
      'Почніть відстежувати візити, щоб бачити статистику.';

  @override
  String get noCountryDataAvailable => 'Немає доступних даних по країнах.';

  @override
  String countriesCount(Object count) {
    return 'у $count країнах';
  }

  @override
  String get countries => 'Країни';

  @override
  String get pleaseSelectCountry => 'Оберіть країну';

  @override
  String get pleaseSelectCity => 'Оберіть місто';

  @override
  String get pleaseSelectStartDate => 'Оберіть дату початку';

  @override
  String get pleaseFillAllFields => 'Заповніть усі обов\'язкові поля';

  @override
  String failedToShareExport(Object error) {
    return 'Не вдалося поділитися експортом: $error';
  }

  @override
  String get fileEmptyOrUnreadable => 'Файл порожній або не читається';

  @override
  String failedToReadFile(Object error) {
    return 'Не вдалося прочитати файл: $error';
  }

  @override
  String get navVisits => 'Візити';

  @override
  String get navStatistics => 'Статистика';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get addVisitSemanticLabel => 'Додати візит';

  @override
  String get unknownCity => 'Невідоме місто';

  @override
  String get unknownCountry => 'Невідома країна';

  @override
  String get activeVisit => 'Активний візит';

  @override
  String get startDate => 'Дата початку';

  @override
  String get endDate => 'Дата завершення';

  @override
  String get duration => 'Тривалість';

  @override
  String get source => 'Джерело';

  @override
  String get lastUpdated => 'Останнє оновлення';

  @override
  String get sourceAuto => 'Автоматично (GPS)';

  @override
  String get sourceManual => 'Введено вручну';

  @override
  String daysCount(Object count) {
    return '$count дн.';
  }

  @override
  String totalDaysTracked(Object count) {
    return 'Всього днів: $count';
  }

  @override
  String get daysTracked => 'днів відстежено';

  @override
  String get deleteVisit => 'Видалити візит';

  @override
  String deleteVisitConfirm(Object cityName) {
    return 'Ви впевнені, що хочете видалити візит до $cityName?';
  }

  @override
  String activeSince(Object date) {
    return 'Активно з $date';
  }
}
