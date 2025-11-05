import 'package:days_tracker/data/services/location_service.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

/// Background task unique name
const String locationCheckTaskName = 'locationCheckTask';

/// Background dispatcher - must be a top-level function
/// This is called by the OS when background task triggers
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) {
    try {
      // TODO: Initialize DI container in background isolate
      // This requires special handling since we're in a separate isolate
      // For now, this is a placeholder - see README for implementation notes

      final logger = Logger();
      logger.i('Background task triggered: $task');

      // In production, you would:
      // 1. Initialize get_it locator
      // 2. Get LocationService
      // 3. Call performLocationCheck with source='background'

      return Future.value(true);
    } catch (e) {
      Logger().e('Background task failed: $e');
      return Future.value(false);
    }
  });
}

@lazySingleton
class BackgroundManager {
  final SettingsRepository _settingsRepository;
  final LocationService _locationService;
  final Logger _logger = Logger();

  BackgroundManager(this._settingsRepository, this._locationService);

  /// Initialize background tracking
  Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        backgroundDispatcher,
      );
      _logger.i('Background manager initialized');

      // Check if background tracking is enabled and start if needed
      final enabled = await _settingsRepository.isBackgroundTrackingEnabled();
      if (enabled) {
        await startBackgroundTracking();
      }
    } catch (e) {
      _logger.e('Failed to initialize background manager: $e');
    }
  }

  /// Start background location tracking
  Future<void> startBackgroundTracking() async {
    try {
      final frequency = await _settingsRepository.getTrackingFrequency();

      // Cancel any existing tasks
      await Workmanager().cancelByUniqueName(locationCheckTaskName);

      // Register periodic task
      // Note: Minimum frequency is 15 minutes on both iOS and Android
      await Workmanager().registerPeriodicTask(
        locationCheckTaskName,
        locationCheckTaskName,
        frequency: Duration(minutes: frequency.clamp(15, 60)),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        initialDelay: const Duration(minutes: 1),
      );

      await _settingsRepository.setBackgroundTrackingEnabled(true);
      _logger
          .i('Background tracking started with frequency: $frequency minutes');
    } catch (e) {
      _logger.e('Failed to start background tracking: $e');
      rethrow;
    }
  }

  /// Stop background location tracking
  Future<void> stopBackgroundTracking() async {
    try {
      await Workmanager().cancelByUniqueName(locationCheckTaskName);
      await _settingsRepository.setBackgroundTrackingEnabled(false);
      _logger.i('Background tracking stopped');
    } catch (e) {
      _logger.e('Failed to stop background tracking: $e');
      rethrow;
    }
  }

  /// Check if background tracking is currently running
  Future<bool> isBackgroundTrackingActive() async {
    return await _settingsRepository.isBackgroundTrackingEnabled();
  }

  /// Perform immediate location check (for testing/manual trigger)
  Future<void> performImmediateCheck() async {
    try {
      await _locationService.performLocationCheck();
      _logger.i('Immediate location check completed');
    } catch (e) {
      _logger.e('Failed to perform immediate check: $e');
      rethrow;
    }
  }
}
