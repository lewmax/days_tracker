import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/mappers/visit_mapper.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2025, 1, 1);
  const city = City(
    id: 1,
    countryId: 10,
    cityName: 'Kyiv',
    latitude: 50.45,
    longitude: 30.52,
    totalDays: 5,
  );

  group('VisitDataMapper', () {
    test('toEntity maps all fields without city', () {
      final data = VisitData(
        id: 'v1',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: DateTime.utc(2025, 1, 10),
        isActive: false,
        source: 'manual',
        userLatitude: null,
        userLongitude: null,
        lastUpdated: now,
        createdAt: now,
      );
      final entity = data.toEntity();
      expect(entity.id, 'v1');
      expect(entity.cityId, 1);
      expect(entity.startDate, DateTime.utc(2025));
      expect(entity.endDate, DateTime.utc(2025, 1, 10));
      expect(entity.isActive, false);
      expect(entity.source, VisitSource.manual);
      expect(entity.city, isNull);
    });

    test('toEntity maps with city and active visit', () {
      final data = VisitData(
        id: 'v2',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: null,
        isActive: true,
        source: 'auto',
        userLatitude: 50.0,
        userLongitude: 30.0,
        lastUpdated: now,
        createdAt: now,
      );
      final entity = data.toEntity(city: city);
      expect(entity.city, city);
      expect(entity.source, VisitSource.auto);
      expect(entity.endDate, isNull);
      expect(entity.userLatitude, 50.0);
      expect(entity.userLongitude, 30.0);
    });
  });

  group('VisitEntityMapper', () {
    test('toData maps entity to VisitData', () {
      final visit = Visit(
        id: 'v1',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: DateTime.utc(2025, 1, 15),
        isActive: false,
        source: VisitSource.manual,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: now,
      );
      final data = visit.toData();
      expect(data.id, 'v1');
      expect(data.cityId, 1);
      expect(data.source, 'manual');
      expect(data.isActive, false);
    });

    test('toCompanion returns VisitsCompanion', () {
      final visit = Visit(
        id: 'v1',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: null,
        isActive: true,
        source: VisitSource.auto,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: now,
      );
      final companion = visit.toCompanion();
      expect(companion.id.value, 'v1');
      expect(companion.cityId.value, 1);
      expect(companion.source.value, 'auto');
    });
  });
}
