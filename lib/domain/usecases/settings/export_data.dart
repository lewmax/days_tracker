import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/export_service.dart';
import 'package:injectable/injectable.dart';

/// Use case for exporting all app data to JSON format.
///
/// Returns the JSON string that can be saved to a file.
@lazySingleton
class ExportData {
  final ExportService _exportService;

  ExportData(this._exportService);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or JSON string on success.
  Future<Either<Failure, String>> call() {
    return _exportService.exportToJson();
  }
}
