import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for getting the current day counting rule.
///
/// The day counting rule determines how presence days are calculated:
/// - [DayCountingRule.anyPresence]: Any ping on a day counts as presence
/// - [DayCountingRule.twoOrMorePings]: At least 2 pings required to count
@lazySingleton
class GetDayCountingRule {
  final SettingsRepository _repository;

  GetDayCountingRule(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or [DayCountingRule] on success.
  /// Returns [DayCountingRule.anyPresence] as default if not set.
  Future<Either<Failure, DayCountingRule>> call() async {
    return _repository.getDayCountingRule();
  }
}
