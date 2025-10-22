// lib/features/checkout/domain/entities/order_item_option_entity.dart
import 'package:equatable/equatable.dart';

// این موجودیت، گزینه‌هایی که برای یک آیتم سفارش ثبت نهایی شده‌اند را نگه می‌دارد
class OrderItemOptionEntity extends Equatable {
  final String optionGroupName;
  final String optionName;
  final double priceDelta; // قیمتی که در لحظه خرید ثبت شده

  const OrderItemOptionEntity({
    required this.optionGroupName,
    required this.optionName,
    required this.priceDelta,
  });

  @override
  List<Object?> get props => [optionGroupName, optionName, priceDelta];
}