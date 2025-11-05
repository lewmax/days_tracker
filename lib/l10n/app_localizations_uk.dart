// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'DaysTracker';

  @override
  String get visits => 'Візити';

  @override
  String get summary => 'Підсумок';

  @override
  String get map => 'Карта';

  @override
  String get settings => 'Налаштування';

  @override
  String get activeVisit => 'Активний візит';

  @override
  String get pastVisits => 'Минулі візити';

  @override
  String get noVisitsYet => 'Поки немає візитів';

  @override
  String get addVisit => 'Додати візит';

  @override
  String get deleteVisit => 'Видалити візит';

  @override
  String get confirmDelete => 'Ви впевнені, що хочете видалити цей візит?';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get save => 'Зберегти';

  @override
  String get close => 'Закрити';

  @override
  String get country => 'Країна';

  @override
  String get city => 'Місто';

  @override
  String get startDate => 'Дата початку';

  @override
  String get endDate => 'Дата закінчення';

  @override
  String get ongoing => 'Триває';

  @override
  String get notSelected => 'Не вибрано';

  @override
  String get totalDays => 'Всього днів';

  @override
  String get overnightOnly => 'Тільки з ночівлею';

  @override
  String get countOvernightStays => 'Враховувати тільки ночівлі';

  @override
  String get last30Days => 'Останні 30 днів';

  @override
  String get last90Days => 'Останні 90 днів';

  @override
  String get last183Days => 'Останні 183 дні';

  @override
  String get last365Days => 'Останні 365 днів';

  @override
  String get visitedCountries => 'Відвідані країни';

  @override
  String get backgroundTracking => 'Фонове відстеження';

  @override
  String get trackLocationEveryHour => 'Відстежувати місцезнаходження щогодини';

  @override
  String get trackingFrequency => 'Частота відстеження';

  @override
  String get minutes => 'хвилин';

  @override
  String get mapboxConfiguration => 'Налаштування Mapbox';

  @override
  String get apiToken => 'API Токен';

  @override
  String get notConfigured => 'Не налаштовано';

  @override
  String get dataManagement => 'Управління даними';

  @override
  String get exportData => 'Експортувати дані';

  @override
  String get exportAllVisits => 'Експортувати всі візити як JSON';

  @override
  String get importData => 'Імпортувати дані';

  @override
  String get importVisits => 'Імпортувати візити з JSON';

  @override
  String get deleteAllData => 'Видалити всі дані';

  @override
  String get permanentlyDelete => 'Назавжди видалити всі візити';

  @override
  String get privacy => 'Конфіденційність';

  @override
  String get privacyNotice => 'Повідомлення про конфіденційність';

  @override
  String get about => 'Про додаток';

  @override
  String get version => 'Версія';

  @override
  String get refreshLocation => 'Оновити місцезнаходження';

  @override
  String get error => 'Помилка';

  @override
  String get retry => 'Повторити';

  @override
  String get loading => 'Завантаження';

  @override
  String get noDataForPeriod => 'Немає даних за вибраний період';
}
