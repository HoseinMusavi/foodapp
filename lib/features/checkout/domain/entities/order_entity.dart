// lib/features/checkout/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';
import '../../../customer/domain/entities/address_entity.dart'; // ایمپورت آدرس
import 'order_item_entity.dart'; // ایمپورت آیتم سفارش

// ما از enum خود بک‌اند برای وضعیت سفارش استفاده می‌کنیم
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready_for_pickup,
  delivering,
  delivered,
  cancelled,
  unknown // برای مدیریت خطاهای احتمالی
}

class OrderEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String customerId;
  final int storeId;
  final int addressId;
  final double subtotalPrice;
  final double deliveryFee;
  final double discountAmount;
  final double totalPrice;
  final OrderStatus status; // <-- استفاده از enum
  final String? notes;

  // آبجکت‌های کامل که می‌توانیم با JOIN دریافت کنیم
  final List<OrderItemEntity> items;
  final AddressEntity? address;
  // final StoreEntity? store; // (اختیاری، اگر نیاز بود)

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.customerId,
    required this.storeId,
    required this.addressId,
    required this.subtotalPrice,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.items = const [],
    this.address,
  });

  @override
  List<Object?> get props => [id, status, items];
}