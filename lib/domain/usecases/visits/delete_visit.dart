import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for deleting a visit.
///
/// This will also delete associated daily_presence records.
@lazySingleton
class DeleteVisit {
  final VisitsRepository _repository;

  DeleteVisit(this._repository);

  /// Executes the use case.
  ///
  /// [id] The unique identifier of the visit to delete.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure(message: 'Visit ID cannot be empty'));
    }
    return _repository.deleteVisit(id);
  }
}
