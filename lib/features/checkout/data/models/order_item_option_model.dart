// lib/features/checkout/data/models/order_item_option_model.dart
import '../../domain/entities/order_item_option_entity.dart';

class OrderItemOptionModel extends OrderItemOptionEntity {
  const OrderItemOptionModel({
    required super.optionGroupName,
    required super.optionName,
    required super.priceDelta,
  });

  factory OrderItemOptionModel.fromJson(Map<String, dynamic> json) {
    return OrderItemOptionModel(
      optionGroupName: json['option_group_name'] as String,
      optionName: json['option_name'] as String,
      priceDelta: (json['price_delta'] as num).toDouble(),
    );
  }

  // ما نیازی به toJson نداریم چون این مدل را فقط از بک‌اند می‌خوانیم
  // و تابع place_order خودش آن‌ها را در بک‌اند کپی می‌کند.
}