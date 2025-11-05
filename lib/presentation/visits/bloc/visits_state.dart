import 'package:days_tracker/domain/entities/visit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visits_state.freezed.dart';

@freezed
class VisitsState with _$VisitsState {
  const factory VisitsState.initial() = _Initial;
  const factory VisitsState.loading() = _Loading;
  const factory VisitsState.loaded({
    required List<Visit> visits,
    Visit? activeVisit,
  }) = _Loaded;
  const factory VisitsState.error(String message) = _Error;
}
