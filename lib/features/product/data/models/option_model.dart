// lib/features/product/data/models/option_model.dart
import '../../domain/entities/option_entity.dart';

class OptionModel extends OptionEntity {
  const OptionModel({
    required super.id,
    required super.optionGroupId,
    required super.name,
    required super.priceDelta,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as int,
      optionGroupId: json['option_group_id'] as int,
      name: json['name'] as String,
      priceDelta: (json['price_delta'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_group_id': optionGroupId,
      'name': name,
      'price_delta': priceDelta,
    };
  }
}