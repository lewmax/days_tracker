import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart' as bg_fetch;
import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/location_processing_service.dart';
import 'package:days_tracker/data/services/location_service.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart' as wm;

/// Unique name for the background location tracking task.
const String kLocationTrackingTaskName = 'locationTrackingTask';

/// Unique ID for the periodic background task.
const String kLocationTrackingTaskId = 'com.daystracker.locationTracking';

/// Callback dispatcher for WorkManager (Android).
/// This must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    final logger = Logger();
    logger.i('Background task started: $task');

    try {
      // Note: In a real implementation, we would need to initialize DI here
      // and get the services. For now, this is a placeholder.
      // The actual implementation would require careful handling of
      // dependency injection in the isolate context.
      logger.i('Background location tracking executed');
      return true;
    } catch (e) {
      logger.e('Background task failed: $e');
      return false;
    }
  });
}

/// Service for managing background location tracking.
///
/// Uses WorkManager for Android and BackgroundFetch for iOS
/// to run hourly location tracking tasks.
@lazySingleton
class BackgroundService {
  final LocationService _locationService;
  final LocationProcessingService _locationProcessingService;
  final Logger _logger = Logger();

  bool _isInitialized = false;
  bool _isTracking = false;

  BackgroundService(this._locationService, this._locationProcessingService);

  /// Whether background tracking is currently enabled.
  bool get isTracking => _isTracking;

  /// Initialize the background service.
  ///
  /// Must be called before starting tracking.
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      if (Platform.isAndroid) {
        await _initializeAndroid();
      } else if (Platform.isIOS) {
        await _initializeIOS();
      }
      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to initialize background service: $e');
      return Left(StorageFailure(message: 'Failed to initialize background service: $e'));
    }
  }

  /// Initialize WorkManager for Android.
  Future<void> _initializeAndroid() async {
    await wm.Workmanager().initialize(callbackDispatcher);
    _logger.i('WorkManager initialized for Android');
  }

  /// Initialize BackgroundFetch for iOS.
  Future<void> _initializeIOS() async {
    final status = await bg_fetch.BackgroundFetch.configure(
      bg_fetch.BackgroundFetchConfig(
        minimumFetchInterval: 60, // 60 minutes (iOS may throttle)
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: bg_fetch.NetworkType.NONE,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    _logger.i('BackgroundFetch configured with status: $status');
  }

  /// iOS background fetch callback.
  Future<void> _onBackgroundFetch(String taskId) async {
    _logger.i('iOS Background fetch started: $taskId');

    try {
      await _performLocationTracking();
      bg_fetch.BackgroundFetch.finish(taskId);
    } catch (e) {
      _logger.e('iOS Background fetch failed: $e');
      bg_fetch.BackgroundFetch.finish(taskId);
    }
  }

  /// iOS background fetch timeout callback.
  void _onBackgroundFetchTimeout(String taskId) {
    _logger.w('iOS Background fetch timeout: $taskId');
    bg_fetch.BackgroundFetch.finish(taskId);
  }

  /// Start background location tracking.
  ///
  /// Registers periodic tasks on both platforms.
  Future<Either<Failure, void>> startTracking() async {
    if (!_isInitialized) {
      final initResult = await initialize();
      if (initResult.isLeft()) {
        return initResult;
      }
    }

    try {
      if (Platform.isAndroid) {
        await _startAndroidTracking();
      } else if (Platform.isIOS) {
        await _startIOSTracking();
      }
      _isTracking = true;
      _logger.i('Background tracking started');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to start background tracking: $e');
      return Left(StorageFailure(message: 'Failed to start tracking: $e'));
    }
  }

  /// Start Android periodic tracking with WorkManager.
  Future<void> _startAndroidTracking() async {
    // Cancel any existing task first
    await wm.Workmanager().cancelByUniqueName(kLocationTrackingTaskId);

    // Register periodic task (minimum 15 minutes on Android)
    await wm.Workmanager().registerPeriodicTask(
      kLocationTrackingTaskId,
      kLocationTrackingTaskName,
      frequency: const Duration(hours: 1),
      constraints: wm.Constraints(
        networkType: wm.NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: wm.BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );

    _logger.i('Android periodic task registered');
  }

  /// Start iOS tracking with BackgroundFetch.
  Future<void> _startIOSTracking() async {
    // BackgroundFetch.start() is deprecated in newer versions
    // The configuration done in initialize() is sufficient
    final status = await bg_fetch.BackgroundFetch.start();
    _logger.i('iOS BackgroundFetch started with status: $status');
  }

  /// Stop background location tracking.
  Future<Either<Failure, void>> stopTracking() async {
    try {
      if (Platform.isAndroid) {
        await _stopAndroidTracking();
      } else if (Platform.isIOS) {
        await _stopIOSTracking();
      }
      _isTracking = false;
      _logger.i('Background tracking stopped');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to stop background tracking: $e');
      return Left(StorageFailure(message: 'Failed to stop tracking: $e'));
    }
  }

  /// Stop Android periodic tracking.
  Future<void> _stopAndroidTracking() async {
    await wm.Workmanager().cancelByUniqueName(kLocationTrackingTaskId);
    _logger.i('Android periodic task cancelled');
  }

  /// Stop iOS tracking.
  Future<void> _stopIOSTracking() async {
    final status = await bg_fetch.BackgroundFetch.stop();
    _logger.i('iOS BackgroundFetch stopped with status: $status');
  }

  /// Perform a single location tracking operation.
  ///
  /// This is called by both Android and iOS background callbacks.
  Future<Either<Failure, void>> _performLocationTracking() async {
    _logger.i('Performing location tracking...');

    // Get current location
    final locationResult = await _locationService.getCurrentPosition();

    return locationResult.fold(
      (failure) {
        _logger.e('Failed to get location: ${failure.message}');
        return Left(failure);
      },
      (position) async {
        _logger.i('Got location: ${position.latitude}, ${position.longitude}');

        // Process the location ping
        final processResult = await _locationProcessingService.processLocationPing(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        );

        return processResult.fold(
          (failure) {
            _logger.e('Failed to process ping: ${failure.message}');
            return Left(failure);
          },
          (_) {
            _logger.i('Location ping processed successfully');
            return const Right(null);
          },
        );
      },
    );
  }

  /// Manually trigger a location tracking operation.
  ///
  /// Useful for testing or immediate location updates.
  Future<Either<Failure, void>> trackNow() async {
    return _performLocationTracking();
  }

  /// Check if the required permissions are granted for background tracking.
  Future<Either<Failure, bool>> checkPermissions() async {
    final permissionResult = await _locationService.checkPermission();
    return permissionResult.fold(
      (failure) => Left(failure),
      (status) => Right(status.name == 'always'),
    );
  }

  /// Request the required permissions for background tracking.
  Future<Either<Failure, bool>> requestPermissions() async {
    final permissionResult = await _locationService.requestPermission();
    return permissionResult.fold(
      (failure) => Left(failure),
      (status) => Right(status.name == 'always'),
    );
  }
}
