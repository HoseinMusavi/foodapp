// lib/features/checkout/domain/entities/order_entity.dart
import 'package:customer_app/features/checkout/domain/entities/order_item_entity.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// enum OrderStatus که منبع اصلی ماست، اینجا باقی می‌ماند
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  delivering,
  delivered,
  cancelled,
}

class OrderEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String customerId;
  // --- اصلاح شد: این فیلدها می‌توانند null باشند ---
  final int? storeId;
  final int? addressId;
  // ---
  final double subtotalPrice;
  final double deliveryFee;
  final double discountAmount;
  final double totalPrice;
  final OrderStatus status;
  final List<OrderItemEntity> items;

  // فیلدهای اضافی
  final StoreEntity? store;
  final AddressEntity? address;
  final String? estimatedDeliveryTime;
  final String? notes;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.customerId,
    // --- اصلاح شد: required حذف شد ---
    this.storeId,
    this.addressId,
    // ---
    required this.subtotalPrice,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalPrice,
    required this.status,
    required this.items,
    this.store,
    this.address,
    this.estimatedDeliveryTime,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        customerId,
        storeId, // <--
        addressId, // <--
        subtotalPrice,
        deliveryFee,
        discountAmount,
        totalPrice,
        status,
        items,
        store,
        address,
        estimatedDeliveryTime,
        notes,
      ];

  OrderEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? customerId,
    // --- اصلاح شد: ValueGetter برای nullable ها ---
    ValueGetter<int?>? storeId,
    ValueGetter<int?>? addressId,
    // ---
    double? subtotalPrice,
    double? deliveryFee,
    double? discountAmount,
    double? totalPrice,
    OrderStatus? status,
    List<OrderItemEntity>? items,
    ValueGetter<StoreEntity?>? store,
    ValueGetter<AddressEntity?>? address,
    ValueGetter<String?>? estimatedDeliveryTime,
    ValueGetter<String?>? notes,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      customerId: customerId ?? this.customerId,
      // --- اصلاح شد ---
      storeId: storeId != null ? storeId() : this.storeId,
      addressId: addressId != null ? addressId() : this.addressId,
      // ---
      subtotalPrice: subtotalPrice ?? this.subtotalPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      items: items ?? this.items,
      store: store != null ? store() : this.store,
      address: address != null ? address() : this.address,
      estimatedDeliveryTime: estimatedDeliveryTime != null
          ? estimatedDeliveryTime()
          : this.estimatedDeliveryTime,
      notes: notes != null ? notes() : this.notes,
    );
  }
}


// اکستنشن (متد .toOrderStatus()) در همین فایل باقی می‌ماند
extension OrderStatusExtension on String {
  OrderStatus toOrderStatus() {
    try {
      return OrderStatus.values.firstWhere((e) => e.name == this);
    } catch (e) {
      print('!!! Unknown OrderStatus: $this');
      return OrderStatus.pending; 
    }
  }
}