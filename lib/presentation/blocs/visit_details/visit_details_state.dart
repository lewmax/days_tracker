import 'package:days_tracker/domain/entities/visit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_details_state.freezed.dart';

/// State for VisitDetailsBloc.
@freezed
class VisitDetailsState with _$VisitDetailsState {
  const factory VisitDetailsState.initial() = _Initial;
  const factory VisitDetailsState.loading() = _Loading;
  const factory VisitDetailsState.loaded(Visit visit) = _Loaded;
  const factory VisitDetailsState.error(String message) = _Error;
}
