import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for retrieving the currently active visit.
///
/// An active visit is one where [Visit.isActive] is true and
/// [Visit.endDate] is null.
@lazySingleton
class GetActiveVisit {
  final VisitsRepository _repository;

  GetActiveVisit(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or [Visit?] on success.
  /// Returns null if no active visit exists.
  Future<Either<Failure, Visit?>> call() async {
    return _repository.getActiveVisit();
  }
}
