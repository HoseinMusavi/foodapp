part of 'checkout_cubit.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

// --- وضعیت‌های جدید اعتبارسنجی کوپن ---
class CheckoutCouponValidating extends CheckoutState {}

class CheckoutCouponApplied extends CheckoutState {
  final String couponCode;
  final double discountAmount;

  const CheckoutCouponApplied({
    required this.couponCode,
    required this.discountAmount,
  });

  @override
  List<Object?> get props => [couponCode, discountAmount];
}

class CheckoutCouponInvalid extends CheckoutState {
  final String message;
  const CheckoutCouponInvalid({required this.message});
  @override
  List<Object?> get props => [message];
}
// ------------------------------------

// وضعیت‌های قبلی ثبت سفارش نهایی
class CheckoutProcessing extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final int orderId;
  const CheckoutSuccess({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class CheckoutFailure extends CheckoutState {
  final String message;
  const CheckoutFailure({required this.message});
  @override
  List<Object?> get props => [message];
}