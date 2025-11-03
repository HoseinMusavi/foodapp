// lib/features/order/presentation/cubit/order_history_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/usecases/get_my_orders_usecase.dart';
import 'package:equatable/equatable.dart';

part 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final GetMyOrdersUsecase getMyOrdersUsecase;

  OrderHistoryCubit({required this.getMyOrdersUsecase})
      : super(OrderHistoryInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> fetchOrderHistory() async {
    emit(OrderHistoryLoading());
    final failureOrOrders = await getMyOrdersUsecase(NoParams());
    failureOrOrders.fold(
      (failure) => emit(OrderHistoryFailure(message: _mapFailureToMessage(failure))),
      (orders) => emit(OrderHistoryLoaded(orders: orders)),
    );
  }
}