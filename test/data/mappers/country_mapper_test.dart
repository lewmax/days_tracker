import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/mappers/country_mapper.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2025, 1, 1);

  group('CountryDataMapper', () {
    test('toEntity maps all fields', () {
      final data = CountryData(
        id: 1,
        countryCode: 'US',
        countryName: 'United States',
        totalDays: 10,
        firstVisitDate: DateTime.utc(2024),
        lastVisitDate: DateTime.utc(2025),
        createdAt: now,
        updatedAt: now,
      );
      final entity = data.toEntity();
      expect(entity.id, 1);
      expect(entity.countryCode, 'US');
      expect(entity.countryName, 'United States');
      expect(entity.totalDays, 10);
      expect(entity.firstVisitDate, DateTime.utc(2024));
      expect(entity.lastVisitDate, DateTime.utc(2025));
    });

    test('toEntity maps null optional dates', () {
      final data = CountryData(
        id: 2,
        countryCode: 'PL',
        countryName: 'Poland',
        totalDays: 0,
        firstVisitDate: null,
        lastVisitDate: null,
        createdAt: now,
        updatedAt: now,
      );
      final entity = data.toEntity();
      expect(entity.firstVisitDate, isNull);
      expect(entity.lastVisitDate, isNull);
    });
  });

  group('CountryEntityMapper', () {
    test('toData maps entity to CountryData', () {
      final country = Country(
        id: 1,
        countryCode: 'UA',
        countryName: 'Ukraine',
        totalDays: 5,
        firstVisitDate: DateTime.utc(2024),
        lastVisitDate: DateTime.utc(2025),
      );
      final data = country.toData();
      expect(data.id, 1);
      expect(data.countryCode, 'UA');
      expect(data.countryName, 'Ukraine');
      expect(data.totalDays, 5);
      expect(data.firstVisitDate, DateTime.utc(2024));
      expect(data.lastVisitDate, DateTime.utc(2025));
      expect(data.createdAt, isNotNull);
      expect(data.updatedAt, isNotNull);
    });
  });
}
