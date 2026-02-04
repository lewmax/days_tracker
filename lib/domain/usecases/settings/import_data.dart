import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/import_service.dart';
import 'package:injectable/injectable.dart';

/// Use case for importing data from a JSON string.
///
/// This operation replaces all existing data with the imported data.
@lazySingleton
class ImportData {
  final ImportService _importService;

  ImportData(this._importService);

  /// Executes the use case.
  ///
  /// [jsonString] The JSON string to import.
  /// Returns [Either] with [Failure] on error or [ImportResult] on success.
  Future<Either<Failure, ImportResult>> call(String jsonString) {
    return _importService.importFromJson(jsonString);
  }
}
