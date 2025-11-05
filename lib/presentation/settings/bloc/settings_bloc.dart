import 'package:days_tracker/data/services/background_manager.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  final VisitsRepository _visitsRepository;
  final BackgroundManager _backgroundManager;

  SettingsBloc(
    this._settingsRepository,
    this._visitsRepository,
    this._backgroundManager,
  ) : super(const SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleBackgroundTracking>(_onToggleBackgroundTracking);
    on<UpdateMapboxToken>(_onUpdateMapboxToken);
    on<UpdateTrackingFrequency>(_onUpdateTrackingFrequency);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<ExportData>(_onExportData);
    on<ImportData>(_onImportData);
    on<DeleteAllData>(_onDeleteAllData);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    try {
      final backgroundTracking =
          await _settingsRepository.isBackgroundTrackingEnabled();
      final mapboxToken = await _settingsRepository.getMapboxToken() ?? '';
      final trackingFrequency =
          await _settingsRepository.getTrackingFrequency();
      final languageCode = await _settingsRepository.getLanguageCode();

      emit(SettingsState.loaded(
        backgroundTrackingEnabled: backgroundTracking,
        mapboxToken: mapboxToken,
        trackingFrequency: trackingFrequency,
        languageCode: languageCode,
      ));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> _onToggleBackgroundTracking(
    ToggleBackgroundTracking event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      try {
        if (currentState.backgroundTrackingEnabled) {
          await _backgroundManager.stopBackgroundTracking();
        } else {
          await _backgroundManager.startBackgroundTracking();
        }
        add(const SettingsEvent.loadSettings());
      } catch (e) {
        emit(SettingsState.error(e.toString()));
      }
    }
  }

  Future<void> _onUpdateMapboxToken(
    UpdateMapboxToken event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.setMapboxToken(event.token);
      add(const SettingsEvent.loadSettings());
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> _onUpdateTrackingFrequency(
    UpdateTrackingFrequency event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.setTrackingFrequency(event.minutes);

      // Restart background tracking with new frequency
      final isEnabled = await _settingsRepository.isBackgroundTrackingEnabled();
      if (isEnabled) {
        await _backgroundManager.stopBackgroundTracking();
        await _backgroundManager.startBackgroundTracking();
      }

      add(const SettingsEvent.loadSettings());
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.setLanguageCode(event.languageCode);
      add(const SettingsEvent.loadSettings());
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> _onExportData(
    ExportData event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final jsonData = await _visitsRepository.exportData();
      emit(SettingsState.dataExported(jsonData));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> _onImportData(
    ImportData event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _visitsRepository.importData(event.jsonData);
      add(const SettingsEvent.loadSettings());
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  Future<void> _onDeleteAllData(
    DeleteAllData event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _visitsRepository.deleteAllData();
      add(const SettingsEvent.loadSettings());
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }
}
