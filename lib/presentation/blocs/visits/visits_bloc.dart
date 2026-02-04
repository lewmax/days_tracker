import 'dart:async';

import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visits_view_mode.dart';
import 'package:days_tracker/domain/usecases/visits/create_visit.dart';
import 'package:days_tracker/domain/usecases/visits/delete_visit.dart';
import 'package:days_tracker/domain/usecases/visits/get_active_visit.dart';
import 'package:days_tracker/domain/usecases/visits/get_all_visits.dart';
import 'package:days_tracker/domain/usecases/visits/update_visit.dart';
import 'package:days_tracker/domain/usecases/visits/watch_visits.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_event.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// BLoC for managing visits state.
///
/// Handles loading, creating, updating, and deleting visits,
/// as well as filtering and changing view modes.
@injectable
class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  final GetAllVisits _getAllVisits;
  final GetActiveVisit _getActiveVisit;
  final CreateVisit _createVisit;
  final UpdateVisit _updateVisit;
  final DeleteVisit _deleteVisit;
  final WatchVisits _watchVisits;
  final Logger _logger = Logger();

  StreamSubscription<List<Visit>>? _visitsSubscription;
  VisitsViewMode _currentViewMode = VisitsViewMode.chronological;
  String? _currentFilter;

  VisitsBloc(
    this._getAllVisits,
    this._getActiveVisit,
    this._createVisit,
    this._updateVisit,
    this._deleteVisit,
    this._watchVisits,
  ) : super(const VisitsState.initial()) {
    on<VisitsEvent>(_onEvent);

    // Start watching visits
    _startWatching();
  }

  void _startWatching() {
    _logger.d('[VisitsBloc] Starting visits stream subscription');
    _visitsSubscription?.cancel();
    _visitsSubscription = _watchVisits().listen((visits) {
      _logger.d('[VisitsBloc] Visits stream update: ${visits.length} visits');
      // if (state is! VisitsState) return;
      state.mapOrNull(
        initial: (_) => add(const VisitsEvent.loadVisits()),
        loaded: (_) => add(const VisitsEvent.refreshVisits()),
        error: (_) => add(const VisitsEvent.loadVisits()),
      );
    });
  }

  Future<void> _onEvent(VisitsEvent event, Emitter<VisitsState> emit) async {
    _logger.d('[VisitsBloc] Event: $event');
    await event.when(
      loadVisits: () => _onLoadVisits(emit),
      refreshVisits: () => _onRefreshVisits(emit),
      createVisit: (visit) => _onCreateVisit(visit, emit),
      updateVisit: (visit) => _onUpdateVisit(visit, emit),
      deleteVisit: (id) => _onDeleteVisit(id, emit),
      changeViewMode: (mode) => _onChangeViewMode(mode, emit),
      filterVisits: (query) => _onFilterVisits(query, emit),
      clearFilter: () => _onClearFilter(emit),
    );
  }

  Future<void> _onLoadVisits(Emitter<VisitsState> emit) async {
    _logger.i('[VisitsBloc] Loading visits');
    emit(const VisitsState.loading());

    final visitsResult = await _getAllVisits();
    final activeResult = await _getActiveVisit();

    visitsResult.fold(
      (failure) {
        _logger.e('[VisitsBloc] Load failed: ${failure.message}');
        emit(VisitsState.error(failure.message));
      },
      (visits) {
        final activeVisit = activeResult.fold((failure) => null, (active) => active);
        final sortedVisits = _sortVisits(visits, _currentViewMode);
        final filteredVisits = _filterVisits(sortedVisits, _currentFilter);
        _logger.i(
          '[VisitsBloc] Loaded ${visits.length} visits, activeVisit: ${activeVisit != null}',
        );
        emit(
          VisitsState.loaded(
            visits: sortedVisits,
            filteredVisits: filteredVisits,
            viewMode: _currentViewMode,
            filterQuery: _currentFilter,
            activeVisit: activeVisit,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshVisits(Emitter<VisitsState> emit) async {
    _logger.d('[VisitsBloc] Refreshing visits');
    final visitsResult = await _getAllVisits();
    final activeResult = await _getActiveVisit();

    visitsResult.fold(
      (failure) {
        _logger.e('[VisitsBloc] Refresh failed: ${failure.message}');
        emit(VisitsState.error(failure.message));
      },
      (visits) {
        final activeVisit = activeResult.fold((failure) => null, (active) => active);
        final sortedVisits = _sortVisits(visits, _currentViewMode);
        final filteredVisits = _filterVisits(sortedVisits, _currentFilter);
        emit(
          VisitsState.loaded(
            visits: sortedVisits,
            filteredVisits: filteredVisits,
            viewMode: _currentViewMode,
            filterQuery: _currentFilter,
            activeVisit: activeVisit,
          ),
        );
      },
    );
  }

  Future<void> _onCreateVisit(Visit visit, Emitter<VisitsState> emit) async {
    _logger.i(
      '[VisitsBloc] Creating visit: ${visit.city?.cityName}, ${visit.city?.country?.countryName}',
    );
    final result = await _createVisit(CreateVisitParams(visit: visit));

    result.fold(
      (failure) {
        _logger.e('[VisitsBloc] Create visit failed: ${failure.message}');
        emit(VisitsState.error(failure.message));
      },
      (_) {
        _logger.i('[VisitsBloc] Visit created successfully');
        add(const VisitsEvent.loadVisits());
      },
    );
  }

  Future<void> _onUpdateVisit(Visit visit, Emitter<VisitsState> emit) async {
    _logger.i('[VisitsBloc] Updating visit id=${visit.id}');
    final result = await _updateVisit(UpdateVisitParams(visit: visit));

    result.fold(
      (failure) {
        _logger.e('[VisitsBloc] Update visit failed: ${failure.message}');
        emit(VisitsState.error(failure.message));
      },
      (_) {
        _logger.i('[VisitsBloc] Visit updated successfully');
        add(const VisitsEvent.loadVisits());
      },
    );
  }

  Future<void> _onDeleteVisit(String id, Emitter<VisitsState> emit) async {
    _logger.i('[VisitsBloc] Deleting visit id=$id');
    final result = await _deleteVisit(id);

    result.fold(
      (failure) {
        _logger.e('[VisitsBloc] Delete visit failed: ${failure.message}');
        emit(VisitsState.error(failure.message));
      },
      (_) {
        _logger.i('[VisitsBloc] Visit deleted successfully');
        add(const VisitsEvent.loadVisits());
      },
    );
  }

  Future<void> _onChangeViewMode(VisitsViewMode mode, Emitter<VisitsState> emit) async {
    _logger.d('[VisitsBloc] View mode changed to $mode');
    _currentViewMode = mode;

    state.mapOrNull(
      loaded: (loadedState) {
        final sortedVisits = _sortVisits(loadedState.visits, mode);
        final filteredVisits = _filterVisits(sortedVisits, _currentFilter);

        emit(
          loadedState.copyWith(
            visits: sortedVisits,
            filteredVisits: filteredVisits,
            viewMode: mode,
          ),
        );
      },
    );
  }

  Future<void> _onFilterVisits(String query, Emitter<VisitsState> emit) async {
    _currentFilter = query.isEmpty ? null : query;

    state.mapOrNull(
      loaded: (loadedState) {
        final filteredVisits = _filterVisits(loadedState.visits, _currentFilter);

        emit(loadedState.copyWith(filteredVisits: filteredVisits, filterQuery: _currentFilter));
      },
    );
  }

  Future<void> _onClearFilter(Emitter<VisitsState> emit) async {
    _currentFilter = null;

    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(filteredVisits: loadedState.visits, filterQuery: null));
      },
    );
  }

  /// Sorts visits based on the selected view mode.
  List<Visit> _sortVisits(List<Visit> visits, VisitsViewMode mode) {
    final sorted = List<Visit>.from(visits);

    switch (mode) {
      case VisitsViewMode.chronological:
        sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
      case VisitsViewMode.groupedByCountry:
        // Group by country, then sort by start date within each group
        sorted.sort((a, b) {
          final countryCompare = (a.city?.country?.countryName ?? '').compareTo(
            b.city?.country?.countryName ?? '',
          );
          if (countryCompare != 0) return countryCompare;
          return b.startDate.compareTo(a.startDate);
        });
      case VisitsViewMode.activeFirst:
        sorted.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return b.startDate.compareTo(a.startDate);
        });
      case VisitsViewMode.monthGrouping:
        // Sort by start date (will be grouped in UI)
        sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    return sorted;
  }

  /// Filters visits based on search query.
  List<Visit> _filterVisits(List<Visit> visits, String? query) {
    if (query == null || query.isEmpty) return visits;

    final lowerQuery = query.toLowerCase();
    return visits.where((visit) {
      final cityName = visit.city?.cityName.toLowerCase() ?? '';
      final countryName = visit.city?.country?.countryName.toLowerCase() ?? '';
      return cityName.contains(lowerQuery) || countryName.contains(lowerQuery);
    }).toList();
  }

  @override
  Future<void> close() {
    _visitsSubscription?.cancel();
    return super.close();
  }
}
