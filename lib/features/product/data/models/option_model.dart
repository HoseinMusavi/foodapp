// lib/features/product/data/models/option_model.dart
import '../../domain/entities/option_entity.dart';

class OptionModel extends OptionEntity {
  const OptionModel({
    required super.id,
    required super.optionGroupId,
    required super.name,
    required super.priceDelta,
    super.groupName, // ✨ اضافه شد
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as int,
      optionGroupId: json['option_group_id'] as int,
      name: json['name'] as String,
      priceDelta: (json['price_delta'] as num?)?.toDouble() ?? 0.0,
      // ✨ اضافه شد: groupName می‌تواند از جوین‌ها بیاید و null باشد
      groupName: json['groupName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_group_id': optionGroupId,
      'name': name,
      'price_delta': priceDelta,
      // groupName معمولاً در زمان ارسال به دیتابیس نیاز نیست
    };
  }

  // ✨ اضافه شد: متد copyWith که در DataSource (خطای ۱۸) نیاز بود
  OptionModel copyWith({
    int? id,
    int? optionGroupId,
    String? name,
    double? priceDelta,
    String? groupName,
  }) {
    return OptionModel(
      id: id ?? this.id,
      optionGroupId: optionGroupId ?? this.optionGroupId,
      name: name ?? this.name,
      priceDelta: priceDelta ?? this.priceDelta,
      groupName: groupName ?? this.groupName,
    );
  }
}