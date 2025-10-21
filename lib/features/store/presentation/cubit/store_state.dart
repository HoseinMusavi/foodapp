// lib/features/store/presentation/cubit/store_state.dart

part of 'store_cubit.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

// وضعیت اولیه و در حال بارگذاری
class StoreLoading extends StoreState {}

// وضعیت موفقیت‌آمیز، همراه با لیستی از فروشگاه‌ها
class StoreLoaded extends StoreState {
  final List<StoreEntity> stores;

  const StoreLoaded(this.stores);

  @override
  List<Object> get props => [stores];
}

// وضعیت خطا، همراه با یک پیام
class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object> get props => [message];
}
