import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/data/mappers/city_mapper.dart';
import 'package:days_tracker/data/mappers/country_mapper.dart';
import 'package:days_tracker/data/mappers/visit_mapper.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementation of [VisitsRepository] using local SQLite database.
@LazySingleton(as: VisitsRepository)
class VisitsRepositoryImpl implements VisitsRepository {
  final VisitsDao _visitsDao;
  final CitiesDao _citiesDao;
  final CountriesDao _countriesDao;
  final DailyPresenceDao _dailyPresenceDao;

  VisitsRepositoryImpl(
    this._visitsDao,
    this._citiesDao,
    this._countriesDao,
    this._dailyPresenceDao,
  );

  @override
  Future<Either<Failure, List<Visit>>> getAllVisits() async {
    try {
      final visitDataList = await _visitsDao.getAll();
      final visits = <Visit>[];

      for (final visitData in visitDataList) {
        final cityData = await _citiesDao.getById(visitData.cityId);
        if (cityData != null) {
          final countryData = await _countriesDao.getById(cityData.countryId);
          final country = countryData?.toEntity();
          final city = cityData.toEntity(country: country);
          visits.add(visitData.toEntity(city: city));
        } else {
          visits.add(visitData.toEntity());
        }
      }

      return Right(visits);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get visits: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitById(String id) async {
    try {
      final visitData = await _visitsDao.getById(id);
      if (visitData == null) {
        return Left(NotFoundFailure(message: 'Visit not found: $id'));
      }

      final cityData = await _citiesDao.getById(visitData.cityId);
      if (cityData != null) {
        final countryData = await _countriesDao.getById(cityData.countryId);
        final country = countryData?.toEntity();
        final city = cityData.toEntity(country: country);
        return Right(visitData.toEntity(city: city));
      }

      return Right(visitData.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get visit: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit?>> getActiveVisit() async {
    try {
      final visitData = await _visitsDao.getActiveVisit();
      if (visitData == null) {
        return const Right(null);
      }

      final cityData = await _citiesDao.getById(visitData.cityId);
      if (cityData != null) {
        final countryData = await _countriesDao.getById(cityData.countryId);
        final country = countryData?.toEntity();
        final city = cityData.toEntity(country: country);
        return Right(visitData.toEntity(city: city));
      }

      return Right(visitData.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get active visit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createVisit(Visit visit) async {
    try {
      // Check for overlaps first
      final hasOverlap = await _visitsDao.hasOverlap(visit.startDate, visit.endDate);

      if (hasOverlap) {
        final overlapping = await _visitsDao.getOverlappingVisit(visit.startDate, visit.endDate);

        String errorMsg = 'This visit overlaps with an existing visit';
        if (overlapping != null) {
          final city = await _citiesDao.getById(overlapping.cityId);
          if (city != null) {
            final country = await _countriesDao.getById(city.countryId);
            errorMsg =
                'This visit overlaps with: ${city.cityName}, '
                '${country?.countryName ?? ""} from ${overlapping.startDate} '
                'to ${overlapping.endDate ?? "present"}';
          }
        }

        return Left(ValidationFailure(message: errorMsg));
      }

      // If there's an active visit and we're creating a new one, close the active one
      if (visit.isActive) {
        final currentActive = await _visitsDao.getActiveVisit();
        if (currentActive != null && currentActive.id != visit.id) {
          await _visitsDao.closeActiveVisit(currentActive.id, DateTime.now().toUtc());
        }
      }

      await _visitsDao.insertVisit(visit.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to create visit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateVisit(Visit visit) async {
    try {
      // Check for overlaps (excluding this visit)
      final hasOverlap = await _visitsDao.hasOverlap(
        visit.startDate,
        visit.endDate,
        excludeId: visit.id,
      );

      if (hasOverlap) {
        return const Left(ValidationFailure(message: 'Visit update would cause overlap'));
      }

      final success = await _visitsDao.updateVisit(visit.toData());
      if (!success) {
        return Left(NotFoundFailure(message: 'Visit not found: ${visit.id}'));
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update visit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVisit(String id) async {
    try {
      // Delete associated daily presence records first
      await _dailyPresenceDao.deleteByVisitId(id);

      // Then delete the visit
      final deleted = await _visitsDao.deleteById(id);
      if (deleted == 0) {
        return Left(NotFoundFailure(message: 'Visit not found: $id'));
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete visit: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasOverlap(Visit visit) async {
    try {
      final overlap = await _visitsDao.hasOverlap(
        visit.startDate,
        visit.endDate,
        excludeId: visit.id,
      );
      return Right(overlap);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to check overlap: $e'));
    }
  }

  @override
  Stream<List<Visit>> watchVisits() {
    return _visitsDao.watchAll().asyncMap((visitDataList) async {
      final visits = <Visit>[];

      for (final visitData in visitDataList) {
        final cityData = await _citiesDao.getById(visitData.cityId);
        if (cityData != null) {
          final countryData = await _countriesDao.getById(cityData.countryId);
          final country = countryData?.toEntity();
          final city = cityData.toEntity(country: country);
          visits.add(visitData.toEntity(city: city));
        } else {
          visits.add(visitData.toEntity());
        }
      }

      return visits;
    });
  }
}
