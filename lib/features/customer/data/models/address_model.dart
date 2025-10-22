// lib/features/customer/data/models/address_model.dart
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت کلاس جدید
import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.title,
    required super.fullAddress,
    super.postalCode,
    super.city,
    super.location,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // تابع کمکی برای پارس کردن موقعیت مکانی از سوپابیس
    LatLng? parseLocation(dynamic loc) {
      if (loc == null) return null;
      try {
        // PostGIS معمولاً موقعیت را به این شکل برمی‌گرداند
        // "SRID=4326;POINT(35.7 51.3)"
        // ما باید آن را پارس کنیم
        if (loc is String && loc.contains('POINT')) {
          final parts = loc.split('(')[1].split(')')[0].split(' ');
          final lon = double.parse(parts[0]);
          final lat = double.parse(parts[1]);
          return LatLng(latitude: lat, longitude: lon);
        }
        // یا اگر به صورت GeoJSON Map بود
        if (loc is Map<String, dynamic>) {
          return LatLng.fromGeoJson(loc);
        }
      } catch (e) {
        // در صورت خطا، موقعیت را نادیده بگیر
        return null;
      }
      return null;
    }

    return AddressModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'بدون عنوان',
      fullAddress: json['full_address'] as String? ?? 'بدون آدرس',
      postalCode: json['postal_code'] as String?,
      city: json['city'] as String?,
      location: parseLocation(json['location']), // <-- جدید: پارس کردن موقعیت
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // معمولاً آیدی را در زمان ساخت (insert) ارسال نمی‌کنیم
      'title': title,
      'full_address': fullAddress,
      'postal_code': postalCode,
      'city': city,
      // سوپابیس برای نوشتن موقعیت، فرمت خاصی می‌خواهد
      // "POINT(long lat)"
      'location': location != null
          ? 'SRID=4326;POINT(${location!.longitude} ${location!.latitude})'
          : null,
    };
  }
}