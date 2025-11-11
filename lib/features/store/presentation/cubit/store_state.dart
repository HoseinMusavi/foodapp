// lib/features/store/presentation/cubit/store_state.dart
part of 'store_cubit.dart'; // <-- ۱. این خط حیاتی اضافه یا اصلاح شد

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

// ۲. --- تعریف کلاس‌هایی که در ارورها ناشناخته بودند ---

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreEntity> stores;
  const StoreLoaded(this.stores);
  @override
  List<Object> get props => [stores];
}

class StoreError extends StoreState {
  final String message;
  const StoreError(this.message);
  @override
  List<Object> get props => [message];
}