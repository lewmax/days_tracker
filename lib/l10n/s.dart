import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_en.dart';
import 's_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'DaysTracker'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settingsTitle;

  /// No description provided for @myVisits.
  ///
  /// In uk, this message translates to:
  /// **'Мої візити'**
  String get myVisits;

  /// No description provided for @statisticsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Статистика'**
  String get statisticsTitle;

  /// No description provided for @addVisit.
  ///
  /// In uk, this message translates to:
  /// **'Додати візит'**
  String get addVisit;

  /// No description provided for @editVisit.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати візит'**
  String get editVisit;

  /// No description provided for @visitDetails.
  ///
  /// In uk, this message translates to:
  /// **'Деталі візиту'**
  String get visitDetails;

  /// No description provided for @saveVisit.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти візит'**
  String get saveVisit;

  /// No description provided for @saveChanges.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни'**
  String get saveChanges;

  /// No description provided for @countryLabel.
  ///
  /// In uk, this message translates to:
  /// **'Країна *'**
  String get countryLabel;

  /// No description provided for @cityLabel.
  ///
  /// In uk, this message translates to:
  /// **'Місто *'**
  String get cityLabel;

  /// No description provided for @dateRangeLabel.
  ///
  /// In uk, this message translates to:
  /// **'Діапазон дат *'**
  String get dateRangeLabel;

  /// No description provided for @useCurrentLocation.
  ///
  /// In uk, this message translates to:
  /// **'Використати поточне місце'**
  String get useCurrentLocation;

  /// No description provided for @visitAddedSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Візит успішно додано'**
  String get visitAddedSuccess;

  /// No description provided for @visitUpdatedSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Візит успішно оновлено'**
  String get visitUpdatedSuccess;

  /// No description provided for @loading.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження...'**
  String get loading;

  /// No description provided for @loadingVisit.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження візиту...'**
  String get loadingVisit;

  /// No description provided for @loadingVisits.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження візитів...'**
  String get loadingVisits;

  /// No description provided for @loadingSettings.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження налаштувань...'**
  String get loadingSettings;

  /// No description provided for @loadingStatistics.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження статистики...'**
  String get loadingStatistics;

  /// No description provided for @initializing.
  ///
  /// In uk, this message translates to:
  /// **'Ініціалізація...'**
  String get initializing;

  /// No description provided for @noVisitsYet.
  ///
  /// In uk, this message translates to:
  /// **'Візитів ще немає'**
  String get noVisitsYet;

  /// No description provided for @noVisitsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Відстежуйте подорожі автоматично або додавайте вручну.'**
  String get noVisitsSubtitle;

  /// No description provided for @locationTracking.
  ///
  /// In uk, this message translates to:
  /// **'Відстеження локації'**
  String get locationTracking;

  /// No description provided for @backgroundTracking.
  ///
  /// In uk, this message translates to:
  /// **'Фоновий трекінг'**
  String get backgroundTracking;

  /// No description provided for @backgroundTrackingSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Відстежувати локацію щогодини у фоні'**
  String get backgroundTrackingSubtitle;

  /// No description provided for @testLocationNow.
  ///
  /// In uk, this message translates to:
  /// **'Перевірити локацію зараз'**
  String get testLocationNow;

  /// No description provided for @testLocationSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Отримати поточну позицію та зберегти пінг'**
  String get testLocationSubtitle;

  /// No description provided for @preferences.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get preferences;

  /// No description provided for @dayCountingRule.
  ///
  /// In uk, this message translates to:
  /// **'Правило підрахунку днів'**
  String get dayCountingRule;

  /// No description provided for @anyPresence.
  ///
  /// In uk, this message translates to:
  /// **'Будь-яка присутність'**
  String get anyPresence;

  /// No description provided for @twoOrMorePings.
  ///
  /// In uk, this message translates to:
  /// **'2+ пінги'**
  String get twoOrMorePings;

  /// No description provided for @dataManagement.
  ///
  /// In uk, this message translates to:
  /// **'Управління даними'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In uk, this message translates to:
  /// **'Експорт даних'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти всі дані у JSON файл'**
  String get exportDataSubtitle;

  /// No description provided for @exportShareSubject.
  ///
  /// In uk, this message translates to:
  /// **'Експорт даних DaysTracker'**
  String get exportShareSubject;

  /// No description provided for @importData.
  ///
  /// In uk, this message translates to:
  /// **'Імпорт даних'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Завантажити дані з JSON файлу'**
  String get importDataSubtitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In uk, this message translates to:
  /// **'Це замінить усі існуючі дані імпортованими. Це не можна скасувати. Продовжити?'**
  String get importConfirmMessage;

  /// No description provided for @confirmImport.
  ///
  /// In uk, this message translates to:
  /// **'Імпорт'**
  String get confirmImport;

  /// No description provided for @clearAllData.
  ///
  /// In uk, this message translates to:
  /// **'Очистити всі дані'**
  String get clearAllData;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити всі візити та статистику'**
  String get clearAllDataSubtitle;

  /// No description provided for @clearAllDataConfirmMessage.
  ///
  /// In uk, this message translates to:
  /// **'Будуть видалені всі візити, пінги та статистика. Це не можна скасувати.'**
  String get clearAllDataConfirmMessage;

  /// No description provided for @deleteEverything.
  ///
  /// In uk, this message translates to:
  /// **'Видалити все'**
  String get deleteEverything;

  /// No description provided for @apiConfiguration.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування API'**
  String get apiConfiguration;

  /// No description provided for @googleMapsApiKey.
  ///
  /// In uk, this message translates to:
  /// **'Ключ Google Maps API'**
  String get googleMapsApiKey;

  /// No description provided for @apiKeyConfigured.
  ///
  /// In uk, this message translates to:
  /// **'Налаштовано'**
  String get apiKeyConfigured;

  /// No description provided for @apiKeyNotConfigured.
  ///
  /// In uk, this message translates to:
  /// **'Не налаштовано'**
  String get apiKeyNotConfigured;

  /// No description provided for @apiKeyDialogDescription.
  ///
  /// In uk, this message translates to:
  /// **'Введіть ключ Google Maps API для геокодування.'**
  String get apiKeyDialogDescription;

  /// No description provided for @apiKeyLabel.
  ///
  /// In uk, this message translates to:
  /// **'Ключ API'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In uk, this message translates to:
  /// **'AIza...'**
  String get apiKeyHint;

  /// No description provided for @apiKeySaved.
  ///
  /// In uk, this message translates to:
  /// **'Ключ API збережено'**
  String get apiKeySaved;

  /// No description provided for @about.
  ///
  /// In uk, this message translates to:
  /// **'Про додаток'**
  String get about;

  /// No description provided for @version.
  ///
  /// In uk, this message translates to:
  /// **'Версія'**
  String get version;

  /// No description provided for @versionNumber.
  ///
  /// In uk, this message translates to:
  /// **'1.0.0'**
  String get versionNumber;

  /// No description provided for @privacy.
  ///
  /// In uk, this message translates to:
  /// **'Конфіденційність'**
  String get privacy;

  /// No description provided for @privacySubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Усі дані зберігаються локально. Без хмарної синхронізації.'**
  String get privacySubtitle;

  /// No description provided for @sourceCode.
  ///
  /// In uk, this message translates to:
  /// **'Вихідний код'**
  String get sourceCode;

  /// No description provided for @viewOnGitHub.
  ///
  /// In uk, this message translates to:
  /// **'Переглянути на GitHub'**
  String get viewOnGitHub;

  /// No description provided for @githubLinkNotConfigured.
  ///
  /// In uk, this message translates to:
  /// **'Посилання на GitHub не налаштовано'**
  String get githubLinkNotConfigured;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @remove.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get remove;

  /// No description provided for @retry.
  ///
  /// In uk, this message translates to:
  /// **'Повторити'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердити'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get delete;

  /// No description provided for @visitNotFound.
  ///
  /// In uk, this message translates to:
  /// **'Візит не знайдено'**
  String get visitNotFound;

  /// No description provided for @timePeriod.
  ///
  /// In uk, this message translates to:
  /// **'Період часу'**
  String get timePeriod;

  /// No description provided for @timePeriodLabel.
  ///
  /// In uk, this message translates to:
  /// **'Період часу'**
  String get timePeriodLabel;

  /// No description provided for @viewMode.
  ///
  /// In uk, this message translates to:
  /// **'Режим перегляду'**
  String get viewMode;

  /// No description provided for @chronologicalView.
  ///
  /// In uk, this message translates to:
  /// **'Хронологічний вигляд'**
  String get chronologicalView;

  /// No description provided for @noVisitsForDay.
  ///
  /// In uk, this message translates to:
  /// **'Немає візитів за цей день.'**
  String get noVisitsForDay;

  /// No description provided for @noCountryData.
  ///
  /// In uk, this message translates to:
  /// **'Немає даних по країнах'**
  String get noCountryData;

  /// No description provided for @noCountryDataSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Почніть відстежувати візити, щоб бачити статистику.'**
  String get noCountryDataSubtitle;

  /// No description provided for @noCountryDataAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Немає доступних даних по країнах.'**
  String get noCountryDataAvailable;

  /// No description provided for @countriesCount.
  ///
  /// In uk, this message translates to:
  /// **'у {count} країнах'**
  String countriesCount(Object count);

  /// No description provided for @countries.
  ///
  /// In uk, this message translates to:
  /// **'Країни'**
  String get countries;

  /// No description provided for @pleaseSelectCountry.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть країну'**
  String get pleaseSelectCountry;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть місто'**
  String get pleaseSelectCity;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть дату початку'**
  String get pleaseSelectStartDate;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In uk, this message translates to:
  /// **'Заповніть усі обов\'язкові поля'**
  String get pleaseFillAllFields;

  /// No description provided for @failedToShareExport.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося поділитися експортом: {error}'**
  String failedToShareExport(Object error);

  /// No description provided for @fileEmptyOrUnreadable.
  ///
  /// In uk, this message translates to:
  /// **'Файл порожній або не читається'**
  String get fileEmptyOrUnreadable;

  /// No description provided for @failedToReadFile.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося прочитати файл: {error}'**
  String failedToReadFile(Object error);

  /// No description provided for @navVisits.
  ///
  /// In uk, this message translates to:
  /// **'Візити'**
  String get navVisits;

  /// No description provided for @navStatistics.
  ///
  /// In uk, this message translates to:
  /// **'Статистика'**
  String get navStatistics;

  /// No description provided for @navSettings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get navSettings;

  /// No description provided for @addVisitSemanticLabel.
  ///
  /// In uk, this message translates to:
  /// **'Додати візит'**
  String get addVisitSemanticLabel;

  /// No description provided for @unknownCity.
  ///
  /// In uk, this message translates to:
  /// **'Невідоме місто'**
  String get unknownCity;

  /// No description provided for @unknownCountry.
  ///
  /// In uk, this message translates to:
  /// **'Невідома країна'**
  String get unknownCountry;

  /// No description provided for @activeVisit.
  ///
  /// In uk, this message translates to:
  /// **'Активний візит'**
  String get activeVisit;

  /// No description provided for @startDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата початку'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата завершення'**
  String get endDate;

  /// No description provided for @duration.
  ///
  /// In uk, this message translates to:
  /// **'Тривалість'**
  String get duration;

  /// No description provided for @source.
  ///
  /// In uk, this message translates to:
  /// **'Джерело'**
  String get source;

  /// No description provided for @lastUpdated.
  ///
  /// In uk, this message translates to:
  /// **'Останнє оновлення'**
  String get lastUpdated;

  /// No description provided for @sourceAuto.
  ///
  /// In uk, this message translates to:
  /// **'Автоматично (GPS)'**
  String get sourceAuto;

  /// No description provided for @sourceManual.
  ///
  /// In uk, this message translates to:
  /// **'Введено вручну'**
  String get sourceManual;

  /// No description provided for @daysCount.
  ///
  /// In uk, this message translates to:
  /// **'{count} дн.'**
  String daysCount(Object count);

  /// No description provided for @totalDaysTracked.
  ///
  /// In uk, this message translates to:
  /// **'Всього днів: {count}'**
  String totalDaysTracked(Object count);

  /// No description provided for @daysTracked.
  ///
  /// In uk, this message translates to:
  /// **'днів відстежено'**
  String get daysTracked;

  /// No description provided for @deleteVisit.
  ///
  /// In uk, this message translates to:
  /// **'Видалити візит'**
  String get deleteVisit;

  /// No description provided for @deleteVisitConfirm.
  ///
  /// In uk, this message translates to:
  /// **'Ви впевнені, що хочете видалити візит до {cityName}?'**
  String deleteVisitConfirm(Object cityName);

  /// No description provided for @activeSince.
  ///
  /// In uk, this message translates to:
  /// **'Активно з {date}'**
  String activeSince(Object date);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'uk':
      return SUk();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
