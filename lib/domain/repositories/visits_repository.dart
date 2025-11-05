import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/entities/visit.dart';

abstract class VisitsRepository {
  /// Get all visits
  Future<List<Visit>> getAllVisits();

  /// Get active visit (if any)
  Future<Visit?> getActiveVisit();

  /// Create a new visit
  Future<void> createVisit(Visit visit);

  /// Update an existing visit
  Future<void> updateVisit(Visit visit);

  /// Delete a visit
  Future<void> deleteVisit(String visitId);

  /// Close active visit and optionally start a new one
  Future<void> closeActiveVisit(DateTime endDate);

  /// Get visits within a date range
  Future<List<Visit>> getVisitsInRange(DateTime startDate, DateTime endDate);

  /// Add a location ping
  Future<void> addLocationPing(LocationPing ping);

  /// Get all location pings
  Future<List<LocationPing>> getAllLocationPings();

  /// Get pending geocoding pings
  Future<List<LocationPing>> getPendingGeocodingPings();

  /// Update location ping
  Future<void> updateLocationPing(LocationPing ping);

  /// Delete all data (for privacy/reset)
  Future<void> deleteAllData();

  /// Export data as JSON
  Future<String> exportData();

  /// Import data from JSON
  Future<void> importData(String jsonData);
}
