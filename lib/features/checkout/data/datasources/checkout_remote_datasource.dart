import 'package:customer_app/core/error/exceptions.dart';
// ایمپورت UseCase (برای Entity)
import 'package:customer_app/features/checkout/domain/usecases/validate_coupon_usecase.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

// Abstract class
abstract class CheckoutRemoteDataSource {
  Future<int> placeOrder({
    required int addressId,
    String? couponCode,
    String? notes,
  });

  // --- این متد اضافه شود ---
  Future<CouponValidationResult> validateCoupon({
    required String couponCode,
    required double subtotal,
  });
  // -------------------------
}

// Implementation
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final SupabaseClient supabaseClient;

  CheckoutRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<int> placeOrder({
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    // ... (کد قبلی شما - بدون تغییر)
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
        print('Unexpected response type from place_order: ${response?.runtimeType}, value: $response');
        throw ServerException(message: 'Invalid response type from place_order function: ${response?.runtimeType}');
      }
    } on PostgrestException catch (e) {
       print('Supabase place_order error: ${e.message}');
       throw ServerException(message: e.message);
    } catch (e, stackTrace) {
      print('Generic place_order error: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'An unexpected error occurred while placing the order.');
    }
  }


  // --- این متد اضافه شود ---
  @override
  Future<CouponValidationResult> validateCoupon({
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

      // تابع ما یک list (حاوی یک map) برمی‌گرداند
      if (response is List && response.isNotEmpty) {
        final data = response.first as Map<String, dynamic>;
        return CouponValidationResult(
          discountAmount: (data['discount_amount'] as num).toDouble(),
          errorMessage: data['error_message'] as String?,
        );
      } else {
        throw ServerException(message: 'Invalid response from validate_coupon function.');
      }
    } on PostgrestException catch (e) {
      print('Supabase validate_coupon error: ${e.message}');
      throw ServerException(message: e.message);
    } catch (e, stackTrace) {
      print('Generic validate_coupon error: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'An unexpected error occurred while validating the coupon.');
    }
  }
  // -------------------------
}