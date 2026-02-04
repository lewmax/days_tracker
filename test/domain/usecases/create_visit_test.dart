import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/create_visit.dart';
import 'package:days_tracker/domain/usecases/visits/validate_visit_overlap.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple mock implementation of VisitsRepository for testing.
class MockVisitsRepository implements VisitsRepository {
  bool _createCalled = false;
  Failure? _createFailure;

  bool get createCalled => _createCalled;
  void setCreateFailure(Failure? failure) => _createFailure = failure;

  @override
  Future<Either<Failure, void>> createVisit(Visit visit) async {
    _createCalled = true;
    if (_createFailure != null) return Left(_createFailure!);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> hasOverlap(Visit visit) async => const Right(false);

  @override
  Future<Either<Failure, List<Visit>>> getAllVisits() async => const Right([]);

  @override
  Future<Either<Failure, Visit>> getVisitById(String id) async =>
      const Left(NotFoundFailure(message: 'Not found'));

  @override
  Future<Either<Failure, Visit?>> getActiveVisit() async => const Right(null);

  @override
  Future<Either<Failure, void>> updateVisit(Visit visit) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteVisit(String id) async => const Right(null);

  @override
  Stream<List<Visit>> watchVisits() => Stream.value([]);
}

/// Simple mock implementation of ValidateVisitOverlap for testing.
class MockValidateVisitOverlap {
  OverlapValidationResult _result = const OverlapValidationResult.noOverlap();
  Failure? _failure;
  bool _called = false;

  bool get called => _called;
  void setResult(OverlapValidationResult result) => _result = result;
  void setFailure(Failure? failure) => _failure = failure;

  Future<Either<Failure, OverlapValidationResult>> call(Visit visit) async {
    _called = true;
    if (_failure != null) return Left(_failure!);
    return Right(_result);
  }
}

void main() {
  late MockVisitsRepository mockRepository;

  setUp(() {
    mockRepository = MockVisitsRepository();
  });

  final testVisit = Visit(
    id: 'visit-1',
    cityId: 1,
    startDate: DateTime.utc(2026),
    endDate: DateTime.utc(2026, 1, 10),
    isActive: false,
    source: VisitSource.manual,
    lastUpdated: DateTime.utc(2026, 1, 10),
  );

  group('CreateVisit', () {
    test('should create visit when no overlap', () async {
      // Arrange
      final useCase = CreateVisit(mockRepository, ValidateVisitOverlap(mockRepository));

      // Act
      final result = await useCase(CreateVisitParams(visit: testVisit));

      // Assert
      expect(result.isRight(), true);
      expect(mockRepository.createCalled, true);
    });

    test('should fail when dates are invalid (start after end)', () async {
      // Arrange
      final useCase = CreateVisit(mockRepository, ValidateVisitOverlap(mockRepository));

      final invalidVisit = testVisit.copyWith(
        startDate: DateTime.utc(2026, 1, 15),
        endDate: DateTime.utc(2026, 1, 10),
      );

      // Act
      final result = await useCase(CreateVisitParams(visit: invalidVisit));

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('before end date'));
      }, (success) => fail('Expected left but got right'));
    });

    test('should propagate failure from repository create', () async {
      // Arrange
      mockRepository.setCreateFailure(const DatabaseFailure(message: 'Failed to create'));
      final useCase = CreateVisit(mockRepository, ValidateVisitOverlap(mockRepository));

      // Act
      final result = await useCase(CreateVisitParams(visit: testVisit));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (success) => fail('Expected left but got right'),
      );
    });
  });
}
