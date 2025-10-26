// lib/features/cart/data/models/cart_item_model.dart

import '../../../product/domain/entities/option_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id, // ✨ اضافه شد
    required super.product,
    required super.quantity,
    required super.selectedOptions, // ✨ اضافه شد
  });

  // ✨ فیکس: این متد (خطای ۱۹) آپدیت شد تا آپشن‌ها را بپذیرد
  factory CartItemModel.fromSupabase(
    Map<String, dynamic> data,
    ProductEntity product,
    List<OptionEntity> selectedOptions, // ✨ اضافه شد
  ) {
    return CartItemModel(
      id: data['id'] as int, // ✨ اضافه شد: ID از جدول cart_items
      product: product,
      quantity: data['quantity'] as int,
      selectedOptions: selectedOptions, // ✨ اضافه شد
    );
  }
}