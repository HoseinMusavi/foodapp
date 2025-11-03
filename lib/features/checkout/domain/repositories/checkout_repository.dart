import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:dartz/dartz.dart';
// ایمپورت UseCase جدید
import 'package:customer_app/features/checkout/domain/usecases/validate_coupon_usecase.dart';


abstract class CheckoutRepository {
  Future<Either<Failure, int>> placeOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  });

  // --- این متد اضافه شود ---
  Future<Either<Failure, CouponValidationResult>> validateCoupon({
    required String couponCode,
    required double subtotal,
  });
  // -------------------------
}