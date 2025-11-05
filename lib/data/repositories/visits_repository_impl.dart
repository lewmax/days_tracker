import 'dart:convert';
import 'package:days_tracker/data/services/secure_storage_service.dart';
import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@LazySingleton(as: VisitsRepository)
class VisitsRepositoryImpl implements VisitsRepository {
  static const String _visitsKey = 'visits_v1';
  static const String _pingsKey = 'location_pings_v1';
  static const String _activeVisitIdKey = 'active_visit_id';

  final SecureStorageService _storage;
  final Logger _logger = Logger();

  VisitsRepositoryImpl(this._storage);

  @override
  Future<List<Visit>> getAllVisits() async {
    try {
      final jsonList = await _storage.readJsonList(_visitsKey);
      if (jsonList == null) return [];

      return jsonList
          .map((json) => Visit.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error getting all visits: $e');
      return [];
    }
  }

  @override
  Future<Visit?> getActiveVisit() async {
    try {
      final activeId = await _storage.read(_activeVisitIdKey);
      if (activeId == null) return null;

      final visits = await getAllVisits();
      return visits.where((v) => v.id == activeId && v.isActive).firstOrNull;
    } catch (e) {
      _logger.e('Error getting active visit: $e');
      return null;
    }
  }

  @override
  Future<void> createVisit(Visit visit) async {
    try {
      final visits = await getAllVisits();
      visits.add(visit);
      await _saveVisits(visits);

      if (visit.isActive) {
        await _storage.write(_activeVisitIdKey, visit.id);
      }
    } catch (e) {
      _logger.e('Error creating visit: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateVisit(Visit visit) async {
    try {
      final visits = await getAllVisits();
      final index = visits.indexWhere((v) => v.id == visit.id);

      if (index != -1) {
        visits[index] = visit;
        await _saveVisits(visits);

        if (visit.isActive) {
          await _storage.write(_activeVisitIdKey, visit.id);
        }
      }
    } catch (e) {
      _logger.e('Error updating visit: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteVisit(String visitId) async {
    try {
      final visits = await getAllVisits();
      visits.removeWhere((v) => v.id == visitId);
      await _saveVisits(visits);

      final activeId = await _storage.read(_activeVisitIdKey);
      if (activeId == visitId) {
        await _storage.delete(_activeVisitIdKey);
      }
    } catch (e) {
      _logger.e('Error deleting visit: $e');
      rethrow;
    }
  }

  @override
  Future<void> closeActiveVisit(DateTime endDate) async {
    try {
      final activeVisit = await getActiveVisit();
      if (activeVisit != null) {
        final closedVisit = activeVisit.copyWith(
          endDate: endDate,
          isActive: false,
        );
        await updateVisit(closedVisit);
        await _storage.delete(_activeVisitIdKey);
      }
    } catch (e) {
      _logger.e('Error closing active visit: $e');
      rethrow;
    }
  }

  @override
  Future<List<Visit>> getVisitsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allVisits = await getAllVisits();
      return allVisits.where((visit) {
        final visitEnd = visit.endDate ?? DateTime.now();
        return visit.startDate.isBefore(endDate) && visitEnd.isAfter(startDate);
      }).toList();
    } catch (e) {
      _logger.e('Error getting visits in range: $e');
      return [];
    }
  }

  @override
  Future<void> addLocationPing(LocationPing ping) async {
    try {
      final pings = await getAllLocationPings();
      pings.add(ping);

      // Keep only last 1000 pings to avoid storage bloat
      if (pings.length > 1000) {
        pings.removeRange(0, pings.length - 1000);
      }

      await _savePings(pings);
    } catch (e) {
      _logger.e('Error adding location ping: $e');
      rethrow;
    }
  }

  @override
  Future<List<LocationPing>> getAllLocationPings() async {
    try {
      final jsonList = await _storage.readJsonList(_pingsKey);
      if (jsonList == null) return [];

      return jsonList
          .map((json) => LocationPing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error getting location pings: $e');
      return [];
    }
  }

  @override
  Future<List<LocationPing>> getPendingGeocodingPings() async {
    try {
      final allPings = await getAllLocationPings();
      return allPings.where((ping) => ping.geocodingPending).toList();
    } catch (e) {
      _logger.e('Error getting pending geocoding pings: $e');
      return [];
    }
  }

  @override
  Future<void> updateLocationPing(LocationPing ping) async {
    try {
      final pings = await getAllLocationPings();
      final index = pings.indexWhere((p) => p.id == ping.id);

      if (index != -1) {
        pings[index] = ping;
        await _savePings(pings);
      }
    } catch (e) {
      _logger.e('Error updating location ping: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _storage.delete(_visitsKey);
      await _storage.delete(_pingsKey);
      await _storage.delete(_activeVisitIdKey);
    } catch (e) {
      _logger.e('Error deleting all data: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportData() async {
    try {
      final visits = await getAllVisits();
      final pings = await getAllLocationPings();

      final data = {
        'visits': visits.map((v) => v.toJson()).toList(),
        'pings': pings.map((p) => p.toJson()).toList(),
        'exported_at': DateTime.now().toIso8601String(),
      };

      return json.encode(data);
    } catch (e) {
      _logger.e('Error exporting data: $e');
      rethrow;
    }
  }

  @override
  Future<void> importData(String jsonData) async {
    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;

      final visitsJson = data['visits'] as List<dynamic>;
      final visits = visitsJson
          .map((json) => Visit.fromJson(json as Map<String, dynamic>))
          .toList();

      final pingsJson = data['pings'] as List<dynamic>? ?? [];
      final pings = pingsJson
          .map((json) => LocationPing.fromJson(json as Map<String, dynamic>))
          .toList();

      await _saveVisits(visits);
      await _savePings(pings);

      // Update active visit ID if any
      final activeVisit = visits.where((v) => v.isActive).firstOrNull;
      if (activeVisit != null) {
        await _storage.write(_activeVisitIdKey, activeVisit.id);
      }
    } catch (e) {
      _logger.e('Error importing data: $e');
      rethrow;
    }
  }

  Future<void> _saveVisits(List<Visit> visits) async {
    final jsonList = visits.map((v) => v.toJson()).toList();
    await _storage.writeJsonList(_visitsKey, jsonList);
  }

  Future<void> _savePings(List<LocationPing> pings) async {
    final jsonList = pings.map((p) => p.toJson()).toList();
    await _storage.writeJsonList(_pingsKey, jsonList);
  }
}
