// lib/features/checkout/data/models/order_model.dart
import '../../../customer/data/models/address_model.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.createdAt,
    required super.customerId,
    required super.storeId,
    required super.addressId,
    required super.subtotalPrice,
    required super.deliveryFee,
    required super.discountAmount,
    required super.totalPrice,
    required super.status,
    super.notes,
    required super.items,
    super.address,
  });

  // تابع کمکی برای تبدیل رشته وضعیت به enum
  static OrderStatus _parseStatus(String statusStr) {
    try {
      return OrderStatus.values.firstWhere((e) => e.name == statusStr);
    } catch (e) {
      return OrderStatus.unknown;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // پارس کردن آیتم‌های سفارش (اگر JOIN شده باشند)
    final itemsList = (json['order_items'] as List<dynamic>?)
            ?.map((itemJson) =>
                OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
            .toList() ??
        [];

    // پارس کردن آدرس (اگر JOIN شده باشد)
    final addressData = json['addresses'];
    final address = addressData != null
        ? AddressModel.fromJson(addressData as Map<String, dynamic>)
        : null;

    return OrderModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      customerId: json['customer_id'] as String,
      storeId: json['store_id'] as int,
      addressId: json['address_id'] as int,
      subtotalPrice: (json['subtotal_price'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      notes: json['notes'] as String?,
      items: itemsList,
      address: address,
    );
  }
}