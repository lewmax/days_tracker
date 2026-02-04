import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/update_visit.dart';
import 'package:days_tracker/domain/usecases/visits/validate_visit_overlap.dart';
import 'package:flutter_test/flutter_test.dart';

class MockVisitsRepository implements VisitsRepository {
  Either<Failure, void>? updateResultToReturn;
  Failure? failureToReturn;
  Visit? lastUpdatedVisit;

  void setUpdateSuccess() {
    updateResultToReturn = const Right(null);
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
    updateResultToReturn = null;
  }

  @override
  Future<Either<Failure, void>> updateVisit(Visit visit) async {
    lastUpdatedVisit = visit;
    if (failureToReturn != null) return Left(failureToReturn!);
    return updateResultToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidateVisitOverlap implements ValidateVisitOverlap {
  Either<Failure, OverlapValidationResult>? resultToReturn;
  Failure? failureToReturn;

  void setNoOverlap() {
    resultToReturn = const Right(OverlapValidationResult.noOverlap());
    failureToReturn = null;
  }

  void setOverlap(String message) {
    resultToReturn = Right(OverlapValidationResult.overlap(message));
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
    resultToReturn = null;
  }

  @override
  Future<Either<Failure, OverlapValidationResult>> call(Visit visit) async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return resultToReturn!;
  }
}

void main() {
  group('UpdateVisit', () {
    late UpdateVisit useCase;
    late MockVisitsRepository mockRepository;
    late MockValidateVisitOverlap mockValidateOverlap;

    setUp(() {
      mockRepository = MockVisitsRepository();
      mockValidateOverlap = MockValidateVisitOverlap();
      useCase = UpdateVisit(mockRepository, mockValidateOverlap);
    });

    final validVisit = Visit(
      id: 'visit-123',
      cityId: 1,
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 1, 10),
      isActive: false,
      source: VisitSource.manual,
      lastUpdated: DateTime.utc(2026, 1, 10),
    );

    test('should update visit when valid', () async {
      mockValidateOverlap.setNoOverlap();
      mockRepository.setUpdateSuccess();

      final result = await useCase(UpdateVisitParams(visit: validVisit));

      expect(result.isRight(), isTrue);
      expect(mockRepository.lastUpdatedVisit?.id, 'visit-123');
    });

    test('should return ValidationFailure when ID is empty', () async {
      final invalidVisit = Visit(
        id: '',
        cityId: 1,
        startDate: DateTime.utc(2026, 1, 1),
        isActive: true,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2026, 1, 1),
      );

      final result = await useCase(UpdateVisitParams(visit: invalidVisit));

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'Visit ID cannot be empty');
      }, (_) => fail('Should not succeed'));
    });

    test('should return ValidationFailure when start date is after end date', () async {
      final invalidVisit = Visit(
        id: 'visit-123',
        cityId: 1,
        startDate: DateTime.utc(2026, 1, 15),
        endDate: DateTime.utc(2026, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2026, 1, 10),
      );

      final result = await useCase(UpdateVisitParams(visit: invalidVisit));

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'Start date must be before end date');
      }, (_) => fail('Should not succeed'));
    });

    test('should return ValidationFailure when visit overlaps', () async {
      mockValidateOverlap.setOverlap('Overlaps with visit on Jan 5-8');

      final result = await useCase(UpdateVisitParams(visit: validVisit));

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, contains('Overlaps'));
      }, (_) => fail('Should not succeed'));
    });

    test('should return failure when overlap validation fails', () async {
      mockValidateOverlap.setFailure(const DatabaseFailure(message: 'DB error'));

      final result = await useCase(UpdateVisitParams(visit: validVisit));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test('should return failure when repository update fails', () async {
      mockValidateOverlap.setNoOverlap();
      mockRepository.setFailure(const DatabaseFailure(message: 'Update failed'));

      final result = await useCase(UpdateVisitParams(visit: validVisit));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test('should allow visit with null end date (active visit)', () async {
      final activeVisit = Visit(
        id: 'visit-123',
        cityId: 1,
        startDate: DateTime.utc(2026, 1, 1),
        isActive: true,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2026, 1, 10),
      );

      mockValidateOverlap.setNoOverlap();
      mockRepository.setUpdateSuccess();

      final result = await useCase(UpdateVisitParams(visit: activeVisit));

      expect(result.isRight(), isTrue);
    });
  });
}
