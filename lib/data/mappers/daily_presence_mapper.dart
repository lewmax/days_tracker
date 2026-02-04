import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/daily_presence.dart' as domain;
import 'package:drift/drift.dart';

/// Extension to convert DailyPresenceData (database) to DailyPresence (domain entity).
extension DailyPresenceDataMapper on DailyPresenceData {
  /// Converts this database model to a domain entity.
  ///
  /// [city] Optional city entity to include as navigation property.
  /// [country] Optional country entity to include as navigation property.
  domain.DailyPresence toEntity({City? city, Country? country}) {
    return domain.DailyPresence(
      id: id,
      visitId: visitId,
      date: date,
      cityId: cityId,
      countryId: countryId,
      pingCount: pingCount,
      meetsAnyPresenceRule: meetsAnyPresenceRule,
      meetsTwoOrMorePingsRule: meetsTwoOrMorePingsRule,
      city: city,
      country: country,
    );
  }
}

/// Extension to convert DailyPresence (domain entity) to DailyPresenceData (database).
extension DailyPresenceEntityMapper on domain.DailyPresence {
  /// Converts this domain entity to a database model.
  DailyPresenceData toData() {
    final now = DateTime.now().toUtc();
    return DailyPresenceData(
      id: id,
      visitId: visitId,
      date: date,
      cityId: cityId,
      countryId: countryId,
      pingCount: pingCount,
      meetsAnyPresenceRule: meetsAnyPresenceRule,
      meetsTwoOrMorePingsRule: meetsTwoOrMorePingsRule,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Converts this domain entity to a Drift companion for insertion.
  DailyPresenceTableCompanion toCompanion() {
    final now = DateTime.now().toUtc();
    return DailyPresenceTableCompanion(
      visitId: Value(visitId),
      date: Value(date),
      cityId: Value(cityId),
      countryId: Value(countryId),
      pingCount: Value(pingCount),
      meetsAnyPresenceRule: Value(meetsAnyPresenceRule),
      meetsTwoOrMorePingsRule: Value(meetsTwoOrMorePingsRule),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }
}
