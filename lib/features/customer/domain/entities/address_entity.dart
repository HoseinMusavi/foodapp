// lib/features/customer/domain/entities/address_entity.dart
import 'package:equatable/equatable.dart';
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت کلاس جدید

class AddressEntity extends Equatable {
  final int id;
  final String title;
  final String fullAddress;
  final String? postalCode; // <-- تغییر: اختیاری شد
  final String? city;       // <-- تغییر: اختیاری شد
  final LatLng? location;   // <-- جدید: موقعیت مکانی

  const AddressEntity({
    required this.id,
    required this.title,
    required this.fullAddress,
    this.postalCode,
    this.city,
    this.location,
  });

  @override
  List<Object?> get props => [id, title, fullAddress, postalCode, city, location];
}