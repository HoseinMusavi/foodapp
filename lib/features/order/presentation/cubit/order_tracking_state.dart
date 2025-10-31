// lib/features/order/presentation/cubit/order_tracking_state.dart

part of 'order_tracking_cubit.dart';

abstract class OrderTrackingState extends Equatable {
  const OrderTrackingState();

  @override
  List<Object> get props => [];
}

/// وضعیت اولیه، در حال دریافت جزئیات کامل
class OrderTrackingLoading extends OrderTrackingState {}

/// وضعیت خطا
class OrderTrackingError extends OrderTrackingState {
  final String message;
  const OrderTrackingError({required this.message});

  @override
  List<Object> get props => [message];
}

/// وضعیت موفقیت‌آمیز، حاوی جزئیات کامل سفارش
/// (این state حالا هم جزئیات کامل رو داره و هم وضعیتش زنده آپدیت می‌شه)
class OrderTrackingLoaded extends OrderTrackingState {
  final OrderEntity order;

  const OrderTrackingLoaded({required this.order});

  @override
  List<Object> get props => [order];
}