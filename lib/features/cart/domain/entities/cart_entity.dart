// lib/features/cart/domain/entities/cart_entity.dart

import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({
    this.items = const [],
  }); // به صورت پیش‌فرض، لیست آیتم‌ها خالی است

  // یک getter برای محاسبه قیمت کل سبد خرید
  double get totalPrice {
    if (items.isEmpty) {
      return 0;
    }
    // قیمت کل هر آیتم را با هم جمع می‌زنیم
    return items.map((item) => item.totalPrice).reduce((a, b) => a + b);
  }

  // یک getter برای محاسبه تعداد کل آیتم‌ها در سبد
  int get totalItems {
    if (items.isEmpty) {
      return 0;
    }
    return items.map((item) => item.quantity).reduce((a, b) => a + b);
  }

  @override
  List<Object?> get props => [items];
}
