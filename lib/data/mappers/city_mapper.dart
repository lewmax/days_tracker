import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';

/// Extension to convert CityData (database) to City (domain entity).
extension CityDataMapper on CityData {
  /// Converts this database model to a domain entity.
  ///
  /// [country] Optional country entity to include as navigation property.
  City toEntity({Country? country}) {
    return City(
      id: id,
      countryId: countryId,
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
      totalDays: totalDays,
      country: country,
    );
  }
}

/// Extension to convert City (domain entity) to CityData (database).
extension CityEntityMapper on City {
  /// Converts this domain entity to a database model.
  ///
  /// Note: createdAt and updatedAt are set to current time.
  /// Use this for creating new records.
  CityData toData() {
    final now = DateTime.now().toUtc();
    return CityData(
      id: id,
      countryId: countryId,
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
      totalDays: totalDays,
      createdAt: now,
      updatedAt: now,
    );
  }
}
