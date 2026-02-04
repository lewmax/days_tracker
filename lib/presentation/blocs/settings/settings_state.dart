import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// State for the SettingsBLoC.
@freezed
class SettingsState with _$SettingsState {
  const SettingsState._();

  /// Initial state before settings are loaded.
  const factory SettingsState.initial() = _Initial;

  /// Loading state while fetching settings.
  const factory SettingsState.loading() = _Loading;

  /// Loaded state with settings data.
  const factory SettingsState.loaded({
    required DayCountingRule dayCountingRule,
    required bool backgroundTrackingEnabled,
    required bool hasApiKey,
    @Default(false) bool isTrackingLocation,
    @Default(false) bool isExporting,
    @Default(false) bool isImporting,
    String? lastLocationResult,
    String? exportedData,
    String? importMessage,
  }) = _Loaded;

  /// Error state when something goes wrong.
  const factory SettingsState.error(String message) = _Error;

  /// Helper to check if we're in loaded state.
  bool get isLoaded => this is _Loaded;

  /// Get current day counting rule.
  DayCountingRule get dayCountingRuleOrDefault =>
      maybeMap(loaded: (state) => state.dayCountingRule, orElse: () => DayCountingRule.anyPresence);

  /// Get background tracking status.
  bool get isBackgroundTrackingEnabled =>
      maybeMap(loaded: (state) => state.backgroundTrackingEnabled, orElse: () => false);

  /// Check if API key is configured.
  bool get hasApiKeyConfigured => maybeMap(loaded: (state) => state.hasApiKey, orElse: () => false);

  /// Check if currently tracking location.
  bool get isCurrentlyTracking =>
      maybeMap(loaded: (state) => state.isTrackingLocation, orElse: () => false);
}
