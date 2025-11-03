import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/data/models/address_model.dart';
import 'package:customer_app/features/customer/data/models/customer_model.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerDetails() async {
    try {
      final customer = await remoteDataSource.getCustomerDetails();
      return Right(customer);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomerProfile(
      CustomerEntity customer) async {
    try {
      final customerModel = CustomerModel(
        id: customer.id,
        email: customer.email,
        fullName: customer.fullName,
        phone: customer.phone,
        avatarUrl: customer.avatarUrl,
        defaultAddressId: customer.defaultAddressId,
      );
      final updatedCustomer =
          await remoteDataSource.updateCustomerProfile(customerModel);
      return Right(updatedCustomer);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // پیاده سازی متد زیر
  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      return Right(addresses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // پیاده سازی متد زیر
  @override
  Future<Either<Failure, void>> addAddress(AddressEntity address) async {
     try {
      final addressModel = AddressModel(
        id: address.id,
        customerId: address.customerId,
        title: address.title,
        fullAddress: address.fullAddress,
        postalCode: address.postalCode,
        city: address.city,
        latitude: address.latitude,
        longitude: address.longitude,
      );
      await remoteDataSource.addAddress(addressModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}