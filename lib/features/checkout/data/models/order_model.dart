// lib/features/checkout/data/models/order_model.dart

import 'package:customer_app/features/checkout/data/models/order_item_model.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/checkout/domain/entities/order_item_entity.dart';
import 'package:customer_app/features/customer/data/models/address_model.dart';
import 'package:customer_app/features/store/data/models/store_model.dart';

class OrderModel extends OrderEntity {
  
  const OrderModel({
    required super.id,
    required super.createdAt,
    required super.customerId,
    super.storeId, // <-- حالا اختیاری است
    super.addressId, // <-- حالا اختیاری است
    required super.subtotalPrice,
    required super.deliveryFee,
    required super.discountAmount,
    required super.totalPrice,
    required super.status,
    required super.items,
    super.store,
    super.address,
    super.estimatedDeliveryTime,
    super.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    
    // --- منطق هوشمند (رفع خطای Map/int و مدیریت Null) ---
    
    // ۱. خواندن Store ID
    final storeData = json['store_id'];
    int? parsedStoreId; // <-- اصلاح شد: می‌تواند null باشد
    if (storeData is int) {
      parsedStoreId = storeData;
    } else if (storeData is Map) {
      parsedStoreId = (storeData['id'] as num).toInt();
    } else {
      parsedStoreId = null; // <-- اگر null بود، null بماند
    }

    // ۲. خواندن Address ID
    final addressData = json['address_id'];
    int? parsedAddressId; // <-- اصلاح شد: می‌تواند null باشد
    if (addressData is int) {
      parsedAddressId = addressData;
    } else if (addressData is Map) {
      parsedAddressId = (addressData['id'] as num).toInt();
    } else {
      parsedAddressId = null; // <-- اگر null بود، null بماند (دیگر خطا پرتاب نمی‌شود)
    }
    // --- پایان منطق هوشمند ---

    final List<OrderItemEntity> parsedItems = 
        json['order_items'] != null && json['order_items'] is List
            ? (json['order_items'] as List)
                .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
                .toList()
            : []; 

    return OrderModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      customerId: json['customer_id'] as String,
      storeId: parsedStoreId, 
      addressId: parsedAddressId, 
      subtotalPrice: (json['subtotal_price'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: (json['status'] as String).toOrderStatus(), 
      items: parsedItems, 
      
      estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
      notes: json['notes'] as String?,
      store: (json['store_id'] is Map)
          ? StoreModel.fromJson(json['store_id'] as Map<String, dynamic>)
          : null,
      address: (json['address_id'] is Map)
          ? AddressModel.fromJson(json['address_id'] as Map<String, dynamic>)
          : null,
    );
  }
}