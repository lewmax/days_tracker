import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisitSource', () {
    test('should have correct labels', () {
      expect(VisitSource.manual.label, 'Manual');
      expect(VisitSource.auto.label, 'Auto');
    });

    test('fromString should parse manual', () {
      expect(VisitSource.fromString('manual'), VisitSource.manual);
      expect(VisitSource.fromString('MANUAL'), VisitSource.manual);
    });

    test('fromString should parse auto', () {
      expect(VisitSource.fromString('auto'), VisitSource.auto);
      expect(VisitSource.fromString('AUTO'), VisitSource.auto);
    });

    test('fromString should return manual for unknown values', () {
      expect(VisitSource.fromString('unknown'), VisitSource.manual);
      expect(VisitSource.fromString(''), VisitSource.manual);
    });

    test('should have correct number of values', () {
      expect(VisitSource.values.length, 2);
    });
  });
}
