// lib/features/order/presentation/cubit/order_history_state.dart

part of 'order_history_cubit.dart';

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderEntity> orders;
  // --- فیلد جدید اضافه شد (بخش ۱.۳) ---
  final Set<int> reviewedOrderIds;
  // ---

  const OrderHistoryLoaded({
    required this.orders,
    this.reviewedOrderIds = const <int>{}, // --- مقدار پیشفرض ---
  });

  // --- متد copyWith برای آپدیت آسان ---
  OrderHistoryLoaded copyWith({
    List<OrderEntity>? orders,
    Set<int>? reviewedOrderIds,
  }) {
    return OrderHistoryLoaded(
      orders: orders ?? this.orders,
      reviewedOrderIds: reviewedOrderIds ?? this.reviewedOrderIds,
    );
  }

  @override
  List<Object> get props => [orders, reviewedOrderIds]; // --- اضافه شد ---
}

class OrderHistoryError extends OrderHistoryState {
  final String message;

  const OrderHistoryError({required this.message});

  @override
  List<Object> get props => [message];
}