// lib/features/cart/data/models/cart_model.dart

import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  // ✨ فیکس: items باید از نوع CartItemModel باشد نه CartItemEntity
  const CartModel({required List<CartItemModel> items}) : super(items: items);

  // ✨ فیکس: (رفع خطای ۱)
  // متد factory fromJson که استفاده نمی‌شد و خطا داشت، حذف شد.
}