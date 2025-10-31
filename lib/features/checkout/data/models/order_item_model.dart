// lib/features/checkout/data/models/order_item_model.dart

import 'package:customer_app/features/checkout/data/models/order_item_option_model.dart';
import 'package:customer_app/features/checkout/domain/entities/order_item_entity.dart';

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
    
    // ****** 1. این بخش اضافه شد (برای خواندن آپشن‌ها) ******
    List<OrderItemOptionModel> optionsList = [];
    if (json['order_item_options'] != null) {
      optionsList = (json['order_item_options'] as List)
          .map((optionJson) => OrderItemOptionModel.fromJson(optionJson))
          .toList();
    }
    // ****** پایان بخش اضافه شده ******

    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      productName: json['product_name'],
      options: optionsList, // <-- ** 2. آپشن‌ها اینجا پاس داده شد **
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'product_name': productName,
      // 'options': options.map((o) => (o as OrderItemOptionModel).toJson()).toList(), // فعلا نیازی نیست
    };
  }
}