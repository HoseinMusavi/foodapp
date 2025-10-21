// lib/features/store/data/models/store_model.dart

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
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? 'آدرس نامشخص',
      logoUrl: json['logo_url'] as String,
      isOpen: json['is_open'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      ratingCount: json['rating_count'] as int? ?? 0,
      cuisineType: json['cuisine_type'] as String? ?? 'فست فود',
      deliveryTimeEstimate:
          json['delivery_time_estimate'] as String? ?? '۲۰-۳۰ دقیقه',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'logo_url': logoUrl,
      'is_open': isOpen,
      'rating': rating,
      'rating_count': ratingCount,
      'cuisine_type': cuisineType,
      'delivery_time_estimate': deliveryTimeEstimate,
    };
  }
}
