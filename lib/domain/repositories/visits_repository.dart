import 'package:dartz/dartz.dart';

import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';

/// Abstract repository for managing visits.
///
/// This defines the contract for visit operations. The actual implementation
/// is in the data layer.
abstract class VisitsRepository {
  /// Retrieves all visits, optionally with city and country details.
  ///
  /// Returns visits sorted by start date descending (newest first).
  Future<Either<Failure, List<Visit>>> getAllVisits();

  /// Retrieves a single visit by its ID.
  ///
  /// [id] The unique identifier of the visit.
  /// Returns the visit or NotFoundFailure if not found.
  Future<Either<Failure, Visit>> getVisitById(String id);

  /// Retrieves the currently active visit (if any).
  ///
  /// There should only be one active visit at a time.
  /// Returns null wrapped in Right if no active visit exists.
  Future<Either<Failure, Visit?>> getActiveVisit();

  /// Creates a new visit.
  ///
  /// [visit] The visit to create.
  /// Returns ValidationFailure if the visit overlaps with existing visits.
  Future<Either<Failure, void>> createVisit(Visit visit);

  /// Updates an existing visit.
  ///
  /// [visit] The visit with updated fields.
  /// Returns ValidationFailure if the update would cause an overlap.
  Future<Either<Failure, void>> updateVisit(Visit visit);

  /// Deletes a visit by its ID.
  ///
  /// [id] The unique identifier of the visit to delete.
  /// This also cascades to delete associated daily_presence records.
  Future<Either<Failure, void>> deleteVisit(String id);

  /// Checks if a visit would overlap with existing visits.
  ///
  /// [visit] The visit to check for overlaps.
  /// Returns true if there's an overlap, false otherwise.
  Future<Either<Failure, bool>> hasOverlap(Visit visit);

  /// Watches all visits for changes (reactive stream).
  ///
  /// Emits the full list of visits whenever any change occurs.
  Stream<List<Visit>> watchVisits();
}
