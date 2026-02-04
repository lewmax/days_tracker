import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

/// Use case for clearing all data from the database.
///
/// This is a destructive operation that cannot be undone.
@lazySingleton
class ClearAllData {
  final AppDatabase _database;

  ClearAllData(this._database);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call() async {
    try {
      await _database.clearAllData();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to clear data: $e'));
    }
  }
}
