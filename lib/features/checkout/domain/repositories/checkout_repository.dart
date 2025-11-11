import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:dartz/dartz.dart';

// Abstract class defining the contract for checkout operations
abstract class CheckoutRepository {
  /// Calls the 'place_order' function in Supabase.
  ///
  /// Takes the selected [address], optional [couponCode], and optional [notes].
  /// Returns either a [Failure] or the new order ID (int).
  Future<Either<Failure, int>> placeOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  });
}