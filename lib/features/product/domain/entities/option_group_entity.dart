// lib/features/product/domain/entities/option_group_entity.dart
import 'package:equatable/equatable.dart';
import 'option_entity.dart'; // <-- فایل بالایی را ایمپورت می‌کند

class OptionGroupEntity extends Equatable {
  final int id;
  final int storeId;
  final String name;
  // ما لیست آپشن‌ها را مستقیماً اینجا نگه می‌داریم تا کار در UI راحت باشد
  final List<OptionEntity> options; 

  const OptionGroupEntity({
    required this.id,
    required this.storeId,
    required this.name,
    this.options = const [],
  });

  @override
  List<Object?> get props => [id, storeId, name, options];
}