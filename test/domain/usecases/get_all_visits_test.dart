import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/get_all_visits.dart';
import 'package:flutter_test/flutter_test.dart';

class MockVisitsRepository implements VisitsRepository {
  Either<Failure, List<Visit>>? resultToReturn;
  Failure? failureToReturn;

  void setResult(List<Visit> visits) {
    resultToReturn = Right(visits);
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
    resultToReturn = null;
  }

  @override
  Future<Either<Failure, List<Visit>>> getAllVisits() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return resultToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetAllVisits', () {
    late GetAllVisits useCase;
    late MockVisitsRepository mockRepository;

    setUp(() {
      mockRepository = MockVisitsRepository();
      useCase = GetAllVisits(mockRepository);
    });

    final testVisits = [
      Visit(
        id: 'visit-1',
        cityId: 1,
        startDate: DateTime.utc(2026, 1, 1),
        endDate: DateTime.utc(2026, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2026, 1, 10),
      ),
      Visit(
        id: 'visit-2',
        cityId: 2,
        startDate: DateTime.utc(2026, 1, 15),
        isActive: true,
        source: VisitSource.auto,
        lastUpdated: DateTime.utc(2026, 1, 20),
      ),
    ];

    test('should return list of visits when successful', () async {
      mockRepository.setResult(testVisits);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold((failure) => fail('Should not return failure'), (visits) {
        expect(visits.length, 2);
        expect(visits[0].id, 'visit-1');
        expect(visits[1].id, 'visit-2');
      });
    });

    test('should return empty list when no visits exist', () async {
      mockRepository.setResult([]);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (visits) => expect(visits, isEmpty),
      );
    });

    test('should return failure when repository fails', () async {
      mockRepository.setFailure(const DatabaseFailure(message: 'Database error'));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<DatabaseFailure>());
        expect((failure as DatabaseFailure).message, 'Database error');
      }, (visits) => fail('Should not return visits'));
    });
  });
}
