// lib/features/cart/domain/entities/cart_entity.dart

import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  // ✨ فیکس: کانستراکتور آپدیت شد (دیگر id نمی‌خواهد)
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  // Helper to get total price of the entire cart
  double get totalPrice {
    // ✨ فیکس: (رفع خطای ۶) از 'item.totalPrice' استفاده شد
    return items.fold(
        0.0, (sum, item) => sum + item.totalPrice);
  }

  // Helper to get total number of items
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  List<Object> get props => [items];
}