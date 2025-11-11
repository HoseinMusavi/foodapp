// lib/features/checkout/domain/usecases/validate_coupon_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/coupon_validation_entity.dart';
import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ValidateCouponUsecase
    implements UseCase<CouponValidationEntity, ValidateCouponParams> {
  final CheckoutRepository repository;

  ValidateCouponUsecase(this.repository);

  @override
  Future<Either<Failure, CouponValidationEntity>> call(
      ValidateCouponParams params) async {
    return await repository.validateCoupon(
      couponCode: params.couponCode,
      subtotal: params.subtotal,
    );
  }
}

class ValidateCouponParams extends Equatable {
  final String couponCode;
  final double subtotal; // سبد خرید برای اعتبارسنجی min_order_amount

  const ValidateCouponParams({
    required this.couponCode,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [couponCode, subtotal];
}