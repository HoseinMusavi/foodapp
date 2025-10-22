// lib/features/product/data/models/product_category_model.dart
import '../../domain/entities/product_category_entity.dart';

class ProductCategoryModel extends ProductCategoryEntity {
  const ProductCategoryModel({
    required super.id,
    required super.storeId,
    required super.name,
    super.sortOrder,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'name': name,
      'sort_order': sortOrder,
    };
  }
}