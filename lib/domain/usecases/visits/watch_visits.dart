import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for watching visits changes in real-time.
///
/// Returns a stream that emits whenever visits are added, updated, or deleted.
@lazySingleton
class WatchVisits {
  final VisitsRepository _repository;

  WatchVisits(this._repository);

  /// Executes the use case.
  ///
  /// Returns a [Stream] of [List<Visit>] that emits on changes.
  Stream<List<Visit>> call() {
    return _repository.watchVisits();
  }
}
