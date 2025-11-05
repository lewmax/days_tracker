import 'package:days_tracker/domain/entities/visit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState.initial() = Initial;
  const factory MapState.loading() = Loading;
  const factory MapState.loaded({
    required List<Visit> visits,
    required Set<String> visitedCountries,
    required Map<String, List<String>> countryCities,
    String? selectedCountry,
    String? selectedCity,
  }) = Loaded;
  const factory MapState.error(String message) = Error;
}
