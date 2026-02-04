import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/background_service.dart';
import 'package:days_tracker/data/services/location_processing_service.dart';
import 'package:days_tracker/data/services/location_service.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:days_tracker/domain/usecases/settings/get_background_tracking_enabled.dart';
import 'package:days_tracker/domain/usecases/settings/get_day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/settings/get_google_maps_api_key.dart';
import 'package:days_tracker/domain/usecases/settings/set_background_tracking_enabled.dart';
import 'package:days_tracker/domain/usecases/settings/set_day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/settings/set_google_maps_api_key.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSettingsRepository implements SettingsRepository {
  DayCountingRule? dayCountingRuleToReturn;
  bool? backgroundTrackingToReturn;
  String? apiKeyToReturn;
  Failure? failureToReturn;

  DayCountingRule? lastSetRule;
  bool? lastSetTracking;
  String? lastSetApiKey;

  void setDayCountingRuleResult(DayCountingRule rule) {
    dayCountingRuleToReturn = rule;
    failureToReturn = null;
  }

  void setBackgroundTrackingResult(bool enabled) {
    backgroundTrackingToReturn = enabled;
    failureToReturn = null;
  }

  void setApiKeyResult(String? key) {
    apiKeyToReturn = key;
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
  }

  void setSuccess() {
    failureToReturn = null;
  }

  @override
  Future<Either<Failure, DayCountingRule>> getDayCountingRule() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(dayCountingRuleToReturn ?? DayCountingRule.anyPresence);
  }

  @override
  Future<Either<Failure, void>> setDayCountingRule(DayCountingRule rule) async {
    lastSetRule = rule;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> getBackgroundTrackingEnabled() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(backgroundTrackingToReturn ?? false);
  }

  @override
  Future<Either<Failure, void>> setBackgroundTrackingEnabled(bool enabled) async {
    lastSetTracking = enabled;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, String?>> getGoogleMapsApiKey() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(apiKeyToReturn);
  }

  @override
  Future<Either<Failure, void>> setGoogleMapsApiKey(String apiKey) async {
    lastSetApiKey = apiKey;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of LocationService for testing.
class MockLocationService implements LocationService {
  @override
  Future<Either<Failure, Position>> getCurrentPosition() async {
    return Right(
      Position(latitude: 52.2297, longitude: 21.0122, timestamp: DateTime.now(), accuracy: 10.0),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of LocationProcessingService for testing.
class MockLocationProcessingService implements LocationProcessingService {
  @override
  Future<Either<Failure, void>> processLocationPing({
    required double latitude,
    required double longitude,
    required double? accuracy,
  }) async {
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of BackgroundService for testing.
class MockBackgroundService extends BackgroundService {
  Failure? failureToReturn;
  bool startTrackingCalled = false;
  bool stopTrackingCalled = false;

  MockBackgroundService() : super(MockLocationService(), MockLocationProcessingService());

  void setSuccess() {
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
  }

  @override
  Future<Either<Failure, void>> startTracking() async {
    startTrackingCalled = true;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> stopTracking() async {
    stopTrackingCalled = true;
    if (failureToReturn != null) return Left(failureToReturn!);
    return const Right(null);
  }
}

void main() {
  group('GetDayCountingRule', () {
    late GetDayCountingRule useCase;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = GetDayCountingRule(mockRepository);
    });

    test('should return anyPresence rule when set', () async {
      mockRepository.setDayCountingRuleResult(DayCountingRule.anyPresence);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (rule) => expect(rule, DayCountingRule.anyPresence),
      );
    });

    test('should return twoOrMorePings rule when set', () async {
      mockRepository.setDayCountingRuleResult(DayCountingRule.twoOrMorePings);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (rule) => expect(rule, DayCountingRule.twoOrMorePings),
      );
    });

    test('should return failure when repository fails', () async {
      mockRepository.setFailure(const StorageFailure(message: 'Storage error'));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (rule) => fail('Should not return rule'),
      );
    });
  });

  group('SetDayCountingRule', () {
    late SetDayCountingRule useCase;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = SetDayCountingRule(mockRepository);
    });

    test('should set day counting rule successfully', () async {
      mockRepository.setSuccess();

      final result = await useCase(DayCountingRule.twoOrMorePings);

      expect(result.isRight(), isTrue);
      expect(mockRepository.lastSetRule, DayCountingRule.twoOrMorePings);
    });

    test('should return failure when repository fails', () async {
      mockRepository.setFailure(const StorageFailure(message: 'Storage error'));

      final result = await useCase(DayCountingRule.anyPresence);

      expect(result.isLeft(), isTrue);
    });
  });

  group('GetBackgroundTrackingEnabled', () {
    late GetBackgroundTrackingEnabled useCase;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = GetBackgroundTrackingEnabled(mockRepository);
    });

    test('should return true when tracking is enabled', () async {
      mockRepository.setBackgroundTrackingResult(true);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (enabled) => expect(enabled, isTrue),
      );
    });

    test('should return false when tracking is disabled', () async {
      mockRepository.setBackgroundTrackingResult(false);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (enabled) => expect(enabled, isFalse),
      );
    });
  });

  group('SetBackgroundTrackingEnabled', () {
    late SetBackgroundTrackingEnabled useCase;
    late MockSettingsRepository mockRepository;
    late MockBackgroundService mockBackgroundService;

    setUp(() {
      mockRepository = MockSettingsRepository();
      mockBackgroundService = MockBackgroundService();
      useCase = SetBackgroundTrackingEnabled(mockRepository, mockBackgroundService);
    });

    test('should enable background tracking', () async {
      mockRepository.setSuccess();
      mockBackgroundService.setSuccess();

      final result = await useCase(true);

      expect(result.isRight(), isTrue);
      expect(mockRepository.lastSetTracking, isTrue);
      expect(mockBackgroundService.startTrackingCalled, isTrue);
    });

    test('should disable background tracking', () async {
      mockRepository.setSuccess();
      mockBackgroundService.setSuccess();

      final result = await useCase(false);

      expect(result.isRight(), isTrue);
      expect(mockRepository.lastSetTracking, isFalse);
      expect(mockBackgroundService.stopTrackingCalled, isTrue);
    });
  });

  group('GetGoogleMapsApiKey', () {
    late GetGoogleMapsApiKey useCase;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = GetGoogleMapsApiKey(mockRepository);
    });

    test('should return API key when set', () async {
      mockRepository.setApiKeyResult('test-api-key-123');

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (key) => expect(key, 'test-api-key-123'),
      );
    });

    test('should return null when no API key set', () async {
      mockRepository.setApiKeyResult(null);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not return failure'), (key) => expect(key, isNull));
    });
  });

  group('SetGoogleMapsApiKey', () {
    late SetGoogleMapsApiKey useCase;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = SetGoogleMapsApiKey(mockRepository);
    });

    test('should set API key successfully', () async {
      mockRepository.setSuccess();

      final result = await useCase('new-api-key');

      expect(result.isRight(), isTrue);
      expect(mockRepository.lastSetApiKey, 'new-api-key');
    });

    test('should return failure when repository fails', () async {
      mockRepository.setFailure(const StorageFailure(message: 'Secure storage error'));

      final result = await useCase('api-key');

      expect(result.isLeft(), isTrue);
    });
  });
}
