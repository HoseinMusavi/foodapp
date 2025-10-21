// lib/features/checkout/domain/entities/order_entity.dart

import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class OrderEntity extends Equatable {
  final String id; // شناسه منحصر به فرد سفارش
  final List<CartItemEntity> items; // لیست محصولات سفارش داده شده
  final double totalPrice; // قیمت نهایی
  final DateTime orderDate; // تاریخ ثبت سفارش
  final String status; // وضعیت سفارش (مثلا: در حال پردازش)

  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
  });

  @override
  List<Object?> get props => [id, items, totalPrice, orderDate, status];
}
