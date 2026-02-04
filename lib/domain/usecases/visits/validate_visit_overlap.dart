import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Result of visit overlap validation.
class OverlapValidationResult {
  /// Whether there is an overlap with existing visits.
  final bool hasOverlap;

  /// Message describing the overlap, if any.
  final String? message;

  const OverlapValidationResult({required this.hasOverlap, this.message});

  /// Creates a result indicating no overlap.
  const OverlapValidationResult.noOverlap() : hasOverlap = false, message = null;

  /// Creates a result indicating an overlap.
  const OverlapValidationResult.overlap(String overlapMessage)
    : hasOverlap = true,
      message = overlapMessage;
}

/// Use case for validating if a visit overlaps with existing visits.
///
/// This is a critical validation that prevents users from creating
/// visits with overlapping date ranges in the same city.
@lazySingleton
class ValidateVisitOverlap {
  final VisitsRepository _repository;

  ValidateVisitOverlap(this._repository);

  /// Executes the use case.
  ///
  /// [visit] The visit to validate for overlaps.
  /// Returns [Either] with [Failure] on error or [OverlapValidationResult] on success.
  Future<Either<Failure, OverlapValidationResult>> call(Visit visit) async {
    // Validate input
    if (visit.startDate.isAfter(visit.endDate ?? DateTime.now().toUtc())) {
      return const Right(OverlapValidationResult.overlap('Start date cannot be after end date'));
    }

    final result = await _repository.hasOverlap(visit);

    return result.fold((failure) => Left(failure), (hasOverlap) {
      if (hasOverlap) {
        return const Right(
          OverlapValidationResult.overlap('This visit overlaps with an existing visit'),
        );
      }
      return const Right(OverlapValidationResult.noOverlap());
    });
  }
}
