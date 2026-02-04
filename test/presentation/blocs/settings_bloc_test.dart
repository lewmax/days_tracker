import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/background_service.dart';
import 'package:days_tracker/data/services/export_service.dart';
import 'package:days_tracker/data/services/import_service.dart';
import 'package:days_tracker/data/services/location_processing_service.dart';
import 'package:days_tracker/data/services/location_service.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
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
import 'package:days_tracker/presentation/blocs/settings/settings_bloc.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_event.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of SettingsRepository for testing.
class MockSettingsRepository implements SettingsRepository {
  DayCountingRule _rule = DayCountingRule.anyPresence;
  bool _trackingEnabled = false;
  String? _apiKey;

  @override
  Future<Either<Failure, DayCountingRule>> getDayCountingRule() async => Right(_rule);

  @override
  Future<Either<Failure, void>> setDayCountingRule(DayCountingRule rule) async {
    _rule = rule;
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> getBackgroundTrackingEnabled() async => Right(_trackingEnabled);

  @override
  Future<Either<Failure, void>> setBackgroundTrackingEnabled(bool enabled) async {
    _trackingEnabled = enabled;
    return const Right(null);
  }

  @override
  Future<Either<Failure, String?>> getGoogleMapsApiKey() async => Right(_apiKey);

  @override
  Future<Either<Failure, void>> setGoogleMapsApiKey(String key) async {
    _apiKey = key;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearGoogleMapsApiKey() async {
    _apiKey = null;
    return const Right(null);
  }
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
  MockBackgroundService() : super(MockLocationService(), MockLocationProcessingService());

  @override
  Future<Either<Failure, void>> startTracking() async => const Right(null);

  @override
  Future<Either<Failure, void>> stopTracking() async => const Right(null);

  @override
  Future<Either<Failure, void>> trackNow() async => const Right(null);
}

/// Mock implementation of TrackLocationNow for testing.
class MockTrackLocationNow implements TrackLocationNow {
  @override
  Future<Either<Failure, void>> call() async => const Right(null);
}

/// Mock implementation of ExportService for testing.
class MockExportService implements ExportService {
  @override
  Future<Either<Failure, String>> exportToJson() async => const Right('{}');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of ImportService for testing.
class MockImportService implements ImportService {
  @override
  Future<Either<Failure, ImportResult>> importFromJson(String jsonString) async => Right(
    ImportResult(
      countriesImported: 0,
      citiesImported: 0,
      visitsImported: 0,
      pingsImported: 0,
      presenceImported: 0,
    ),
  );

  @override
  Either<Failure, ExportDataModel> validateJson(String jsonString) => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of ClearAllData for testing.
class MockClearAllData implements ClearAllData {
  @override
  Future<Either<Failure, void>> call() async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockSettingsRepository mockRepository;
  late MockBackgroundService mockBackgroundService;
  late GetDayCountingRule getDayCountingRule;
  late SetDayCountingRule setDayCountingRule;
  late GetBackgroundTrackingEnabled getBackgroundTrackingEnabled;
  late SetBackgroundTrackingEnabled setBackgroundTrackingEnabled;
  late GetGoogleMapsApiKey getGoogleMapsApiKey;
  late SetGoogleMapsApiKey setGoogleMapsApiKey;
  late ClearGoogleMapsApiKey clearGoogleMapsApiKey;
  late MockTrackLocationNow trackLocationNow;
  late ExportData exportData;
  late ImportData importData;
  late ClearAllData clearAllData;

  setUp(() {
    mockRepository = MockSettingsRepository();
    mockBackgroundService = MockBackgroundService();
    getDayCountingRule = GetDayCountingRule(mockRepository);
    setDayCountingRule = SetDayCountingRule(mockRepository);
    getBackgroundTrackingEnabled = GetBackgroundTrackingEnabled(mockRepository);
    setBackgroundTrackingEnabled = SetBackgroundTrackingEnabled(
      mockRepository,
      mockBackgroundService,
    );
    getGoogleMapsApiKey = GetGoogleMapsApiKey(mockRepository);
    setGoogleMapsApiKey = SetGoogleMapsApiKey(mockRepository);
    clearGoogleMapsApiKey = ClearGoogleMapsApiKey(mockRepository);
    trackLocationNow = MockTrackLocationNow();
    exportData = ExportData(MockExportService());
    importData = ImportData(MockImportService());
    clearAllData = MockClearAllData();
  });

  SettingsBloc createBloc() => SettingsBloc(
    getDayCountingRule,
    setDayCountingRule,
    getBackgroundTrackingEnabled,
    setBackgroundTrackingEnabled,
    getGoogleMapsApiKey,
    setGoogleMapsApiKey,
    clearGoogleMapsApiKey,
    trackLocationNow,
    exportData,
    importData,
    clearAllData,
  );

  group('SettingsBloc', () {
    test('initial state should be SettingsState.initial()', () {
      final bloc = createBloc();
      expect(bloc.state, const SettingsState.initial());
      bloc.close();
    });

    blocTest<SettingsBloc, SettingsState>(
      'emits [loading, loaded] when loadSettings is added',
      build: createBloc,
      act: (bloc) => bloc.add(const SettingsEvent.loadSettings()),
      expect: () => [
        const SettingsState.loading(),
        isA<SettingsState>().having((s) => s.isLoaded, 'isLoaded', true),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits correct state when changeDayCountingRule is added',
      build: createBloc,
      seed: () => const SettingsState.loaded(
        dayCountingRule: DayCountingRule.anyPresence,
        backgroundTrackingEnabled: false,
        hasApiKey: false,
      ),
      act: (bloc) =>
          bloc.add(const SettingsEvent.changeDayCountingRule(DayCountingRule.twoOrMorePings)),
      expect: () => [
        const SettingsState.loaded(
          dayCountingRule: DayCountingRule.twoOrMorePings,
          backgroundTrackingEnabled: false,
          hasApiKey: false,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits correct state when toggleBackgroundTracking is added',
      build: createBloc,
      seed: () => const SettingsState.loaded(
        dayCountingRule: DayCountingRule.anyPresence,
        backgroundTrackingEnabled: false,
        hasApiKey: false,
      ),
      act: (bloc) => bloc.add(const SettingsEvent.toggleBackgroundTracking(true)),
      expect: () => [
        const SettingsState.loaded(
          dayCountingRule: DayCountingRule.anyPresence,
          backgroundTrackingEnabled: true,
          hasApiKey: false,
        ),
      ],
    );
  });
}
