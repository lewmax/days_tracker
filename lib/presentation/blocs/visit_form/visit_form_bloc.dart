import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/usecases/geocoding/reverse_geocode_location.dart';
import 'package:days_tracker/domain/usecases/location/get_current_location.dart';
import 'package:days_tracker/domain/usecases/visits/create_visit.dart';
import 'package:days_tracker/domain/usecases/visits/get_visit_by_id.dart';
import 'package:days_tracker/domain/usecases/visits/update_visit.dart';
import 'package:days_tracker/presentation/blocs/visit_form/visit_form_event.dart';
import 'package:days_tracker/presentation/blocs/visit_form/visit_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// BLoC for the add/edit visit form.
///
/// Handles loading visit for edit, current location, form fields, and save.
@injectable
class VisitFormBloc extends Bloc<VisitFormEvent, VisitFormState> {
  final GetVisitById _getVisitById;
  final GetCurrentLocation _getCurrentLocation;
  final ReverseGeocodeLocation _reverseGeocode;
  final CreateVisit _createVisit;
  final UpdateVisit _updateVisit;
  final Logger _logger = Logger();

  VisitFormBloc(
    this._getVisitById,
    this._getCurrentLocation,
    this._reverseGeocode,
    this._createVisit,
    this._updateVisit,
  ) : super(const VisitFormState.initial()) {
    on<VisitFormEvent>(
      (event, emit) => event.when(
        load: (visitId) => _onLoad(visitId, emit),
        useCurrentLocation: () => _onUseCurrentLocation(emit),
        setCountry: (code, name) => _onSetCountry(code, name, emit),
        setCity: (city) => _onSetCity(city, emit),
        setDates: (start, end) => _onSetDates(start, end, emit),
        save: () => _onSave(emit),
        clearError: () => _onClearError(emit),
      ),
    );
  }

  Future<void> _onLoad(String? visitId, Emitter<VisitFormState> emit) async {
    if (visitId == null || visitId.isEmpty) {
      _logger.d('[VisitFormBloc] Add mode: emitting empty form');
      emit(VisitFormState.form(VisitFormData.empty()));
      return;
    }

    _logger.i('[VisitFormBloc] Loading visit for edit: $visitId');
    emit(VisitFormState.loadingVisit(visitId));

    final result = await _getVisitById(visitId);

    return result.fold(
      (failure) {
        _logger.e('[VisitFormBloc] Load visit failed: ${failure.message}');
        emit(VisitFormState.loadError(failure.message));
      },
      (visit) {
        _logger.i('[VisitFormBloc] Loaded visit: ${visit.city?.cityName}');
        emit(
          VisitFormState.form(
            VisitFormData(
              visitId: visit.id,
              originalVisit: visit,
              countryCode: visit.city?.country?.countryCode,
              countryName: visit.city?.country?.countryName,
              city: visit.city,
              startDate: visit.startDate,
              endDate: visit.endDate,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUseCurrentLocation(Emitter<VisitFormState> emit) async {
    final VisitFormData? currentData = state.mapOrNull(form: (s) => s.data);
    final isInitial = state.mapOrNull(initial: (_) => true) ?? false;

    if (currentData == null && !isInitial) return;

    final data = (currentData ?? VisitFormData.empty()).copyWith(
      isLocationLoading: true,
      errorMessage: null,
    );
    emit(VisitFormState.form(data));

    _logger.i('[VisitFormBloc] Fetching current location');
    final locationResult = await _getCurrentLocation();

    return locationResult.fold(
      (failure) async {
        _logger.e('[VisitFormBloc] Location failed: ${failure.message}');
        _emitFormWithError(failure.message, emit);
      },
      (location) async {
        _logger.d('[VisitFormBloc] Reverse geocoding ${location.latitude}, ${location.longitude}');
        final geocodeResult = await _reverseGeocode(
          ReverseGeocodeParams(latitude: location.latitude, longitude: location.longitude),
        );

        return geocodeResult.fold(
          (failure) {
            _logger.e('[VisitFormBloc] Geocoding failed: ${failure.message}');
            _emitFormWithError(failure.message, emit);
          },
          (city) {
            _logger.i(
              '[VisitFormBloc] Resolved city: ${city.cityName}, ${city.country?.countryCode}',
            );
            emit(
              VisitFormState.form(
                data.copyWith(
                  city: city,
                  countryCode: city.country?.countryCode,
                  countryName: city.country?.countryName,
                  isLocationLoading: false,
                  errorMessage: null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _emitFormWithError(String message, Emitter<VisitFormState> emit) {
    final currentData = state.mapOrNull(form: (s) => s.data);
    final isInitial = state.mapOrNull(initial: (_) => true) ?? false;
    if (currentData != null) {
      emit(
        VisitFormState.form(
          currentData.copyWith(isLocationLoading: false, isSaving: false, errorMessage: message),
        ),
      );
    } else if (isInitial) {
      emit(VisitFormState.form(VisitFormData(errorMessage: message)));
    }
  }

  void _onSetCountry(String code, String name, Emitter<VisitFormState> emit) {
    _logger.d('[VisitFormBloc] Set country: $code $name');
    final currentData = state.mapOrNull(form: (s) => s.data);
    if (currentData != null) {
      emit(
        VisitFormState.form(
          currentData.copyWith(
            countryCode: code,
            countryName: name,
            city: null,
            errorMessage: null,
          ),
        ),
      );
    } else if (state.mapOrNull(initial: (_) => true) == true) {
      emit(VisitFormState.form(VisitFormData(countryCode: code, countryName: name, city: null)));
    }
  }

  void _onSetCity(City city, Emitter<VisitFormState> emit) {
    _logger.d('[VisitFormBloc] Set city: ${city.cityName}');
    final currentData = state.mapOrNull(form: (s) => s.data);
    if (currentData != null) {
      emit(
        VisitFormState.form(
          currentData.copyWith(
            city: city,
            countryCode: city.country?.countryCode ?? currentData.countryCode,
            countryName: city.country?.countryName ?? currentData.countryName,
            errorMessage: null,
          ),
        ),
      );
    } else if (state.mapOrNull(initial: (_) => true) == true) {
      emit(
        VisitFormState.form(
          VisitFormData(
            city: city,
            countryCode: city.country?.countryCode,
            countryName: city.country?.countryName,
          ),
        ),
      );
    }
  }

  void _onSetDates(DateTime start, DateTime? end, Emitter<VisitFormState> emit) {
    _logger.d('[VisitFormBloc] Set dates: $start -> $end');
    final currentData = state.mapOrNull(form: (s) => s.data);
    if (currentData != null) {
      emit(
        VisitFormState.form(
          currentData.copyWith(startDate: start, endDate: end, errorMessage: null),
        ),
      );
    } else if (state.mapOrNull(initial: (_) => true) == true) {
      emit(VisitFormState.form(VisitFormData(startDate: start, endDate: end)));
    }
  }

  Future<void> _onSave(Emitter<VisitFormState> emit) async {
    final data = state.mapOrNull(form: (s) => s.data);
    if (data == null) return;

    if (data.countryCode == null) {
      _logger.w('[VisitFormBloc] Save validation: no country');
      emit(VisitFormState.form(data.copyWith(errorMessage: 'Please select a country')));
      return;
    }
    if (data.city == null) {
      _logger.w('[VisitFormBloc] Save validation: no city');
      emit(VisitFormState.form(data.copyWith(errorMessage: 'Please select a city')));
      return;
    }
    if (data.startDate == null) {
      _logger.w('[VisitFormBloc] Save validation: no start date');
      emit(VisitFormState.form(data.copyWith(errorMessage: 'Please select a start date')));
      return;
    }

    emit(VisitFormState.form(data.copyWith(isSaving: true, errorMessage: null)));

    if (data.visitId != null && data.originalVisit != null) {
      _logger.i('[VisitFormBloc] Updating visit ${data.visitId}');
      final updated = data.originalVisit!.copyWith(
        cityId: data.city!.id,
        city: data.city!.copyWith(
          country: Country(
            id: data.city!.country?.id ?? 0,
            countryCode: data.countryCode!,
            countryName: data.countryName ?? '',
            totalDays: data.city!.country?.totalDays ?? 0,
          ),
        ),
        startDate: data.startDate,
        endDate: data.endDate,
        isActive: data.endDate == null,
        lastUpdated: DateTime.now().toUtc(),
      );

      final result = await _updateVisit(UpdateVisitParams(visit: updated));

      return result.fold(
        (failure) {
          _logger.e('[VisitFormBloc] Update failed: ${failure.message}');
          emit(VisitFormState.form(data.copyWith(isSaving: false, errorMessage: failure.message)));
        },
        (_) {
          _logger.i('[VisitFormBloc] Update success');
          emit(const VisitFormState.saveSuccess());
        },
      );
    } else {
      _logger.i('[VisitFormBloc] Creating new visit');
      final visit = Visit(
        id: const Uuid().v4(),
        cityId: data.city!.id,
        city: data.city!.copyWith(
          country: Country(
            id: 0,
            countryCode: data.countryCode!,
            countryName: data.countryName ?? '',
          ),
        ),
        startDate: data.startDate!,
        endDate: data.endDate,
        isActive: data.endDate == null,
        source: VisitSource.manual,
        lastUpdated: DateTime.now().toUtc(),
      );

      final result = await _createVisit(CreateVisitParams(visit: visit));

      return result.fold(
        (failure) {
          _logger.e('[VisitFormBloc] Create failed: ${failure.message}');
          emit(VisitFormState.form(data.copyWith(isSaving: false, errorMessage: failure.message)));
        },
        (_) {
          _logger.i('[VisitFormBloc] Create success');
          emit(const VisitFormState.saveSuccess());
        },
      );
    }
  }

  void _onClearError(Emitter<VisitFormState> emit) {
    final currentData = state.mapOrNull(form: (s) => s.data);
    if (currentData != null && currentData.errorMessage != null) {
      emit(VisitFormState.form(currentData.copyWith(errorMessage: null)));
    }
  }
}
