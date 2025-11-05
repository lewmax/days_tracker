import 'package:days_tracker/data/services/location_service.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_event.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  final VisitsRepository _visitsRepository;
  final LocationService _locationService;

  VisitsBloc(
    this._visitsRepository,
    this._locationService,
  ) : super(const VisitsState.initial()) {
    on<LoadVisits>(_onLoadVisits);
    on<CreateVisit>(_onCreateVisit);
    on<UpdateVisit>(_onUpdateVisit);
    on<DeleteVisit>(_onDeleteVisit);
    on<RefreshLocation>(_onRefreshLocation);
    on<CloseActiveVisit>(_onCloseActiveVisit);
  }

  Future<void> _onLoadVisits(
    LoadVisits event,
    Emitter<VisitsState> emit,
  ) async {
    emit(const VisitsState.loading());
    try {
      final visits = await _visitsRepository.getAllVisits();
      final activeVisit = await _visitsRepository.getActiveVisit();

      // Sort visits by start date descending
      visits.sort((a, b) => b.startDate.compareTo(a.startDate));

      emit(VisitsState.loaded(visits: visits, activeVisit: activeVisit));
    } catch (e) {
      emit(VisitsState.error(e.toString()));
    }
  }

  Future<void> _onCreateVisit(
    CreateVisit event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await _visitsRepository.createVisit(event.visit);
      add(const VisitsEvent.loadVisits());
    } catch (e) {
      emit(VisitsState.error(e.toString()));
    }
  }

  Future<void> _onUpdateVisit(
    UpdateVisit event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await _visitsRepository.updateVisit(event.visit);
      add(const VisitsEvent.loadVisits());
    } catch (e) {
      emit(VisitsState.error(e.toString()));
    }
  }

  Future<void> _onDeleteVisit(
    DeleteVisit event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await _visitsRepository.deleteVisit(event.visitId);
      add(const VisitsEvent.loadVisits());
    } catch (e) {
      emit(VisitsState.error(e.toString()));
    }
  }

  Future<void> _onRefreshLocation(
    RefreshLocation event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await _locationService.performLocationCheck(source: 'manual_refresh');
      add(const VisitsEvent.loadVisits());
    } catch (e) {
      emit(VisitsState.error(e.toString()));
    }
  }

  Future<void> _onCloseActiveVisit(
    CloseActiveVisit event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await _visitsRepository.closeActiveVisit(DateTime.now());
      add(const VisitsEvent.loadVisits());
    } catch (e) {
      emit(VisitsState.error(e.toString()));
    }
  }
}
