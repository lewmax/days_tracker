import 'package:days_tracker/domain/usecases/visits/get_visit_by_id.dart';
import 'package:days_tracker/presentation/blocs/visit_details/visit_details_event.dart';
import 'package:days_tracker/presentation/blocs/visit_details/visit_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// BLoC for loading and displaying a single visit's details.
@injectable
class VisitDetailsBloc extends Bloc<VisitDetailsEvent, VisitDetailsState> {
  final GetVisitById _getVisitById;
  final Logger _logger = Logger();
  String? _visitId;

  VisitDetailsBloc(this._getVisitById) : super(const VisitDetailsState.initial()) {
    on<VisitDetailsEvent>(_onEvent);
  }

  Future<void> _onEvent(VisitDetailsEvent event, Emitter<VisitDetailsState> emit) async {
    await event.when(load: (id) => _onLoad(id, emit), retry: () => _onRetry(emit));
  }

  Future<void> _onLoad(String visitId, Emitter<VisitDetailsState> emit) async {
    _visitId = visitId;
    _logger.i('[VisitDetailsBloc] Loading visit id=$visitId');
    emit(const VisitDetailsState.loading());

    final result = await _getVisitById(visitId);

    result.fold(
      (failure) {
        _logger.e('[VisitDetailsBloc] Load failed: ${failure.message}');
        emit(VisitDetailsState.error(failure.message));
      },
      (visit) {
        _logger.i('[VisitDetailsBloc] Loaded visit: ${visit.city?.cityName}');
        emit(VisitDetailsState.loaded(visit));
      },
    );
  }

  Future<void> _onRetry(Emitter<VisitDetailsState> emit) async {
    final id = _visitId;
    if (id != null) {
      _logger.d('[VisitDetailsBloc] Retry loading visit id=$id');
      add(VisitDetailsEvent.load(id));
    }
  }
}
