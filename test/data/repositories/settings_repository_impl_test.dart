import 'package:days_tracker/data/repositories/settings_repository_impl.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory fake for FlutterSecureStorage (avoids platform channels in tests).
class FakeFlutterSecureStorage extends FlutterSecureStorage {
  FakeFlutterSecureStorage() : super();

  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _storage[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) _storage[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  late SettingsRepositoryImpl repo;
  late SharedPreferences prefs;
  late FakeFlutterSecureStorage secureStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    secureStorage = FakeFlutterSecureStorage();
    repo = SettingsRepositoryImpl(prefs, secureStorage);
  });

  group('SettingsRepositoryImpl', () {
    group('day counting rule', () {
      test('getDayCountingRule returns anyPresence when not set', () async {
        final result = await repo.getDayCountingRule();
        expect(result.isRight(), true);
        result.fold((l) => fail('expected Right'), (r) {
          expect(r, DayCountingRule.anyPresence);
        });
      });

      test('setDayCountingRule then getDayCountingRule returns set value', () async {
        final result = await repo.setDayCountingRule(DayCountingRule.twoOrMorePings);
        expect(result.isRight(), true);

        final getResult = await repo.getDayCountingRule();
        getResult.fold((l) => fail('expected Right'), (r) {
          expect(r, DayCountingRule.twoOrMorePings);
        });
      });
    });

    group('background tracking', () {
      test('getBackgroundTrackingEnabled returns false when not set', () async {
        final result = await repo.getBackgroundTrackingEnabled();
        expect(result.isRight(), true);
        result.fold((l) => fail('expected Right'), (r) => expect(r, false));
      });

      test('setBackgroundTrackingEnabled then get returns value', () async {
        await repo.setBackgroundTrackingEnabled(true);
        final result = await repo.getBackgroundTrackingEnabled();
        result.fold((l) => fail('expected Right'), (r) => expect(r, true));
      });
    });

    group('Google Maps API key', () {
      test('getGoogleMapsApiKey returns null when not set', () async {
        final result = await repo.getGoogleMapsApiKey();
        expect(result.isRight(), true);
        result.fold((l) => fail('expected Right'), (r) => expect(r, null));
      });

      test('setGoogleMapsApiKey then get returns key', () async {
        await repo.setGoogleMapsApiKey('test-key-123');
        final result = await repo.getGoogleMapsApiKey();
        result.fold((l) => fail('expected Right'), (r) => expect(r, 'test-key-123'));
      });

      test('clearGoogleMapsApiKey removes key', () async {
        await repo.setGoogleMapsApiKey('key');
        await repo.clearGoogleMapsApiKey();
        final result = await repo.getGoogleMapsApiKey();
        result.fold((l) => fail('expected Right'), (r) => expect(r, null));
      });
    });
  });
}
