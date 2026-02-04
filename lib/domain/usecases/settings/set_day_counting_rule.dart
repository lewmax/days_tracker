import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for setting the day counting rule.
///
/// Changes how presence days are calculated throughout the app.
@lazySingleton
class SetDayCountingRule {
  final SettingsRepository _repository;

  SetDayCountingRule(this._repository);

  /// Executes the use case.
  ///
  /// [rule] The new day counting rule to set.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(DayCountingRule rule) async {
    return _repository.setDayCountingRule(rule);
  }
}
