import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/validate_visit_overlap.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple mock implementation of VisitsRepository for testing.
class MockVisitsRepository implements VisitsRepository {
  bool _hasOverlapResult = false;
  Failure? _failure;

  void setHasOverlapResult(bool value) => _hasOverlapResult = value;
  void setFailure(Failure? failure) => _failure = failure;

  @override
  Future<Either<Failure, bool>> hasOverlap(Visit visit) async {
    if (_failure != null) return Left(_failure!);
    return Right(_hasOverlapResult);
  }

  @override
  Future<Either<Failure, List<Visit>>> getAllVisits() async => const Right([]);

  @override
  Future<Either<Failure, Visit>> getVisitById(String id) async =>
      const Left(NotFoundFailure(message: 'Not found'));

  @override
  Future<Either<Failure, Visit?>> getActiveVisit() async => const Right(null);

  @override
  Future<Either<Failure, void>> createVisit(Visit visit) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateVisit(Visit visit) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteVisit(String id) async => const Right(null);

  @override
  Stream<List<Visit>> watchVisits() => Stream.value([]);
}

void main() {
  late ValidateVisitOverlap useCase;
  late MockVisitsRepository mockRepository;

  setUp(() {
    mockRepository = MockVisitsRepository();
    useCase = ValidateVisitOverlap(mockRepository);
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

  group('ValidateVisitOverlap', () {
    test('should return no overlap when repository returns false', () async {
      // Arrange
      mockRepository.setHasOverlapResult(false);

      // Act
      final result = await useCase(testVisit);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected right but got left'), (validationResult) {
        expect(validationResult.hasOverlap, false);
        expect(validationResult.message, null);
      });
    });

    test('should return overlap when repository returns true', () async {
      // Arrange
      mockRepository.setHasOverlapResult(true);

      // Act
      final result = await useCase(testVisit);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected right but got left'), (validationResult) {
        expect(validationResult.hasOverlap, true);
        expect(validationResult.message, isNotNull);
      });
    });

    test('should return overlap when start date is after end date', () async {
      // Arrange
      final invalidVisit = Visit(
        id: 'visit-2',
        cityId: 1,
        startDate: DateTime.utc(2026, 1, 15),
        endDate: DateTime.utc(2026, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2026, 1, 10),
      );

      // Act
      final result = await useCase(invalidVisit);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected right but got left'), (validationResult) {
        expect(validationResult.hasOverlap, true);
        expect(validationResult.message, 'Start date cannot be after end date');
      });
    });

    test('should propagate failure from repository', () async {
      // Arrange
      mockRepository.setFailure(const DatabaseFailure(message: 'Database error'));

      // Act
      final result = await useCase(testVisit);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (validationResult) => fail('Expected left but got right'),
      );
    });

    test('should handle active visit with null end date', () async {
      // Arrange
      final activeVisit = Visit(
        id: 'visit-3',
        cityId: 1,
        startDate: DateTime.utc(2026),
        isActive: true,
        source: VisitSource.auto,
        lastUpdated: DateTime.utc(2026, 1, 5),
      );

      mockRepository.setHasOverlapResult(false);

      // Act
      final result = await useCase(activeVisit);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected right but got left'), (validationResult) {
        expect(validationResult.hasOverlap, false);
      });
    });
  });
}
