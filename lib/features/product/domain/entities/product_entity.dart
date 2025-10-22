// lib/features/product/domain/entities/product_entity.dart


import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final int storeId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final int? categoryId; // <-- جدید: جایگزین category شد
  final String? categoryName; // <-- جدید: برای نمایش در UI
  final bool isAvailable;

  // فیلد storeName حذف شد چون در مدل اصلی نبود

  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.isAvailable,
  });

  double get finalPrice => discountPrice ?? price;

  @override
  List<Object?> get props => [id, storeId, name, categoryId];

  // ... متد copyWith ...
  ProductEntity copyWith({
    int? id,
    int? storeId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    bool? isAvailable,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}