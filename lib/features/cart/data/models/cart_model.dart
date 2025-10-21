// lib/features/cart/data/models/cart_model.dart

import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({required List<CartItemModel> items}) : super(items: items);

  // This factory can be used if you need to create a CartModel from a list of dynamic JSON objects,
  // but for now, we are constructing it directly from CartItemModels in the repository.
  factory CartModel.fromJson(List<dynamic> json) {
    final items = json
        .map(
          (itemJson) => CartItemModel.fromSupabase(
            itemJson,
            // Note: This simplified fromJson assumes product data is already parsed.
            // In our current implementation, we build this model directly in the repository,
            // which is more efficient.
            itemJson['product'], // This is a placeholder
          ),
        )
        .toList();
    return CartModel(items: items);
  }
}
