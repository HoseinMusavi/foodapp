// lib/features/product/data/models/product_model.dart
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.description,
    required super.price,
    required super.discountPrice,
    required super.imageUrl,
    required super.isAvailable,
    super.categoryId,
    super.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // این بخش برای زمانی است که جدول product_categories را JOIN می‌کنیم
    String? catName;
    if (json['product_categories'] != null &&
        json['product_categories'] is Map) {
      catName = json['product_categories']['name'] as String?;
    }

    return ProductModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as int?, // <-- تغییر
      categoryName: catName, // <-- جدید: از JOIN خوانده می‌شود
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}