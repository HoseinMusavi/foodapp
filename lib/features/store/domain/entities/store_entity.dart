// lib/features/store/domain/entities/store_entity.dart

import 'package:equatable/equatable.dart';

import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت کلاس جدید

class StoreEntity extends Equatable {
  final int id;
  final String name;
  final String address;
  final String logoUrl;
  final bool isOpen;
  final double rating;
  final int ratingCount;
  final String cuisineType;
  final String deliveryTimeEstimate;
  final LatLng? location; // <-- جدید: موقعیت مکانی رستوران

  const StoreEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.logoUrl,
    required this.isOpen,
    required this.rating,
    required this.ratingCount,
    required this.cuisineType,
    required this.deliveryTimeEstimate,
    this.location,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        logoUrl,
        isOpen,
        rating,
        location,
      ];
}