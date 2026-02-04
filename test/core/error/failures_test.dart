import 'package:days_tracker/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('concrete Failure has message and props', () {
      const f = ValidationFailure(message: 'test');
      expect(f.message, 'test');
      expect(f.props, ['test']);
      expect(f, isA<Failure>());
    });
  });

  group('DatabaseFailure', () {
    test('creates with message', () {
      const f = DatabaseFailure(message: 'DB error');
      expect(f.message, 'DB error');
      expect(f, equals(const DatabaseFailure(message: 'DB error')));
    });
  });

  group('NetworkFailure', () {
    test('creates with message', () {
      const f = NetworkFailure(message: 'No connection');
      expect(f.message, 'No connection');
    });
  });

  group('GeocodingFailure', () {
    test('creates with message', () {
      const f = GeocodingFailure(message: 'City not found');
      expect(f.message, 'City not found');
    });
  });

  group('ValidationFailure', () {
    test('creates with message', () {
      const f = ValidationFailure(message: 'Overlap');
      expect(f.message, 'Overlap');
    });
  });

  group('PermissionFailure', () {
    test('creates with message', () {
      const f = PermissionFailure(message: 'Denied');
      expect(f.message, 'Denied');
    });
  });

  group('LocationFailure', () {
    test('creates with message', () {
      const f = LocationFailure(message: 'GPS off');
      expect(f.message, 'GPS off');
    });
  });

  group('StorageFailure', () {
    test('creates with message', () {
      const f = StorageFailure(message: 'Write failed');
      expect(f.message, 'Write failed');
    });
  });

  group('NotFoundFailure', () {
    test('creates with message', () {
      const f = NotFoundFailure(message: 'Visit not found');
      expect(f.message, 'Visit not found');
    });
  });

  group('UnexpectedFailure', () {
    test('creates with message', () {
      const f = UnexpectedFailure(message: 'Unknown');
      expect(f.message, 'Unknown');
    });
  });
}
