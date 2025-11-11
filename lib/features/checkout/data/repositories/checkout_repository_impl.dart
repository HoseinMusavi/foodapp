// lib/features/checkout/data/repositories/checkout_repository_impl.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:customer_app/features/checkout/domain/entities/coupon_validation_entity.dart';
import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:customer_app/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:dartz/dartz.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, int>> placeOrder(PlaceOrderParams params) async {
    try {
      // --- اصلاح شد: گارد برای Null-Safety ---
      // ما باید قبل از ارسال، چک کنیم که آدرس ID دارد
      if (params.address.id == null) {
        return Left(ServerFailure(
            message: 'خطای داخلی: آدرس انتخاب شده شناسه معتبر ندارد.'));
      }
      // --- پایان اصلاح ---

      final orderId = await remoteDataSource.placeOrder(
        addressId: params.address.id!, // حالا می‌توانیم با اطمینان از ! استفاده کنیم
        couponCode: params.couponCode,
        notes: params.notes,
      );
      return Right(orderId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponValidationEntity>> validateCoupon(
      {required String couponCode, required double subtotal}) async {
    try {
      final result = await remoteDataSource.validateCoupon(
        couponCode: couponCode,
        subtotal: subtotal,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}