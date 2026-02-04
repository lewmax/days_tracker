import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.freezed.dart';

/// Events for the SettingsBLoC.
@freezed
class SettingsEvent with _$SettingsEvent {
  /// Load current settings from storage.
  const factory SettingsEvent.loadSettings() = _LoadSettings;

  /// Change the day counting rule.
  const factory SettingsEvent.changeDayCountingRule(DayCountingRule rule) = _ChangeDayCountingRule;

  /// Toggle background tracking on/off.
  const factory SettingsEvent.toggleBackgroundTracking(bool enabled) = _ToggleBackgroundTracking;

  /// Trigger an immediate location track (test location).
  const factory SettingsEvent.trackLocationNow() = _TrackLocationNow;

  /// Set the Google Maps API key.
  const factory SettingsEvent.setApiKey(String apiKey) = _SetApiKey;

  /// Clear the Google Maps API key.
  const factory SettingsEvent.clearApiKey() = _ClearApiKey;

  /// Export all data to JSON.
  const factory SettingsEvent.exportData() = _ExportData;

  /// Import data from JSON.
  const factory SettingsEvent.importData(String jsonData) = _ImportData;

  /// Clear all data (dangerous operation).
  const factory SettingsEvent.clearAllData() = _ClearAllData;
}
