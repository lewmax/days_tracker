import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/validate_visit_overlap.dart';
import 'package:injectable/injectable.dart';

/// Parameters for creating a new visit.
class CreateVisitParams {
  final Visit visit;

  const CreateVisitParams({required this.visit});
}

/// Use case for creating a new visit.
///
/// This use case:
/// 1. Validates that the visit dates are valid
/// 2. Checks for overlaps with existing visits
/// 3. Creates the visit in the repository
@lazySingleton
class CreateVisit {
  final VisitsRepository _repository;
  final ValidateVisitOverlap _validateOverlap;

  CreateVisit(this._repository, this._validateOverlap);

  /// Executes the use case.
  ///
  /// [params] The parameters containing the visit to create.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(CreateVisitParams params) async {
    final visit = params.visit;

    // Step 1: Validate dates
    if (visit.endDate != null && visit.startDate.isAfter(visit.endDate!)) {
      return const Left(ValidationFailure(message: 'Start date must be before end date'));
    }

    // Step 2: Check for overlaps
    final overlapResult = await _validateOverlap(visit);

    return overlapResult.fold((failure) => Left(failure), (validationResult) async {
      if (validationResult.hasOverlap) {
        return Left(
          ValidationFailure(
            message: validationResult.message ?? 'Visit overlaps with existing visit',
          ),
        );
      }

      // Step 3: Create the visit
      return _repository.createVisit(visit);
    });
  }
}
