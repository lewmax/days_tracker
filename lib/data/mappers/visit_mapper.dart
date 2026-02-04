import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:drift/drift.dart';

/// Extension to convert VisitData (database) to Visit (domain entity).
extension VisitDataMapper on VisitData {
  /// Converts this database model to a domain entity.
  ///
  /// [city] Optional city entity to include as navigation property.
  Visit toEntity({City? city}) {
    return Visit(
      id: id,
      cityId: cityId,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      source: VisitSource.fromString(source),
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      lastUpdated: lastUpdated,
      city: city,
    );
  }
}

/// Extension to convert Visit (domain entity) to VisitData (database).
extension VisitEntityMapper on Visit {
  /// Converts this domain entity to a database model.
  ///
  /// Note: createdAt is set to current time.
  /// Use this for creating new records.
  VisitData toData() {
    final now = DateTime.now().toUtc();
    return VisitData(
      id: id,
      cityId: cityId,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      source: source.name,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      lastUpdated: lastUpdated,
      createdAt: now,
    );
  }

  /// Converts this domain entity to a Drift companion for insertion.
  VisitsCompanion toCompanion() {
    final now = DateTime.now().toUtc();
    return VisitsCompanion(
      id: Value(id),
      cityId: Value(cityId),
      startDate: Value(startDate),
      endDate: Value(endDate),
      isActive: Value(isActive),
      source: Value(source.name),
      userLatitude: Value(userLatitude),
      userLongitude: Value(userLongitude),
      lastUpdated: Value(lastUpdated),
      createdAt: Value(now),
    );
  }
}
