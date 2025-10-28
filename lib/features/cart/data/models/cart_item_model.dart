// lib/features/cart/data/models/cart_item_model.dart

import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({required super.product, required super.quantity});

  // --- ✨ THIS IS THE MISSING METHOD ✨ ---
  // This factory constructor knows how to parse the Supabase response
  factory CartItemModel.fromSupabase(
    Map<String, dynamic> data,
    ProductEntity product,
  ) {
    return CartItemModel(product: product, quantity: data['quantity'] as int);
  }
}
