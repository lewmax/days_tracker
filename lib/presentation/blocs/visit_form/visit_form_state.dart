import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_form_state.freezed.dart';

/// Immutable form data for add/edit visit.
@freezed
abstract class VisitFormData with _$VisitFormData {
  const factory VisitFormData({
    String? visitId,
    Visit? originalVisit,
    String? countryCode,
    String? countryName,
    City? city,
    DateTime? startDate,
    DateTime? endDate,
    @Default(false) bool isLocationLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _VisitFormData;

  factory VisitFormData.empty() => const VisitFormData();
}

/// State for VisitFormBloc.
@freezed
class VisitFormState with _$VisitFormState {
  /// Initial (add mode): empty form.
  const factory VisitFormState.initial() = _Initial;

  /// Loading visit for edit.
  const factory VisitFormState.loadingVisit(String visitId) = _LoadingVisit;

  /// Failed to load visit for edit.
  const factory VisitFormState.loadError(String message) = _LoadError;

  /// Form ready (add or edit) with current data.
  const factory VisitFormState.form(VisitFormData data) = _Form;

  /// Save completed successfully (UI should pop).
  const factory VisitFormState.saveSuccess() = _SaveSuccess;
}
