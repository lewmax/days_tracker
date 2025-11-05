import 'package:days_tracker/domain/entities/visit_summary.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:days_tracker/domain/usecases/calculate_visit_summary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'summary_event.dart';
part 'summary_state.dart';
part 'summary_bloc.freezed.dart';

@injectable
class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final CalculateVisitSummary _calculateVisitSummary;
  final SettingsRepository _settingsRepository;

  SummaryBloc(
    this._calculateVisitSummary,
    this._settingsRepository,
  ) : super(const SummaryState.initial()) {
    on<LoadSummary>(_onLoadSummary);
    on<ToggleOvernightOnly>(_onToggleOvernightOnly);
    on<ChangePeriod>(_onChangePeriod);
  }

  Future<void> _onLoadSummary(
    LoadSummary event,
    Emitter<SummaryState> emit,
  ) async {
    emit(const SummaryState.loading());
    try {
      final overnightOnly = await _settingsRepository.isOvernightOnlyEnabled();
      final ruleStr = await _settingsRepository.getDayCountingRule();
      final rule = ruleStr == 'fullDay'
          ? DayCountingRule.fullDay
          : DayCountingRule.anyPresence;

      final summaries = await _calculateVisitSummary.execute(
        startDate: event.startDate,
        endDate: event.endDate,
        rule: rule,
        overnightOnly: overnightOnly,
      );

      emit(SummaryState.loaded(
        summaries: summaries,
        startDate: event.startDate,
        endDate: event.endDate,
        overnightOnly: overnightOnly,
      ));
    } catch (e) {
      emit(SummaryState.error(e.toString()));
    }
  }

  Future<void> _onToggleOvernightOnly(
    ToggleOvernightOnly event,
    Emitter<SummaryState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final newValue = !currentState.overnightOnly;
      await _settingsRepository.setOvernightOnlyEnabled(newValue);

      add(SummaryEvent.loadSummary(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      ));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<SummaryState> emit,
  ) async {
    add(SummaryEvent.loadSummary(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }
}
