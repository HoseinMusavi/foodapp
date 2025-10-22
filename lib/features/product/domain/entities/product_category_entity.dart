// lib/features/product/domain/entities/product_category_entity.dart
import 'package:equatable/equatable.dart';

class ProductCategoryEntity extends Equatable {
  final int id;
  final int storeId;
  final String name;
  final int? sortOrder;

  const ProductCategoryEntity({
    required this.id,
    required this.storeId,
    required this.name,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [id, storeId, name];
}