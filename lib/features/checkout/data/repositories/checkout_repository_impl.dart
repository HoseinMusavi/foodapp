import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:dartz/dartz.dart';

// Implementation of the CheckoutRepository
class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, int>> placeOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  }) async {
    // Validate that the address has an ID before proceeding
    if (address.id == null) {
      print('Error: Attempted to place order with missing address ID.');
      return Left(ServerFailure(message: 'Address ID is missing. Cannot place order.'));
    }
    try {
      // Call the remote data source to execute the Supabase function
      final orderId = await remoteDataSource.placeOrder(
        addressId: address.id!,
        couponCode: couponCode,
        notes: notes,
      );
      // Return the order ID on success
      return Right(orderId);
    } on ServerException catch (e) {
      // Forward server exceptions as ServerFailure
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      // Catch any other unexpected errors
      print('Unexpected error in CheckoutRepositoryImpl: $e');
      print('Stack trace: $stackTrace');
       return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }
}