import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit.freezed.dart';
part 'visit.g.dart';

@freezed
abstract class Visit with _$Visit {
  const factory Visit({
    required String id,
    required String countryCode,
    String? countryName,
    String? city,
    required DateTime startDate,
    DateTime? endDate,
    required double latitude,
    required double longitude,
    required bool overnightOnly,
    required bool isActive,
    required DateTime lastUpdated,
  }) = _Visit;

  factory Visit.fromJson(Map<String, dynamic> json) => _$VisitFromJson(json);
}
