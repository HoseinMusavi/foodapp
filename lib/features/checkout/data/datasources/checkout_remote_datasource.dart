import 'package:customer_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Abstract class defining the contract for remote checkout data operations
abstract class CheckoutRemoteDataSource {
  /// Calls the Supabase RPC function 'place_order'.
  ///
  /// Requires the [addressId] and accepts optional [couponCode] and [notes].
  /// Returns the new order ID (int) on success.
  /// Throws a [ServerException] on failure.
  Future<int> placeOrder({
    required int addressId,
    String? couponCode,
    String? notes,
  });
}

// Implementation using Supabase client
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final SupabaseClient supabaseClient;

  CheckoutRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<int> placeOrder({
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    try {
      // Call the 'place_order' PostgreSQL function via RPC
      final response = await supabaseClient.rpc(
        'place_order',
        params: {
          'p_address_id': addressId,
          'p_coupon_code': couponCode,
          'p_notes': notes,
        },
      );

      // Ensure the response is an integer (the order ID)
      if (response is int) {
        return response;
      } else {
        // Log unexpected response type
        print('Unexpected response type from place_order: ${response?.runtimeType}, value: $response');
        throw ServerException(message: 'Invalid response type from place_order function: ${response?.runtimeType}');
      }
    } on PostgrestException catch (e) {
       // Log detailed Supabase errors
       print('Supabase place_order error: ${e.message}');
       print('Code: ${e.code}');
       print('Details: ${e.details}');
       print('Hint: ${e.hint}');
       // Return the specific error message from the database function
       throw ServerException(message: e.message);
    } catch (e, stackTrace) {
      // Log generic errors
      print('Generic place_order error: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'An unexpected error occurred while placing the order.');
    }
  }
}