import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visits_view_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visits_event.freezed.dart';

/// Events for the VisitsBLoC.
@freezed
class VisitsEvent with _$VisitsEvent {
  /// Load all visits from the repository.
  const factory VisitsEvent.loadVisits() = _LoadVisits;

  /// Refresh visits (pull-to-refresh).
  const factory VisitsEvent.refreshVisits() = _RefreshVisits;

  /// Create a new visit.
  const factory VisitsEvent.createVisit(Visit visit) = _CreateVisit;

  /// Update an existing visit.
  const factory VisitsEvent.updateVisit(Visit visit) = _UpdateVisit;

  /// Delete a visit by ID.
  const factory VisitsEvent.deleteVisit(String id) = _DeleteVisit;

  /// Change the view mode for the visits list.
  const factory VisitsEvent.changeViewMode(VisitsViewMode mode) = _ChangeViewMode;

  /// Filter visits by search query.
  const factory VisitsEvent.filterVisits(String query) = _FilterVisits;

  /// Clear any filters applied to visits.
  const factory VisitsEvent.clearFilter() = _ClearFilter;
}
