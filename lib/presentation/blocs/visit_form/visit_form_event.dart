import 'package:days_tracker/domain/entities/city.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_form_event.freezed.dart';

/// Events for the visit add/edit form BLoC.
@freezed
class VisitFormEvent with _$VisitFormEvent {
  /// Load form: for add pass null, for edit pass visit id.
  const factory VisitFormEvent.load(String? visitId) = _Load;

  /// Use current device location to fill city/country.
  const factory VisitFormEvent.useCurrentLocation() = _UseCurrentLocation;

  /// Set selected country (code and name).
  const factory VisitFormEvent.setCountry({required String code, required String name}) =
      _SetCountry;

  /// Set selected city (also updates country from city if present).
  const factory VisitFormEvent.setCity(City city) = _SetCity;

  /// Set start and end dates.
  const factory VisitFormEvent.setDates({required DateTime start, DateTime? end}) = _SetDates;

  /// Save the visit (create or update).
  const factory VisitFormEvent.save() = _Save;

  /// Clear the current error message.
  const factory VisitFormEvent.clearError() = _ClearError;
}
