// lib/features/checkout/presentation/cubit/checkout_state.dart

part of 'checkout_cubit.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

// --- استیت‌های مربوط به اعتبارسنجی کد تخفیف ---

// زمانی که دکمه "اعمال" زده می‌شود و منتظر پاسخ سرور هستیم
class CheckoutCouponValidating extends CheckoutState {}

// زمانی که سرور پاسخ می‌دهد که کد معتبر است و مبلغ تخفیف را برمی‌گرداند
class CheckoutCouponSuccess extends CheckoutState {
  final double discountAmount;
  const CheckoutCouponSuccess({required this.discountAmount});

  @override
  List<Object?> get props => [discountAmount];
}

// زمانی که کد نامعتبر است (خطای سرور یا خطای منطقی مثل "کد منقضی شده")
class CheckoutCouponFailure extends CheckoutState {
  final String message;
  const CheckoutCouponFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// --- استیت‌های مربوط به ثبت نهایی سفارش (قبلاً وجود داشتند) ---

// زمانی که دکمه "ثبت نهایی" زده می‌شود
class CheckoutProcessing extends CheckoutState {}

// زمانی که سفارش با موفقیت ثبت می‌شود
class CheckoutSuccess extends CheckoutState {
  final int orderId;

  const CheckoutSuccess({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// زمانی که در ثبت نهایی سفارش خطایی رخ می‌دهد
class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure({required this.message});

  @override
  List<Object?> get props => [message];
}