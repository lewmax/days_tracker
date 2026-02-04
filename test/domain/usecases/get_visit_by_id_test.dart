import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/get_visit_by_id.dart';
import 'package:flutter_test/flutter_test.dart';

class MockVisitsRepository implements VisitsRepository {
  Either<Failure, Visit>? resultToReturn;
  Failure? failureToReturn;
  String? lastRequestedId;

  void setResult(Visit visit) {
    resultToReturn = Right(visit);
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
    resultToReturn = null;
  }

  @override
  Future<Either<Failure, Visit>> getVisitById(String id) async {
    lastRequestedId = id;
    if (failureToReturn != null) return Left(failureToReturn!);
    return resultToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetVisitById', () {
    late GetVisitById useCase;
    late MockVisitsRepository mockRepository;

    setUp(() {
      mockRepository = MockVisitsRepository();
      useCase = GetVisitById(mockRepository);
    });

    final testVisit = Visit(
      id: 'visit-123',
      cityId: 1,
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 1, 10),
      isActive: false,
      source: VisitSource.manual,
      lastUpdated: DateTime.utc(2026, 1, 10),
    );

    test('should return visit when ID is valid', () async {
      mockRepository.setResult(testVisit);

      final result = await useCase('visit-123');

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not return failure'), (visit) {
        expect(visit.id, 'visit-123');
        expect(visit.cityId, 1);
      });
      expect(mockRepository.lastRequestedId, 'visit-123');
    });

    test('should return ValidationFailure when ID is empty', () async {
      final result = await useCase('');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'Visit ID cannot be empty');
      }, (_) => fail('Should not succeed'));
    });

    test('should return NotFoundFailure when visit does not exist', () async {
      mockRepository.setFailure(const NotFoundFailure(message: 'Visit not found'));

      final result = await useCase('nonexistent-id');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should not succeed'),
      );
    });

    test('should return failure when repository fails', () async {
      mockRepository.setFailure(const DatabaseFailure(message: 'Database error'));

      final result = await useCase('visit-123');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should not succeed'),
      );
    });
  });
}
