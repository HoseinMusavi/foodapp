// lib/features/checkout/data/datasources/checkout_remote_datasource.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/features/checkout/domain/entities/coupon_validation_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CheckoutRemoteDataSource {
  Future<int> placeOrder({
    required int addressId,
    String? couponCode,
    String? notes,
  });

  Future<CouponValidationEntity> validateCoupon({
    required String couponCode,
    required double subtotal,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final SupabaseClient supabaseClient;

  CheckoutRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CouponValidationEntity> validateCoupon({
    required String couponCode,
    required double subtotal,
  }) async {
    try {
      final response = await supabaseClient.rpc(
        'validate_coupon',
        params: {
          'p_coupon_code': couponCode,
          'p_subtotal': subtotal,
        },
      );

      if (response is List && response.isNotEmpty) {
        final data = response[0] as Map<String, dynamic>;
        return CouponValidationEntity.fromJson(data);
      } else {
        throw const ServerException(message: 'پاسخ نامعتبر از سرور برای کد تخفیف');
      }
    } on PostgrestException catch (e) {
      print('Supabase validate_coupon error: ${e.message}');
      throw ServerException(message: e.message);
    } catch (e) {
      print('Generic validate_coupon error: $e');
      throw ServerException(message: 'خطا در اعتبارسنجی کد تخفیف');
    }
  }

  @override
  Future<int> placeOrder({
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    try {
      final response = await supabaseClient.rpc(
        'place_order',
        params: {
          'p_address_id': addressId,
          'p_coupon_code': couponCode,
          'p_notes': notes,
        },
      );

      if (response is int) {
        return response;
      } else {
        // --- اصلاح شد: ---
        // این throw باید در بدنه else باشد تا کامپایلر مطمئن شود
        // که تابع هرگز به صورت ضمنی null برنمی‌گرداند.
        print(
            'Unexpected response type from place_order: ${response?.runtimeType}, value: $response');
        throw ServerException(
            message:
                'Invalid response type from place_order function: ${response?.runtimeType}');
        // --- پایان اصلاح ---
      }
    } on PostgrestException catch (e) {
      print('Supabase place_order error: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      throw ServerException(message: e.message);
    } catch (e, stackTrace) {
      print('Generic place_order error: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(
          message: 'An unexpected error occurred while placing the order.');
    }
  }
}