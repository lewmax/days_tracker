import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/visits/delete_visit.dart';
import 'package:flutter_test/flutter_test.dart';

class MockVisitsRepository implements VisitsRepository {
  Either<Failure, void>? resultToReturn;
  Failure? failureToReturn;
  String? lastDeletedId;

  void setSuccess() {
    resultToReturn = const Right(null);
    failureToReturn = null;
  }

  void setFailure(Failure failure) {
    failureToReturn = failure;
    resultToReturn = null;
  }

  @override
  Future<Either<Failure, void>> deleteVisit(String id) async {
    lastDeletedId = id;
    if (failureToReturn != null) return Left(failureToReturn!);
    return resultToReturn!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DeleteVisit', () {
    late DeleteVisit useCase;
    late MockVisitsRepository mockRepository;

    setUp(() {
      mockRepository = MockVisitsRepository();
      useCase = DeleteVisit(mockRepository);
    });

    test('should delete visit when ID is valid', () async {
      mockRepository.setSuccess();

      final result = await useCase('visit-123');

      expect(result.isRight(), isTrue);
      expect(mockRepository.lastDeletedId, 'visit-123');
    });

    test('should return ValidationFailure when ID is empty', () async {
      final result = await useCase('');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).message, 'Visit ID cannot be empty');
      }, (_) => fail('Should not succeed'));
    });

    test('should return failure when repository fails', () async {
      mockRepository.setFailure(const DatabaseFailure(message: 'Delete failed'));

      final result = await useCase('visit-123');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<DatabaseFailure>());
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
  });
}
