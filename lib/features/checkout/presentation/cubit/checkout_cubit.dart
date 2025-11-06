// lib/features/checkout/presentation/cubit/checkout_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/domain/usecases/place_order_usecase.dart';
// ایمپورت یوزکیس جدید
import 'package:customer_app/features/checkout/domain/usecases/validate_coupon_usecase.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:equatable/equatable.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final PlaceOrderUsecase placeOrderUsecase;
  // --- یوزکیس جدید اضافه شد ---
  final ValidateCouponUsecase validateCouponUsecase;
  // --- پایان بخش اضافه شده ---

  CheckoutCubit({
    required this.placeOrderUsecase,
    required this.validateCouponUsecase, // --- به کانستراکتور اضافه شد ---
  }) : super(CheckoutInitial());

  // تابع کمکی برای مدیریت پیام خطا
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  // --- متد جدید اضافه شد ---
  /// این متد فقط کد تخفیف را اعتبارسنجی می‌کند و UI را آپدیت می‌کند
  Future<void> applyCoupon({
    required String couponCode,
    required double subtotal,
  }) async {
    // اگر کد خالی باشد، استیت را ریست کن (اگر قبلاً کدی اعمال شده)
    if (couponCode.isEmpty) {
      emit(CheckoutInitial());
      return;
    }
    
    emit(CheckoutCouponValidating());

    final failureOrValidation = await validateCouponUsecase(
      ValidateCouponParams(couponCode: couponCode, subtotal: subtotal),
    );

    failureOrValidation.fold(
      (failure) {
        // خطای سیستمی (مثل قطعی اینترنت)
        emit(CheckoutCouponFailure(message: _mapFailureToMessage(failure)));
      },
      (validationResult) {
        // خطای منطقی (مثل: "کد نامعتبر است")
        if (validationResult.hasError) {
          emit(CheckoutCouponFailure(message: validationResult.errorMessage!));
        } else {
          // موفقیت
          emit(CheckoutCouponSuccess(
              discountAmount: validationResult.discountAmount));
        }
      },
    );
  }
  // --- پایان بخش اضافه شده ---

  /// این متد سفارش نهایی را ثبت می‌کند
  Future<void> submitOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  }) async {
    emit(CheckoutProcessing());
    // استفاده از UseCase با پارامترهایش
    final failureOrOrderId = await placeOrderUsecase(
      PlaceOrderParams(
        address: address,
        couponCode: (couponCode != null && couponCode.isEmpty) ? null : couponCode,
        notes: notes,
      ),
    );

    failureOrOrderId.fold(
      (failure) =>
          emit(CheckoutFailure(message: _mapFailureToMessage(failure))),
      (orderId) => emit(CheckoutSuccess(orderId: orderId)),
    );
  }
}