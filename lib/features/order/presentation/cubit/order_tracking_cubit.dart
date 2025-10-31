// lib/features/order/presentation/cubit/order_tracking_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/usecases/get_order_details_usecase.dart';
import 'package:customer_app/features/order/domain/usecases/get_order_updates_usecase.dart';
import 'package:dartz/dartz.dart'; // <-- ** 1. ایمپورت Dartz اضافه شد **
import 'package:equatable/equatable.dart';

part 'order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final GetOrderDetailsUsecase getOrderDetailsUsecase;
  final GetOrderUpdatesUsecase getOrderUpdatesUsecase;
  StreamSubscription? _orderSubscription;

  OrderTrackingCubit({
    required this.getOrderDetailsUsecase,
    required this.getOrderUpdatesUsecase,
  }) : super(OrderTrackingLoading());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> startTrackingOrder(int orderId) async {
    await _orderSubscription?.cancel();
    emit(OrderTrackingLoading());

    // --- مرحله ۱: گرفتن جزئیات کامل سفارش (فقط یک بار) ---
    final failureOrDetails =
        await getOrderDetailsUsecase(GetOrderDetailsParams(orderId: orderId));

    // در صورت شکست در گرفتن جزئیات، متوقف می‌شویم
    if (failureOrDetails.isLeft()) {
      failureOrDetails.fold(
        (failure) => emit(OrderTrackingError(message: _mapFailureToMessage(failure))),
        (_) {},
      );
      return;
    }

    // ****** 2. این خط اصلاح شد (روش صحیح گرفتن مقدار Right) ******
    final initialOrderDetails = (failureOrDetails as Right<Failure, OrderEntity>).value;
    emit(OrderTrackingLoaded(order: initialOrderDetails));

    // --- مرحله ۲: گوش دادن به آپدیت‌های زنده وضعیت ---
    final failureOrStream =
        await getOrderUpdatesUsecase(GetOrderUpdatesParams(orderId: orderId));

    failureOrStream.fold(
      (failure) {
        print('Error subscribing to order updates: ${_mapFailureToMessage(failure)}');
      },
      (statusStream) {
        _orderSubscription = statusStream.listen(
          (orderUpdate) {
            final currentState = state;
            if (currentState is OrderTrackingLoaded) {
              emit(
                OrderTrackingLoaded(
                  order: currentState.order.copyWith(
                    status: orderUpdate.status, // فقط وضعیت آپدیت می‌شود
                  ),
                ),
              );
            }
          },
          onError: (error) {
            print('Error in order status stream: $error');
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}