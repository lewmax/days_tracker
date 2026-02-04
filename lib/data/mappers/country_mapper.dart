import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/domain/entities/country.dart';

/// Extension to convert CountryData (database) to Country (domain entity).
extension CountryDataMapper on CountryData {
  /// Converts this database model to a domain entity.
  Country toEntity() {
    return Country(
      id: id,
      countryCode: countryCode,
      countryName: countryName,
      totalDays: totalDays,
      firstVisitDate: firstVisitDate,
      lastVisitDate: lastVisitDate,
    );
  }
}

/// Extension to convert Country (domain entity) to CountryData (database).
extension CountryEntityMapper on Country {
  /// Converts this domain entity to a database model.
  ///
  /// Note: createdAt and updatedAt are set to current time.
  /// Use this for creating new records.
  CountryData toData() {
    final now = DateTime.now().toUtc();
    return CountryData(
      id: id,
      countryCode: countryCode,
      countryName: countryName,
      totalDays: totalDays,
      firstVisitDate: firstVisitDate,
      lastVisitDate: lastVisitDate,
      createdAt: now,
      updatedAt: now,
    );
  }
}
