import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/validate_visit_overlap.dart';
import 'package:injectable/injectable.dart';

/// Parameters for updating an existing visit.
class UpdateVisitParams {
  final Visit visit;

  const UpdateVisitParams({required this.visit});
}

/// Use case for updating an existing visit.
///
/// This use case:
/// 1. Validates that the visit dates are valid
/// 2. Checks for overlaps with other visits (excluding itself)
/// 3. Updates the visit in the repository
@lazySingleton
class UpdateVisit {
  final VisitsRepository _repository;
  final ValidateVisitOverlap _validateOverlap;

  UpdateVisit(this._repository, this._validateOverlap);

  /// Executes the use case.
  ///
  /// [params] The parameters containing the visit to update.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(UpdateVisitParams params) async {
    final visit = params.visit;

    // Step 1: Validate ID
    if (visit.id.isEmpty) {
      return const Left(ValidationFailure(message: 'Visit ID cannot be empty'));
    }

    // Step 2: Validate dates
    if (visit.endDate != null && visit.startDate.isAfter(visit.endDate!)) {
      return const Left(ValidationFailure(message: 'Start date must be before end date'));
    }

    // Step 3: Check for overlaps (excluding this visit)
    final overlapResult = await _validateOverlap(visit);

    return overlapResult.fold((failure) => Left(failure), (validationResult) async {
      if (validationResult.hasOverlap) {
        return Left(
          ValidationFailure(
            message: validationResult.message ?? 'Visit overlaps with existing visit',
          ),
        );
      }

      // Step 4: Update the visit
      return _repository.updateVisit(visit);
    });
  }
}
