import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visits_view_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visits_state.freezed.dart';

/// State for the VisitsBLoC.
@freezed
class VisitsState with _$VisitsState {
  const VisitsState._();

  /// Initial state before any data is loaded.
  const factory VisitsState.initial() = _Initial;

  /// Loading state while fetching visits.
  const factory VisitsState.loading() = _Loading;

  /// Loaded state with visits data.
  const factory VisitsState.loaded({
    required List<Visit> visits,
    required List<Visit> filteredVisits,
    required VisitsViewMode viewMode,
    required String? filterQuery,
    required Visit? activeVisit,
  }) = _Loaded;

  /// Error state when something goes wrong.
  const factory VisitsState.error(String message) = _Error;

  /// Helper to check if we're in loaded state.
  bool get isLoaded => this is _Loaded;

  /// Get visits if loaded, empty list otherwise.
  List<Visit> get visitsOrEmpty =>
      maybeMap(loaded: (state) => state.filteredVisits, orElse: () => []);

  /// Get active visit if loaded.
  Visit? get activeVisitOrNull =>
      maybeMap(loaded: (state) => state.activeVisit, orElse: () => null);
}
