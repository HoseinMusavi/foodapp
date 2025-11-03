import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// این Entity کوچک، خروجی تابع validate_coupon ما است
class CouponValidationResult extends Equatable {
  final double discountAmount;
  final String? errorMessage;

  const CouponValidationResult({
    required this.discountAmount,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [discountAmount, errorMessage];
}

// UseCase
class ValidateCouponUsecase
    extends UseCase<CouponValidationResult, ValidateCouponParams> {
  final CheckoutRepository repository;

  ValidateCouponUsecase(this.repository);

  @override
  Future<Either<Failure, CouponValidationResult>> call(
      ValidateCouponParams params) async {
    return await repository.validateCoupon(
      couponCode: params.couponCode,
      subtotal: params.subtotal,
    );
  }
}

// پارامترهای ورودی UseCase
class ValidateCouponParams extends Equatable {
  final String couponCode;
  final double subtotal;

  const ValidateCouponParams({
    required this.couponCode,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [couponCode, subtotal];
}