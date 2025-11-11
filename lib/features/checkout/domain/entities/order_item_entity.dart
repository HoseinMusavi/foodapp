// lib/features/checkout/domain/entities/order_item_entity.dart

import 'package:customer_app/features/checkout/domain/entities/order_item_option_entity.dart';

import 'package:customer_app/features/product/domain/entities/product_entity.dart';
import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  // --- اصلاح شد: این دو فیلد می‌توانند null باشند ---
  final int? productId; 
  final ProductEntity? product;
  // ---
  final int quantity;
  final double priceAtPurchase;
  final String productName;
  final List<OrderItemOptionEntity> options;

  const OrderItemEntity({
    required this.id,
    // --- اصلاح شد: required حذف شد ---
    this.productId,
    this.product,
    // ---
    required this.quantity,
    required this.priceAtPurchase,
    required this.productName,
    required this.options,
  });

  @override
  List<Object?> get props => [
        id,
        productId, // <--
        product, // <--
        quantity,
        priceAtPurchase,
        productName,
        options,
      ];
}