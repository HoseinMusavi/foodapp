import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/domain/usecases/place_order_usecase.dart';
// ایمپورت UseCase جدید
import 'package:customer_app/features/checkout/domain/usecases/validate_coupon_usecase.dart'; 
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:equatable/equatable.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final PlaceOrderUsecase placeOrderUsecase;
  // --- UseCase جدید اضافه شود ---
  final ValidateCouponUsecase validateCouponUsecase;
  // -----------------------------

  CheckoutCubit({
    required this.placeOrderUsecase,
    required this.validateCouponUsecase, // <-- اضافه شود
  }) : super(CheckoutInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  // --- متد جدید برای اعتبارسنجی کوپن ---
  Future<void> applyCoupon({
    required String couponCode,
    required double subtotal,
  }) async {
    if (couponCode.isEmpty) {
      emit(CheckoutInitial()); // یا یک خطای "کد را وارد کنید"
      return;
    }
    emit(CheckoutCouponValidating());

    final failureOrResult = await validateCouponUsecase(
      ValidateCouponParams(couponCode: couponCode, subtotal: subtotal),
    );

    failureOrResult.fold(
      (failure) => emit(CheckoutCouponInvalid(message: _mapFailureToMessage(failure))),
      (result) {
        // تابع بک‌اند ممکن است خطا را در اینجا برگرداند
        if (result.errorMessage != null) {
          emit(CheckoutCouponInvalid(message: result.errorMessage!));
        } else {
          emit(CheckoutCouponApplied(
            couponCode: couponCode,
            discountAmount: result.discountAmount,
          ));
        }
      },
    );
  }
  // ------------------------------------

  // --- متد قبلی ثبت سفارش ---
  Future<void> submitOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  }) async {
    emit(CheckoutProcessing());
    final failureOrOrderId = await placeOrderUsecase(
      PlaceOrderParams(
        address: address,
        couponCode: couponCode,
        notes: notes,
      ),
    );

    failureOrOrderId.fold(
      (failure) => emit(CheckoutFailure(message: _mapFailureToMessage(failure))),
      (orderId) => emit(CheckoutSuccess(orderId: orderId)),
    );
  }
}