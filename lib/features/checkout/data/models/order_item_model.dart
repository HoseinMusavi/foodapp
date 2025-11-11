// lib/features/checkout/data/models/order_item_model.dart

import 'package:customer_app/features/checkout/data/models/order_item_option_model.dart';
import 'package:customer_app/features/checkout/domain/entities/order_item_entity.dart';
import 'package:customer_app/features/product/data/models/product_model.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    super.productId, // <-- حالا اختیاری است
    super.product, // <-- حالا اختیاری است
    required super.quantity,
    required super.priceAtPurchase,
    required super.productName,
    required super.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // --- منطق هوشمند جدید (رفع خطای Map/int) ---
    final productData = json['product_id'];
    int? parsedProductId;
    if (productData is int) {
      parsedProductId = productData;
    } else if (productData is Map) {
      parsedProductId = (productData['id'] as num).toInt();
    } else {
      parsedProductId = null; // اگر محصول حذف شده باشد
    }
    // --- پایان منطق هوشمند ---

    return OrderItemModel(
      id: (json['id'] as num).toInt(),
      // --- اصلاح شد ---
      productId: parsedProductId,
      product: (json['product_id'] is Map)
          ? ProductModel.fromJson(json['product_id'] as Map<String, dynamic>)
          : null,
      // ---
      quantity: (json['quantity'] as num).toInt(),
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      productName: json['product_name'] as String,
      options: (json['order_item_options'] as List)
          .map((option) => OrderItemOptionModel.fromJson(option as Map<String, dynamic>))
          .toList(),
    );
  }
}