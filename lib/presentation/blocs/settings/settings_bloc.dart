import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/location/track_location_now.dart';
import 'package:days_tracker/domain/usecases/settings/clear_all_data.dart';
import 'package:days_tracker/domain/usecases/settings/clear_google_maps_api_key.dart';
import 'package:days_tracker/domain/usecases/settings/export_data.dart';
import 'package:days_tracker/domain/usecases/settings/get_background_tracking_enabled.dart';
import 'package:days_tracker/domain/usecases/settings/get_day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/settings/get_google_maps_api_key.dart';
import 'package:days_tracker/domain/usecases/settings/import_data.dart';
import 'package:days_tracker/domain/usecases/settings/set_background_tracking_enabled.dart';
import 'package:days_tracker/domain/usecases/settings/set_day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/settings/set_google_maps_api_key.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_event.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// BLoC for managing app settings.
///
/// Handles day counting rule, background tracking toggle,
/// API key management, and data import/export.
@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Logger _logger = Logger();
  final GetDayCountingRule _getDayCountingRule;
  final SetDayCountingRule _setDayCountingRule;
  final GetBackgroundTrackingEnabled _getBackgroundTrackingEnabled;
  final SetBackgroundTrackingEnabled _setBackgroundTrackingEnabled;
  final GetGoogleMapsApiKey _getGoogleMapsApiKey;
  final SetGoogleMapsApiKey _setGoogleMapsApiKey;
  final ClearGoogleMapsApiKey _clearGoogleMapsApiKey;
  final TrackLocationNow _trackLocationNow;
  final ExportData _exportData;
  final ImportData _importData;
  final ClearAllData _clearAllData;

  SettingsBloc(
    this._getDayCountingRule,
    this._setDayCountingRule,
    this._getBackgroundTrackingEnabled,
    this._setBackgroundTrackingEnabled,
    this._getGoogleMapsApiKey,
    this._setGoogleMapsApiKey,
    this._clearGoogleMapsApiKey,
    this._trackLocationNow,
    this._exportData,
    this._importData,
    this._clearAllData,
  ) : super(const SettingsState.initial()) {
    on<SettingsEvent>(_onEvent);
  }

  Future<void> _onEvent(SettingsEvent event, Emitter<SettingsState> emit) async {
    _logger.d('[SettingsBloc] Event: $event');
    await event.when(
      loadSettings: () => _onLoadSettings(emit),
      changeDayCountingRule: (rule) => _onChangeDayCountingRule(rule, emit),
      toggleBackgroundTracking: (enabled) => _onToggleBackgroundTracking(enabled, emit),
      trackLocationNow: () => _onTrackLocationNow(emit),
      setApiKey: (apiKey) => _onSetApiKey(apiKey, emit),
      clearApiKey: () => _onClearApiKey(emit),
      exportData: () => _onExportData(emit),
      importData: (jsonData) => _onImportData(jsonData, emit),
      clearAllData: () => _onClearAllData(emit),
    );
  }

  Future<void> _onLoadSettings(Emitter<SettingsState> emit) async {
    _logger.i('[SettingsBloc] Loading settings');
    emit(const SettingsState.loading());

    final ruleResult = await _getDayCountingRule();
    final trackingResult = await _getBackgroundTrackingEnabled();
    final apiKeyResult = await _getGoogleMapsApiKey();

    final rule = ruleResult.fold((failure) => DayCountingRule.anyPresence, (rule) => rule);

    final tracking = trackingResult.fold((failure) => false, (enabled) => enabled);

    final hasApiKey = apiKeyResult.fold((failure) => false, (key) => key != null && key.isNotEmpty);
    _logger.i(
      '[SettingsBloc] Settings loaded: rule=$rule, tracking=$tracking, hasApiKey=$hasApiKey',
    );

    emit(
      SettingsState.loaded(
        dayCountingRule: rule,
        backgroundTrackingEnabled: tracking,
        hasApiKey: hasApiKey,
      ),
    );
  }

  Future<void> _onChangeDayCountingRule(DayCountingRule rule, Emitter<SettingsState> emit) async {
    _logger.d('[SettingsBloc] Setting day counting rule: $rule');
    final result = await _setDayCountingRule(rule);

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Set day counting rule failed: ${failure.message}');
        emit(SettingsState.error(failure.message));
      },
      (_) {
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(dayCountingRule: rule));
          },
        );
      },
    );
  }

  Future<void> _onToggleBackgroundTracking(bool enabled, Emitter<SettingsState> emit) async {
    _logger.i('[SettingsBloc] Toggling background tracking: $enabled');
    final result = await _setBackgroundTrackingEnabled(enabled);

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Toggle background tracking failed: ${failure.message}');
        emit(SettingsState.error(failure.message));
      },
      (_) {
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(backgroundTrackingEnabled: enabled));
          },
        );
      },
    );
  }

  Future<void> _onTrackLocationNow(Emitter<SettingsState> emit) async {
    _logger.d('[SettingsBloc] Track location now');
    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(isTrackingLocation: true, lastLocationResult: null));
      },
    );

    final result = await _trackLocationNow();

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Track location failed: ${failure.message}');
        state.mapOrNull(
          loaded: (loadedState) {
            emit(
              loadedState.copyWith(
                isTrackingLocation: false,
                lastLocationResult: 'Failed: ${failure.message}',
              ),
            );
          },
        );
      },
      (_) {
        _logger.i('[SettingsBloc] Location tracked successfully');
        state.mapOrNull(
          loaded: (loadedState) {
            emit(
              loadedState.copyWith(
                isTrackingLocation: false,
                lastLocationResult: 'Location tracked successfully!',
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSetApiKey(String apiKey, Emitter<SettingsState> emit) async {
    _logger.d('[SettingsBloc] Setting API key');
    final result = await _setGoogleMapsApiKey(apiKey);

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Set API key failed: ${failure.message}');
        emit(SettingsState.error(failure.message));
      },
      (_) {
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(hasApiKey: true));
          },
        );
      },
    );
  }

  Future<void> _onClearApiKey(Emitter<SettingsState> emit) async {
    _logger.d('[SettingsBloc] Clearing API key');
    final result = await _clearGoogleMapsApiKey();

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Clear API key failed: ${failure.message}');
        emit(SettingsState.error(failure.message));
      },
      (_) {
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(hasApiKey: false));
          },
        );
      },
    );
  }

  Future<void> _onExportData(Emitter<SettingsState> emit) async {
    _logger.i('[SettingsBloc] Exporting data');
    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(isExporting: true, exportedData: null));
      },
    );

    final result = await _exportData();

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Export failed: ${failure.message}');
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(isExporting: false, exportedData: null));
          },
        );
        emit(SettingsState.error(failure.message));
      },
      (jsonData) {
        _logger.i('[SettingsBloc] Export completed successfully');
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(isExporting: false, exportedData: jsonData));
          },
        );
      },
    );
  }

  Future<void> _onImportData(String jsonData, Emitter<SettingsState> emit) async {
    _logger.i('[SettingsBloc] Importing data');
    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(isImporting: true, importMessage: null));
      },
    );

    final result = await _importData(jsonData);

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Import failed: ${failure.message}');
        state.mapOrNull(
          loaded: (loadedState) {
            emit(
              loadedState.copyWith(
                isImporting: false,
                importMessage: 'Import failed: ${failure.message}',
              ),
            );
          },
        );
      },
      (importResult) {
        _logger.i('[SettingsBloc] Import completed: ${importResult.totalRecords} records');
        state.mapOrNull(
          loaded: (loadedState) {
            emit(
              loadedState.copyWith(
                isImporting: false,
                importMessage: 'Successfully imported ${importResult.totalRecords} records',
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onClearAllData(Emitter<SettingsState> emit) async {
    _logger.w('[SettingsBloc] Clearing all data');
    final result = await _clearAllData();

    result.fold(
      (failure) {
        _logger.e('[SettingsBloc] Clear all data failed: ${failure.message}');
        emit(SettingsState.error(failure.message));
      },
      (_) {
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(importMessage: 'All data cleared successfully'));
          },
        );
      },
    );
  }
}
