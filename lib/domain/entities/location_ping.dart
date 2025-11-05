import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_ping.freezed.dart';
part 'location_ping.g.dart';

@freezed
abstract class LocationPing with _$LocationPing {
  const factory LocationPing({
    required String id,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    double? accuracy,
    String? city,
    String? countryCode,
    String? source,
    @Default(false) bool geocodingPending,
  }) = _LocationPing;

  factory LocationPing.fromJson(Map<String, dynamic> json) =>
      _$LocationPingFromJson(json);
}
