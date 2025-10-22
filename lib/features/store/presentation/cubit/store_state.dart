// lib/features/store/presentation/cubit/store_state.dart

// 1. "part of" را حذف کردیم
import 'package:equatable/equatable.dart'; // 2. ایمپورت‌های مورد نیاز را اضافه کردیم
import '../../domain/entities/store_entity.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

// وضعیت اولیه
class StoreInitial extends StoreState {} // <-- این کلاس را اضافه کردیم

// وضعیت در حال بارگذاری
class StoreLoading extends StoreState {}

// وضعیت موفقیت‌آمیز، همراه با لیستی از فروشگاه‌ها
class StoreLoaded extends StoreState {
  final List<StoreEntity> stores;

  const StoreLoaded({required this.stores}); // <-- از this.stores به required super.stores تغییر کرد

  @override
  List<Object> get props => [stores];
}

// وضعیت خطا، همراه با یک پیام
class StoreError extends StoreState {
  final String message;

  const StoreError({required this.message}); // <-- از this.message به required super.message تغییر کرد

  @override
  List<Object> get props => [message];
}