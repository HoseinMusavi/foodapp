// lib/features/checkout/data/models/order_item_model.dart
import '../../domain/entities/order_item_entity.dart';
import 'order_item_option_model.dart'; // <-- ایمپورت فایل بالا

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.quantity,
    required super.priceAtPurchase,
    required super.productName,
    required super.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // پارس کردن لیست آپشن‌های تودرتو
    final optionsList = (json['order_item_options'] as List<dynamic>?)
            ?.map((optionJson) => OrderItemOptionModel.fromJson(
                optionJson as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderItemModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      productName: json['product_name'] as String,
      options: optionsList,
    );
  }
}