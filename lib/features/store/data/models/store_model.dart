// lib/features/store/data/models/store_model.dart
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت کلاس جدید
import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.address,
    required super.logoUrl,
    required super.isOpen,
    required super.rating,
    required super.ratingCount,
    required super.cuisineType,
    required super.deliveryTimeEstimate,
    super.location,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    // از همان تابع کمکی پارس کردن موقعیت استفاده می‌کنیم
    LatLng? parseLocation(dynamic loc) {
      if (loc == null) return null;
      try {
        if (loc is String && loc.contains('POINT')) {
          final parts = loc.split('(')[1].split(')')[0].split(' ');
          final lon = double.parse(parts[0]);
          final lat = double.parse(parts[1]);
          return LatLng(latitude: lat, longitude: lon);
        }
        if (loc is Map<String, dynamic>) {
          return LatLng.fromGeoJson(loc);
        }
      } catch (e) {
        return null;
      }
      return null;
    }

    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? 'آدرس نامشخص',
      logoUrl: json['logo_url'] as String? ?? '',
      isOpen: json['is_open'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0, // <-- تغییر: پیش‌فرض 0
      ratingCount: json['rating_count'] as int? ?? 0,
      cuisineType: json['cuisine_type'] as String? ?? 'متفرقه',
      deliveryTimeEstimate:
          json['delivery_time_estimate'] as String? ?? 'نامشخص',
      location: parseLocation(json['location']), // <-- جدید
    );
  }

  // ... متد toJson اگر نیاز بود ...
}