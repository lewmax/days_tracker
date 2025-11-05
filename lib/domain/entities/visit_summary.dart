import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_summary.freezed.dart';

@freezed
abstract class VisitSummary with _$VisitSummary {
  const factory VisitSummary({
    required String countryCode,
    String? countryName,
    String? city,
    required int totalDays,
    required List<DateTime> visitDates,
  }) = _VisitSummary;
}

@freezed
abstract class SummaryPeriod with _$SummaryPeriod {
  const factory SummaryPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required String label,
  }) = _SummaryPeriod;
}
