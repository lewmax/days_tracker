// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DaysTracker';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get myVisits => 'My Visits';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get addVisit => 'Add Visit';

  @override
  String get editVisit => 'Edit Visit';

  @override
  String get visitDetails => 'Visit Details';

  @override
  String get saveVisit => 'Save Visit';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get countryLabel => 'Country *';

  @override
  String get cityLabel => 'City *';

  @override
  String get dateRangeLabel => 'Date Range *';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get visitAddedSuccess => 'Visit added successfully';

  @override
  String get visitUpdatedSuccess => 'Visit updated successfully';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingVisit => 'Loading visit...';

  @override
  String get loadingVisits => 'Loading visits...';

  @override
  String get loadingSettings => 'Loading settings...';

  @override
  String get loadingStatistics => 'Loading statistics...';

  @override
  String get initializing => 'Initializing...';

  @override
  String get noVisitsYet => 'No visits yet';

  @override
  String get noVisitsSubtitle =>
      'Track your travels automatically or add manually.';

  @override
  String get locationTracking => 'Location Tracking';

  @override
  String get backgroundTracking => 'Background Tracking';

  @override
  String get backgroundTrackingSubtitle =>
      'Track location hourly in background';

  @override
  String get testLocationNow => 'Test Location Now';

  @override
  String get testLocationSubtitle => 'Get current position and save ping';

  @override
  String get preferences => 'Preferences';

  @override
  String get dayCountingRule => 'Day Counting Rule';

  @override
  String get anyPresence => 'Any Presence';

  @override
  String get twoOrMorePings => '2+ Pings';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataSubtitle => 'Save all data to JSON file';

  @override
  String get exportShareSubject => 'DaysTracker Data Export';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataSubtitle => 'Load data from JSON file';

  @override
  String get importConfirmMessage =>
      'This will replace all existing data with the imported data. This cannot be undone. Continue?';

  @override
  String get confirmImport => 'Import';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataSubtitle => 'Delete all visits and statistics';

  @override
  String get clearAllDataConfirmMessage =>
      'This will delete all visits, pings, and statistics. This cannot be undone.';

  @override
  String get deleteEverything => 'Delete Everything';

  @override
  String get apiConfiguration => 'API Configuration';

  @override
  String get googleMapsApiKey => 'Google Maps API Key';

  @override
  String get apiKeyConfigured => 'Configured';

  @override
  String get apiKeyNotConfigured => 'Not configured';

  @override
  String get apiKeyDialogDescription =>
      'Enter your Google Maps API key for geocoding functionality.';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get apiKeyHint => 'AIza...';

  @override
  String get apiKeySaved => 'API key saved';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySubtitle => 'All data stored locally. No cloud sync.';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get githubLinkNotConfigured => 'GitHub link not configured';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get remove => 'Remove';

  @override
  String get retry => 'Retry';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get visitNotFound => 'Visit not found';

  @override
  String get timePeriod => 'Time Period';

  @override
  String get timePeriodLabel => 'Time Period';

  @override
  String get viewMode => 'View mode';

  @override
  String get chronologicalView => 'Chronological View';

  @override
  String get noVisitsForDay => 'No visits recorded for this day.';

  @override
  String get noCountryData => 'No country data';

  @override
  String get noCountryDataSubtitle =>
      'Start tracking your visits to see statistics.';

  @override
  String get noCountryDataAvailable => 'No country data available.';

  @override
  String countriesCount(Object count) {
    return 'in $count countries';
  }

  @override
  String get countries => 'Countries';

  @override
  String get pleaseSelectCountry => 'Please select a country';

  @override
  String get pleaseSelectCity => 'Please select a city';

  @override
  String get pleaseSelectStartDate => 'Please select a start date';

  @override
  String get pleaseFillAllFields => 'Please fill all required fields';

  @override
  String failedToShareExport(Object error) {
    return 'Failed to share export: $error';
  }

  @override
  String get fileEmptyOrUnreadable => 'File is empty or could not be read';

  @override
  String failedToReadFile(Object error) {
    return 'Failed to read file: $error';
  }

  @override
  String get navVisits => 'Visits';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navSettings => 'Settings';

  @override
  String get addVisitSemanticLabel => 'Add visit';

  @override
  String get unknownCity => 'Unknown City';

  @override
  String get unknownCountry => 'Unknown Country';

  @override
  String get activeVisit => 'Active Visit';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get duration => 'Duration';

  @override
  String get source => 'Source';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get sourceAuto => 'Automatic (GPS)';

  @override
  String get sourceManual => 'Manual Entry';

  @override
  String daysCount(Object count) {
    return '$count days';
  }

  @override
  String totalDaysTracked(Object count) {
    return 'Total days tracked: $count';
  }

  @override
  String get daysTracked => 'days tracked';

  @override
  String get deleteVisit => 'Delete Visit';

  @override
  String deleteVisitConfirm(Object cityName) {
    return 'Are you sure you want to delete this visit to $cityName?';
  }

  @override
  String activeSince(Object date) {
    return 'Active since $date';
  }
}
