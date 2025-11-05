part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loading() = _Loading;
  const factory SettingsState.loaded({
    required bool backgroundTrackingEnabled,
    required String mapboxToken,
    required int trackingFrequency,
    required String languageCode,
  }) = _Loaded;
  const factory SettingsState.dataExported(String jsonData) = _DataExported;
  const factory SettingsState.error(String message) = _Error;
}
