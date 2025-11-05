import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/entities/visit_summary.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

enum DayCountingRule {
  anyPresence, // Count any day with at least 1 hour present
  fullDay, // Count only days fully present (24 hours)
}

@injectable
class CalculateVisitSummary {
  final VisitsRepository _repository;

  CalculateVisitSummary(this._repository);

  Future<List<VisitSummary>> execute({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
    bool overnightOnly = false,
  }) async {
    final visits = await _repository.getVisitsInRange(startDate, endDate);

    // Filter by overnight if needed
    final filteredVisits =
        overnightOnly ? visits.where((v) => v.overnightOnly).toList() : visits;

    // Group by country and city
    final Map<String, List<Visit>> grouped = {};
    for (final visit in filteredVisits) {
      final key = '${visit.countryCode}_${visit.city ?? ""}';
      grouped.putIfAbsent(key, () => []).add(visit);
    }

    // Calculate days for each group
    final summaries = <VisitSummary>[];
    for (final entry in grouped.entries) {
      final visitGroup = entry.value;
      final firstVisit = visitGroup.first;

      final days = _calculateDays(visitGroup, rule);

      summaries.add(
        VisitSummary(
          countryCode: firstVisit.countryCode,
          countryName: firstVisit.countryName,
          city: firstVisit.city,
          totalDays: days.length,
          visitDates: days,
        ),
      );
    }

    // Sort by total days descending
    summaries.sort((a, b) => b.totalDays.compareTo(a.totalDays));

    return summaries;
  }

  List<DateTime> _calculateDays(
    List<Visit> visits,
    DayCountingRule rule,
  ) {
    final Set<DateTime> uniqueDays = {};

    for (final visit in visits) {
      final effectiveEndDate = visit.endDate ?? DateTime.now();
      final start = _normalizeDate(visit.startDate);
      final end = _normalizeDate(effectiveEndDate);

      if (rule == DayCountingRule.anyPresence) {
        // Count all days in range
        var current = start;
        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          uniqueDays.add(current);
          current = current.add(const Duration(days: 1));
        }
      } else {
        // Full day counting - only count if visit spans full day
        // This is more complex and would require hourly tracking
        // For now, treat same as any presence
        var current = start;
        while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
          uniqueDays.add(current);
          current = current.add(const Duration(days: 1));
        }
      }
    }

    final sortedDays = uniqueDays.toList()..sort();
    return sortedDays;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
