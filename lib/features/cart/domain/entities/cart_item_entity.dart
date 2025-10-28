// lib/features/cart/domain/entities/cart_item_entity.dart

import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/option_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  // ✨ اضافه شد: ID منحصر به فرد این آیتم در سبد خرید (نه ID محصول)
  final int id;
  final ProductEntity product;
  final int quantity;
  // ✨ اضافه شد: لیستی از آپشن‌های انتخاب شده برای این آیتم
  final List<OptionEntity> selectedOptions;

  const CartItemEntity({
    required this.id, // ✨ اضافه شد
    required this.product,
    required this.quantity,
    this.selectedOptions = const [], // ✨ اضافه شد (با مقدار پیش‌فرض خالی)
  });

  // Helper getter for total price of this item (product + options) * quantity
  double get totalPrice {
     // محاسبه قیمت پایه محصول
    double basePrice = product.discountPrice ?? product.price;
    // محاسبه مجموع قیمت آپشن‌ها
    double optionsPrice = selectedOptions.fold(
        0.0, (sum, option) => sum + option.priceDelta);
    // قیمت نهایی یک واحد
    double singleItemPrice = basePrice + optionsPrice;
    // قیمت کل ضربدر تعداد
    return singleItemPrice * quantity;
  }

  @override
  // ✨ اضافه شد: id و selectedOptions به props
  List<Object> get props => [id, product, quantity, selectedOptions];
}