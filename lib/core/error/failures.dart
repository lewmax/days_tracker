import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent business logic errors that can be handled gracefully.
/// Each failure type should extend this class and provide a meaningful message.
abstract class Failure extends Equatable {
  /// Human-readable error message.
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure related to database operations.
///
/// Use this for SQLite/Drift errors like query failures, constraint violations, etc.
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message);
}

/// Failure related to network operations.
///
/// Use this for HTTP errors, timeouts, no internet connection, etc.
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message);
}

/// Failure related to geocoding operations.
///
/// Use this when reverse geocoding fails or returns no results.
class GeocodingFailure extends Failure {
  const GeocodingFailure({required String message}) : super(message);
}

/// Failure related to validation errors.
///
/// Use this for business rule violations like overlapping visits.
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}

/// Failure related to permission errors.
///
/// Use this when location permission is denied or restricted.
class PermissionFailure extends Failure {
  const PermissionFailure({required String message}) : super(message);
}

/// Failure related to location services.
///
/// Use this when GPS is disabled or location cannot be obtained.
class LocationFailure extends Failure {
  const LocationFailure({required String message}) : super(message);
}

/// Failure related to storage operations.
///
/// Use this for file I/O errors, secure storage errors, etc.
class StorageFailure extends Failure {
  const StorageFailure({required String message}) : super(message);
}

/// Failure when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message);
}

/// Failure for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required String message}) : super(message);
}
