import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/presentation/map/bloc/map_event.dart';
import 'package:days_tracker/presentation/map/bloc/map_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final VisitsRepository _visitsRepository;

  MapBloc(this._visitsRepository) : super(const MapState.initial()) {
    on<LoadMapData>(_onLoadMapData);
    on<SelectCountry>(_onSelectCountry);
    on<SelectCity>(_onSelectCity);
  }

  Future<void> _onLoadMapData(
    LoadMapData event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapState.loading());
    try {
      final visits = await _visitsRepository.getAllVisits();

      final visitedCountries = <String>{};
      final countryCities = <String, List<String>>{};

      for (final visit in visits) {
        visitedCountries.add(visit.countryCode);
        if (visit.city != null) {
          countryCities
              .putIfAbsent(visit.countryCode, () => [])
              .add(visit.city!);
        }
      }

      // Remove duplicates from city lists
      for (final key in countryCities.keys) {
        countryCities[key] = countryCities[key]!.toSet().toList();
      }

      emit(MapState.loaded(
        visits: visits,
        visitedCountries: visitedCountries,
        countryCities: countryCities,
      ));
    } catch (e) {
      emit(MapState.error(e.toString()));
    }
  }

  Future<void> _onSelectCountry(
    SelectCountry event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is Loaded) {
      emit(currentState.copyWith(
        selectedCountry: event.countryCode,
        selectedCity: null,
      ));
    }
  }

  Future<void> _onSelectCity(
    SelectCity event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is Loaded) {
      emit(currentState.copyWith(selectedCity: event.city));
    }
  }
}
