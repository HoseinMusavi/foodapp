import 'package:customer_app/features/customer/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    super.id,
    required super.customerId,
    required super.title,
    required super.fullAddress,
    super.postalCode,
    super.city,
    required super.latitude,
    required super.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // خواندن موقعیت جغرافیایی از ستون location (که یک Point است)
    // Supabase PostGIS Point را به صورت 'POINT(long lat)' برمیگرداند
    double lat = 0.0;
    double long = 0.0;

    if (json['location'] != null) {
      try {
        // مثال: "POINT(51.5074 0.1278)"
        final parts = json['location']
            .toString()
            .replaceAll('POINT(', '')
            .replaceAll(')', '')
            .split(' ');
        if (parts.length == 2) {
          long = double.parse(parts[0]);
          lat = double.parse(parts[1]);
        }
      } catch (e) {
        // fallback or error
      }
    }

    return AddressModel(
      id: json['id'],
      customerId: json['customer_id'],
      title: json['title'],
      fullAddress: json['full_address'],
      postalCode: json['postal_code'],
      city: json['city'],
      latitude: lat,
      longitude: long,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'title': title,
      'full_address': fullAddress,
      'postal_code': postalCode,
      'city': city,
      // ما مستقیماً lat/long را insert نمیکنیم
      // بلکه از PostGIS ST_MakePoint برای ستون 'location' استفاده میکنیم
      // این کار در remote datasource انجام میشود
    };
  }

  // مپ برای insert که شامل تابع PostGIS است
  Map<String, dynamic> toInsertJson() {
    return {
      'customer_id': customerId,
      'title': title,
      'full_address': fullAddress,
      'postal_code': postalCode,
      'city': city,
      // این تابع PostGIS نقطه جغرافیایی را بر اساس Longitude و Latitude میسازد
      'location': 'POINT($longitude $latitude)',
    };
  }
}