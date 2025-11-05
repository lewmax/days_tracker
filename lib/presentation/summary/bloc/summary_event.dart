part of 'summary_bloc.dart';

@freezed
class SummaryEvent with _$SummaryEvent {
  const factory SummaryEvent.loadSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) = LoadSummary;

  const factory SummaryEvent.toggleOvernightOnly() = ToggleOvernightOnly;

  const factory SummaryEvent.changePeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) = ChangePeriod;
}
