// lib/core/utils/lat_lng.dart (NEW FILE)
import 'package:equatable/equatable.dart';

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];

  // (اختیاری) برای ذخیره‌سازی در سوپابیس
  // سوپابیس نقاط جغرافیایی را به صورت GeoJSON می‌خواهد
  Map<String, dynamic> toGeoJson() {
    return {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    };
  }

  // برای خواندن از سوپابیس
  factory LatLng.fromGeoJson(Map<String, dynamic> json) {
    // سوپابیس معمولاً GeoJSON را به صورت رشته برمی‌گرداند که باید parse شود
    // یا اگر مستقیم Map بود
    final coordinates = json['coordinates'] as List;
    return LatLng(
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
    );
  }
}