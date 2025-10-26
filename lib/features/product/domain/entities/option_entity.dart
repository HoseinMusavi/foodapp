// lib/features/product/domain/entities/option_entity.dart
import 'package:equatable/equatable.dart';

class OptionEntity extends Equatable {
  final int id;
  final int optionGroupId;
  final String name;
  final double priceDelta;
  // ✨ اضافه شد: برای نگهداری نام گروه (مثلاً "سایز" یا "نوشیدنی")
  final String? groupName;

  const OptionEntity({
    required this.id,
    required this.optionGroupId,
    required this.name,
    required this.priceDelta,
    this.groupName, // ✨ اضافه شد
  });

  @override
  // ✨ اضافه شد: groupName به props
  List<Object?> get props => [id, optionGroupId, name, priceDelta, groupName];
}