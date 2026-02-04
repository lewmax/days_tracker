import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/services/import_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ImportService importService;

  setUp(() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    importService = ImportService(db);
  });

  group('ImportService', () {
    test('validateJson returns Right for valid minimal JSON', () {
      const jsonStr = '''
      {
        "version": "1.0",
        "exported_at": "2025-01-01T00:00:00.000Z",
        "app_version": "1.0.0",
        "data": {
          "countries": [],
          "cities": [],
          "visits": [],
          "location_pings": [],
          "daily_presence": []
        }
      }
      ''';
      final result = importService.validateJson(jsonStr);
      expect(result.isRight(), true);
      result.fold((f) => fail('expected Right'), (model) {
        expect(model.version, '1.0');
        expect(model.data.countries, isEmpty);
        expect(model.data.visits, isEmpty);
      });
    });

    test('validateJson returns Left when version missing', () {
      const jsonStr = '''
      {
        "exported_at": "2025-01-01T00:00:00.000Z",
        "app_version": "1.0.0",
        "data": {
          "countries": [],
          "cities": [],
          "visits": [],
          "location_pings": [],
          "daily_presence": []
        }
      }
      ''';
      final result = importService.validateJson(jsonStr);
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, contains('version')), (r) => fail('expected Left'));
    });

    test('validateJson returns Left when data missing', () {
      const jsonStr = '''
      {
        "version": "1.0",
        "exported_at": "2025-01-01T00:00:00.000Z",
        "app_version": "1.0.0"
      }
      ''';
      final result = importService.validateJson(jsonStr);
      expect(result.isLeft(), true);
    });

    test('validateJson returns Left for invalid JSON', () {
      const jsonStr = 'not json at all';
      final result = importService.validateJson(jsonStr);
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, contains('JSON')), (r) => fail('expected Left'));
    });
  });
}
