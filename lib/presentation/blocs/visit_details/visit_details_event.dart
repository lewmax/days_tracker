import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_details_event.freezed.dart';

/// Events for VisitDetailsBloc.
@freezed
class VisitDetailsEvent with _$VisitDetailsEvent {
  /// Load visit by id.
  const factory VisitDetailsEvent.load(String visitId) = _Load;

  /// Retry loading after error.
  const factory VisitDetailsEvent.retry() = _Retry;
}
