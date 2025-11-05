import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_event.freezed.dart';

@freezed
class MapEvent with _$MapEvent {
  const factory MapEvent.loadMapData() = LoadMapData;
  const factory MapEvent.selectCountry(String? countryCode) = SelectCountry;
  const factory MapEvent.selectCity(String? city) = SelectCity;
}
