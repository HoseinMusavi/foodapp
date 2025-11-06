// lib/features/checkout/domain/repositories/checkout_repository.dart

import 'package:customer_app/core/error/failure.dart';
// ایمپورت انتیتی جدید
import 'package:customer_app/features/checkout/domain/entities/coupon_validation_entity.dart';
import 'package:customer_app/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:dartz/dartz.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, int>> placeOrder(PlaceOrderParams params);

  // --- متد جدید اضافه شد ---
  Future<Either<Failure, CouponValidationEntity>> validateCoupon({
    required String couponCode,
    required double subtotal,
  });
  // --- پایان بخش اضافه شده ---
}