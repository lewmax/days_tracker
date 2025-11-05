part of 'summary_bloc.dart';

@freezed
class SummaryState with _$SummaryState {
  const factory SummaryState.initial() = _Initial;
  const factory SummaryState.loading() = _Loading;
  const factory SummaryState.loaded({
    required List<VisitSummary> summaries,
    required DateTime startDate,
    required DateTime endDate,
    required bool overnightOnly,
  }) = _Loaded;
  const factory SummaryState.error(String message) = _Error;
}
