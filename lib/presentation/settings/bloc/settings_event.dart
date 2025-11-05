part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.loadSettings() = LoadSettings;
  const factory SettingsEvent.toggleBackgroundTracking() =
      ToggleBackgroundTracking;
  const factory SettingsEvent.updateMapboxToken(String token) =
      UpdateMapboxToken;
  const factory SettingsEvent.updateTrackingFrequency(int minutes) =
      UpdateTrackingFrequency;
  const factory SettingsEvent.updateLanguage(String languageCode) =
      UpdateLanguage;
  const factory SettingsEvent.exportData() = ExportData;
  const factory SettingsEvent.importData(String jsonData) = ImportData;
  const factory SettingsEvent.deleteAllData() = DeleteAllData;
}
