import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for retrieving a specific visit by ID.
@lazySingleton
class GetVisitById {
  final VisitsRepository _repository;

  GetVisitById(this._repository);

  /// Executes the use case.
  ///
  /// [id] The unique identifier of the visit to retrieve.
  /// Returns [Either] with [Failure] on error or [Visit] on success.
  Future<Either<Failure, Visit>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure(message: 'Visit ID cannot be empty'));
    }
    return _repository.getVisitById(id);
  }
}
