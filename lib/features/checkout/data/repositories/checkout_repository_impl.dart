import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart';
// ایمپورت یوزکیس (برای دسترسی به CouponValidationResult)
import 'package:customer_app/features/checkout/domain/usecases/validate_coupon_usecase.dart'; 
import 'package:dartz/dartz.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, int>> placeOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  }) async {
    
    // --- **اصلاحیه اصلی اینجا بود** ---
    // چک می‌کنیم که آدرس انتخاب شده ID داشته باشد
    if (address.id == null) {
      // این یک خطای حیاتی است، چون آدرس باید قبلا ذخیره شده باشد
      return Left(ServerFailure(message: 'آدرس انتخاب شده نامعتبر است (ID is null).'));
    }
    // -----------------------------------

    try {
      final orderId = await remoteDataSource.placeOrder(
        addressId: address.id!, // <-- حالا می‌توانیم با اطمینان '!' بگذاریم
        couponCode: couponCode,
        notes: notes,
      );
      return Right(orderId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // --- این متد جدید است ---
  @override
  Future<Either<Failure, CouponValidationResult>> validateCoupon({
    required String couponCode,
    required double subtotal,
  }) async {
    try {
      final result = await remoteDataSource.validateCoupon(
        couponCode: couponCode,
        subtotal: subtotal,
      );
      
      // تابع بک‌اند ممکن است یک خطا را به عنوان بخشی از خروجی موفق برگرداند
      if (result.errorMessage != null) {
        // این یک خطای بیزینسی است (مثلاً کد نامعتبر)، نه خطای سرور
        return Left(ServerFailure(message: result.errorMessage!));
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}