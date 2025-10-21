// lib/features/product/domain/entities/product_entity.dart

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final int storeId;
  final String? storeName; // <<< CHANGE: Made this nullable (optional)
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  const ProductEntity({
    required this.id,
    required this.storeId,
    this.storeName, // <<< CHANGE: No longer required
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
  });

  double get finalPrice => discountPrice ?? price;

  @override
  List<Object?> get props => [id, storeId, name];

  // Helper method to create a copy with new values
  ProductEntity copyWith({
    int? id,
    int? storeId,
    String? storeName,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    String? category,
    bool? isAvailable,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
