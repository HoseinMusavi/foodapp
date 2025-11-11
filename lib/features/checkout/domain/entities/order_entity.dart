// lib/features/checkout/domain/entities/order_entity.dart

import 'package:customer_app/features/checkout/domain/entities/order_item_entity.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, preparing, delivering, delivered, cancelled }

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
  final OrderStatus status;
  final String? notes;
  final List<OrderItemEntity> items;
  final StoreEntity? store;

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
    required this.items,
    this.store,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        customerId,
        storeId,
        addressId,
        subtotalPrice,
        deliveryFee,
        discountAmount,
        totalPrice,
        status,
        notes,
        items,
        store,
      ];

  // ****** 1. این متد حیاتی اضافه شد ******
  OrderEntity copyWith({
    OrderStatus? status,
  }) {
    return OrderEntity(
      id: id,
      createdAt: createdAt,
      customerId: customerId,
      storeId: storeId,
      addressId: addressId,
      subtotalPrice: subtotalPrice,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
      totalPrice: totalPrice,
      status: status ?? this.status, // <-- فقط وضعیت آپدیت می‌شود
      notes: notes,
      items: items,
      store: store,
    );
  }
  // ****** پایان بخش اضافه شده ******
}