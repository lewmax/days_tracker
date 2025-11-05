import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class UpdateVisitFromLocation {
  final VisitsRepository _repository;
  final Uuid _uuid = const Uuid();

  UpdateVisitFromLocation(this._repository);

  /// Update or create visit based on location ping
  /// Returns true if a new visit was started
  Future<bool> execute(LocationPing ping) async {
    final activeVisit = await _repository.getActiveVisit();

    // Add the ping to history
    await _repository.addLocationPing(ping);

    // If no city/country info yet, we can't create/update visits
    if (ping.countryCode == null) {
      return false;
    }

    final now = DateTime.now();

    if (activeVisit == null) {
      // No active visit - create new one
      final newVisit = Visit(
        id: _uuid.v4(),
        countryCode: ping.countryCode!,
        city: ping.city,
        startDate: now,
        latitude: ping.latitude,
        longitude: ping.longitude,
        overnightOnly: false,
        isActive: true,
        lastUpdated: now,
      );
      await _repository.createVisit(newVisit);
      return true;
    }

    // Check if location changed (different country or city)
    final sameCountry = activeVisit.countryCode == ping.countryCode;
    final sameCity = activeVisit.city == ping.city;

    if (sameCountry && sameCity) {
      // Still in same location - update lastUpdated
      final updatedVisit = activeVisit.copyWith(
        lastUpdated: now,
        latitude: ping.latitude,
        longitude: ping.longitude,
      );
      await _repository.updateVisit(updatedVisit);
      return false;
    } else {
      // Location changed - close current visit and start new one
      await _repository.closeActiveVisit(activeVisit.lastUpdated);

      final newVisit = Visit(
        id: _uuid.v4(),
        countryCode: ping.countryCode!,
        city: ping.city,
        startDate: now,
        latitude: ping.latitude,
        longitude: ping.longitude,
        overnightOnly: false,
        isActive: true,
        lastUpdated: now,
      );
      await _repository.createVisit(newVisit);
      return true;
    }
  }
}
