// lib/features/checkout/domain/entities/order_item_entity.dart
import 'package:equatable/equatable.dart';
import 'order_item_option_entity.dart'; // <-- ایمپورت فایل بالا

class OrderItemEntity extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceAtPurchase; // قیمت نهایی محصول + آپشن‌ها در لحظه خرید
  final String productName;
  final List<OrderItemOptionEntity> options; // لیست آپشن‌های انتخاب شده

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.productName,
    this.options = const [],
  });

  @override
  List<Object?> get props => [id, orderId, productId, quantity, options];
}