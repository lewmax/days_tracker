import 'package:days_tracker/domain/entities/visit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visits_event.freezed.dart';

@freezed
class VisitsEvent with _$VisitsEvent {
  const factory VisitsEvent.loadVisits() = LoadVisits;
  const factory VisitsEvent.createVisit(Visit visit) = CreateVisit;
  const factory VisitsEvent.updateVisit(Visit visit) = UpdateVisit;
  const factory VisitsEvent.deleteVisit(String visitId) = DeleteVisit;
  const factory VisitsEvent.refreshLocation() = RefreshLocation;
  const factory VisitsEvent.closeActiveVisit() = CloseActiveVisit;
}
