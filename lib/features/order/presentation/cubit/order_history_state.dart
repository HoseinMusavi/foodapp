// lib/features/order/presentation/cubit/order_history_state.dart

part of 'order_history_cubit.dart';

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryFailure extends OrderHistoryState {
  final String message;
  const OrderHistoryFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderEntity> orders;
  const OrderHistoryLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}