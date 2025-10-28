// lib/features/product/data/models/product_model.dart

import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.description,
    required super.price,
    super.discountPrice,
    required super.imageUrl,
    // ✨ --- فیکس نهایی خطا ---
    // اضافه کردن مقدار پیش‌فرض برای پارامتر غیر-قابل-null
    super.isAvailable = true,
    super.categoryId,
    super.storeName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String,
      // این بخش از قبل درست بود و مقدار پیش‌فرض را مدیریت می‌کرد
      isAvailable: json['is_available'] as bool? ?? true,
      categoryId: json['category_id'] as int?,
      storeName: json['storeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'category_id': categoryId,
    };
  }
}