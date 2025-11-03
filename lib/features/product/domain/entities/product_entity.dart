

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final int storeId;
  final String? storeName; // <-- ۱. اضافه شد
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final int? categoryId;
  final String? categoryName;
  final bool isAvailable;

  const ProductEntity({
    required this.id,
    required this.storeId,
    this.storeName, // <-- ۲. اضافه شد
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
  List<Object?> get props => [id, storeId, name, categoryId, storeName]; // <-- ۳. اضافه شد

  // متد copyWith شما از قبل `storeName` را داشت که عالی است
  ProductEntity copyWith({
      int? id,
      int? storeId,
      String? storeName,
      String? name,
      String? description,
      double? price,
      double? discountPrice,
      String? imageUrl,
      int? categoryId,
      String? categoryName,
      bool? isAvailable}) {
    return ProductEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName, // <-- اطمینان از وجود
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