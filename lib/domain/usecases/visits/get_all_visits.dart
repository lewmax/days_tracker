import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for retrieving all visits.
///
/// Returns a list of all visits ordered by start date (newest first).
@lazySingleton
class GetAllVisits {
  final VisitsRepository _repository;

  GetAllVisits(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or [List<Visit>] on success.
  Future<Either<Failure, List<Visit>>> call() async {
    return _repository.getAllVisits();
  }
}
