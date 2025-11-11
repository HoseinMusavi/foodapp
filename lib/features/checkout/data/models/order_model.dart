// lib/features/checkout/data/models/order_model.dart

import 'package:customer_app/features/checkout/data/models/order_item_model.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/store/data/models/store_model.dart'; // <-- ** 1. این ایمپورت اضافه شود **

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
    super.store, // <-- ** 2. این فیلد اضافه شود **
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    
    // خواندن آیتم‌ها
    List<OrderItemModel> itemsList = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      itemsList = (json['order_items'] as List)
          .map((itemJson) => OrderItemModel.fromJson(itemJson))
          .toList();
    }

    // ****** 3. این بخش اضافه شد (برای خواندن فروشگاه) ******
    StoreModel? storeModel;
    if (json['store'] != null && json['store'] is Map) {
      try {
         storeModel = StoreModel.fromJson(json['store']);
      } catch (e) {
        print('Error parsing store in OrderModel: $e');
        storeModel = null;
      }
    }
    // ****** پایان بخش اضافه شده ******
    
    return OrderModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      customerId: json['customer_id'],
      storeId: json['store_id'],
      addressId: json['address_id'],
      subtotalPrice: (json['subtotal_price'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      notes: json['notes'],
      items: itemsList, 
      store: storeModel, // <-- ** 4. این فیلد پاس داده شد **
    );
  }

  // ... متد toJson() بدون تغییر باقی می‌ماند ...
}