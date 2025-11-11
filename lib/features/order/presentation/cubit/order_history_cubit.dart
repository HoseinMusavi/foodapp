// lib/features/order/presentation/cubit/order_history_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/usecases/get_my_orders_usecase.dart';
import 'package:customer_app/features/order/domain/usecases/get_reviewed_order_ids_usecase.dart';
import 'package:dartz/dartz.dart'; // --- ایمپورت dartz اضافه شد ---
import 'package:equatable/equatable.dart';

part 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final GetMyOrdersUsecase getMyOrdersUsecase;
  final GetReviewedOrderIdsUsecase getReviewedOrderIdsUsecase;

  OrderHistoryCubit({
    required this.getMyOrdersUsecase,
    required this.getReviewedOrderIdsUsecase,
  }) : super(OrderHistoryInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> fetchOrderHistory() async {
    // --- اصلاح شد: کل منطق در try/catch قرار گرفت ---
    try {
      if (state is OrderHistoryLoading) return; 
      emit(OrderHistoryLoading());

      final results = await Future.wait([
        getMyOrdersUsecase(NoParams()),
        getReviewedOrderIdsUsecase(NoParams()),
      ]);

      final failureOrOrders = results[0] as Either<Failure, List<OrderEntity>>;
      final failureOrReviewedIds = results[1] as Either<Failure, Set<int>>;

      if (failureOrOrders.isLeft()) {
        failureOrOrders.fold(
          (failure) => emit(OrderHistoryError(message: _mapFailureToMessage(failure))),
          (_) {},
        );
        return;
      }

      final orders = (failureOrOrders as Right<Failure, List<OrderEntity>>).value;
      
      Set<int> reviewedIds = const <int>{};
      if (failureOrReviewedIds.isLeft()) {
        failureOrReviewedIds.fold(
          (failure) => print('خطا در گرفتن ID نقدهای قبلی: ${_mapFailureToMessage(failure)}'),
          (_) {},
        );
      } else {
        reviewedIds = (failureOrReviewedIds as Right<Failure, Set<int>>).value;
      }

      emit(OrderHistoryLoaded(
        orders: orders,
        reviewedOrderIds: reviewedIds,
      ));
    } catch (e) {
      // این catch تضمین می‌کند که در صورت بروز هر خطای پیش‌بینی‌نشده،
      // از حالت لودینگ خارج می‌شویم.
      emit(OrderHistoryError(message: 'خطای سیستمی: ${e.toString()}'));
    }
    // ---
  }
}