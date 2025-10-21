// lib/features/promotion/data/models/promotion_model.dart

import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.imageUrl,
    required super.storeId,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      storeId: json['store_id'] as int?, // Can be null
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image_url': imageUrl, 'store_id': storeId};
  }
}
