import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/enums/visits_view_mode.dart';
import 'package:days_tracker/domain/usecases/visits/create_visit.dart';
import 'package:days_tracker/domain/usecases/visits/delete_visit.dart';
import 'package:days_tracker/domain/usecases/visits/get_active_visit.dart';
import 'package:days_tracker/domain/usecases/visits/get_all_visits.dart';
import 'package:days_tracker/domain/usecases/visits/update_visit.dart';
import 'package:days_tracker/domain/usecases/visits/watch_visits.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_bloc.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_event.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_state.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock implementations
class MockGetAllVisits implements GetAllVisits {
  Either<Failure, List<Visit>>? resultToReturn;

  void setResult(List<Visit> visits) {
    resultToReturn = Right(visits);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, List<Visit>>> call() async {
    return resultToReturn!;
  }
}

class MockGetActiveVisit implements GetActiveVisit {
  Either<Failure, Visit?>? resultToReturn;

  void setResult(Visit? visit) {
    resultToReturn = Right(visit);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, Visit?>> call() async {
    return resultToReturn!;
  }
}

class MockCreateVisit implements CreateVisit {
  Either<Failure, void>? resultToReturn;
  CreateVisitParams? lastParams;

  void setSuccess() {
    resultToReturn = const Right(null);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, void>> call(CreateVisitParams params) async {
    lastParams = params;
    return resultToReturn!;
  }
}

class MockUpdateVisit implements UpdateVisit {
  Either<Failure, void>? resultToReturn;

  void setSuccess() {
    resultToReturn = const Right(null);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, void>> call(UpdateVisitParams params) async {
    return resultToReturn!;
  }
}

class MockDeleteVisit implements DeleteVisit {
  Either<Failure, void>? resultToReturn;

  void setSuccess() {
    resultToReturn = const Right(null);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, void>> call(String id) async {
    return resultToReturn!;
  }
}

class MockWatchVisits implements WatchVisits {
  @override
  Stream<List<Visit>> call() {
    return const Stream.empty();
  }
}

void main() {
  group('VisitsBloc', () {
    late MockGetAllVisits mockGetAllVisits;
    late MockGetActiveVisit mockGetActiveVisit;
    late MockCreateVisit mockCreateVisit;
    late MockUpdateVisit mockUpdateVisit;
    late MockDeleteVisit mockDeleteVisit;
    late MockWatchVisits mockWatchVisits;

    const testCountry = Country(id: 1, countryCode: 'PL', countryName: 'Poland');

    const testCity = City(
      id: 1,
      countryId: 1,
      cityName: 'Warsaw',
      latitude: 52.2297,
      longitude: 21.0122,
      country: testCountry,
    );

    final testVisit1 = Visit(
      id: 'visit-1',
      cityId: 1,
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 1, 10),
      isActive: false,
      source: VisitSource.manual,
      lastUpdated: DateTime.utc(2026, 1, 10),
      city: testCity,
    );

    final testVisit2 = Visit(
      id: 'visit-2',
      cityId: 1,
      startDate: DateTime.utc(2026, 1, 15),
      isActive: true,
      source: VisitSource.manual,
      lastUpdated: DateTime.utc(2026, 1, 20),
      city: testCity,
    );

    setUp(() {
      mockGetAllVisits = MockGetAllVisits();
      mockGetActiveVisit = MockGetActiveVisit();
      mockCreateVisit = MockCreateVisit();
      mockUpdateVisit = MockUpdateVisit();
      mockDeleteVisit = MockDeleteVisit();
      mockWatchVisits = MockWatchVisits();
    });

    VisitsBloc createBloc() {
      return VisitsBloc(
        mockGetAllVisits,
        mockGetActiveVisit,
        mockCreateVisit,
        mockUpdateVisit,
        mockDeleteVisit,
        mockWatchVisits,
      );
    }

    test('initial state should be VisitsState.initial()', () {
      mockGetAllVisits.setResult([]);
      mockGetActiveVisit.setResult(null);

      final bloc = createBloc();
      expect(bloc.state, const VisitsState.initial());
      bloc.close();
    });

    blocTest<VisitsBloc, VisitsState>(
      'emits [loading, loaded] when loadVisits is added',
      setUp: () {
        mockGetAllVisits.setResult([testVisit1, testVisit2]);
        mockGetActiveVisit.setResult(testVisit2);
      },
      build: createBloc,
      act: (bloc) => bloc.add(const VisitsEvent.loadVisits()),
      expect: () => [
        const VisitsState.loading(),
        isA<VisitsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.visits.length, orElse: () => -1),
          'visits count',
          2,
        ),
      ],
    );

    blocTest<VisitsBloc, VisitsState>(
      'emits error state when loadVisits fails',
      setUp: () {
        mockGetAllVisits.setFailure(const DatabaseFailure(message: 'DB error'));
        mockGetActiveVisit.setResult(null);
      },
      build: createBloc,
      act: (bloc) => bloc.add(const VisitsEvent.loadVisits()),
      expect: () => [const VisitsState.loading(), const VisitsState.error('DB error')],
    );

    blocTest<VisitsBloc, VisitsState>(
      'emits error when createVisit fails',
      setUp: () {
        mockGetAllVisits.setResult([]);
        mockGetActiveVisit.setResult(null);
        mockCreateVisit.setFailure(const ValidationFailure(message: 'Validation error'));
      },
      build: createBloc,
      seed: () => const VisitsState.loaded(
        visits: [],
        filteredVisits: [],
        viewMode: VisitsViewMode.chronological,
        filterQuery: null,
        activeVisit: null,
      ),
      act: (bloc) => bloc.add(VisitsEvent.createVisit(testVisit1)),
      expect: () => [const VisitsState.error('Validation error')],
    );

    blocTest<VisitsBloc, VisitsState>(
      'emits error when deleteVisit fails',
      setUp: () {
        mockGetAllVisits.setResult([testVisit1]);
        mockGetActiveVisit.setResult(null);
        mockDeleteVisit.setFailure(const NotFoundFailure(message: 'Visit not found'));
      },
      build: createBloc,
      seed: () => VisitsState.loaded(
        visits: [testVisit1],
        filteredVisits: [testVisit1],
        viewMode: VisitsViewMode.chronological,
        filterQuery: null,
        activeVisit: null,
      ),
      act: (bloc) => bloc.add(const VisitsEvent.deleteVisit('visit-1')),
      expect: () => [const VisitsState.error('Visit not found')],
    );

    blocTest<VisitsBloc, VisitsState>(
      'changes view mode correctly',
      setUp: () {
        mockGetAllVisits.setResult([testVisit1, testVisit2]);
        mockGetActiveVisit.setResult(testVisit2);
      },
      build: createBloc,
      seed: () => VisitsState.loaded(
        visits: [testVisit1, testVisit2],
        filteredVisits: [testVisit1, testVisit2],
        viewMode: VisitsViewMode.chronological,
        filterQuery: null,
        activeVisit: testVisit2,
      ),
      act: (bloc) => bloc.add(const VisitsEvent.changeViewMode(VisitsViewMode.activeFirst)),
      expect: () => [
        isA<VisitsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.viewMode, orElse: () => null),
          'view mode',
          VisitsViewMode.activeFirst,
        ),
      ],
    );

    blocTest<VisitsBloc, VisitsState>(
      'filters visits by query',
      setUp: () {
        mockGetAllVisits.setResult([testVisit1, testVisit2]);
        mockGetActiveVisit.setResult(null);
      },
      build: createBloc,
      seed: () => VisitsState.loaded(
        visits: [testVisit1, testVisit2],
        filteredVisits: [testVisit1, testVisit2],
        viewMode: VisitsViewMode.chronological,
        filterQuery: null,
        activeVisit: null,
      ),
      act: (bloc) => bloc.add(const VisitsEvent.filterVisits('Warsaw')),
      expect: () => [
        isA<VisitsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.filterQuery, orElse: () => null),
          'filter query',
          'Warsaw',
        ),
      ],
    );

    blocTest<VisitsBloc, VisitsState>(
      'clears filter correctly',
      setUp: () {
        mockGetAllVisits.setResult([testVisit1, testVisit2]);
        mockGetActiveVisit.setResult(null);
      },
      build: createBloc,
      seed: () => VisitsState.loaded(
        visits: [testVisit1, testVisit2],
        filteredVisits: [testVisit1],
        viewMode: VisitsViewMode.chronological,
        filterQuery: 'test',
        activeVisit: null,
      ),
      act: (bloc) => bloc.add(const VisitsEvent.clearFilter()),
      expect: () => [
        isA<VisitsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.filterQuery, orElse: () => 'not null'),
          'filter query',
          isNull,
        ),
      ],
    );
  });
}
