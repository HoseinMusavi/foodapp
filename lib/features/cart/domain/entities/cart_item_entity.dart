// lib/features/cart/domain/entities/cart_item_entity.dart

import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({required this.product, required this.quantity});

  // یک getter برای محاسبه قیمت کل این آیتم (قیمت محصول * تعداد)
  double get totalPrice => product.price * quantity;

  @override
  List<Object?> get props => [product, quantity];
}
