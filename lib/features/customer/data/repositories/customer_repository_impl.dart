import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerDetails() async {
    try {
      debugPrint("✅ [Repository] -> getCustomerDetails: Calling DataSource...");
      final customerModel = await remoteDataSource.getCustomerDetails();
      final addresses = await remoteDataSource.getAddresses();

      final customerEntity = CustomerEntity(
        id: customerModel.id,
        fullName: customerModel.fullName,
        email: customerModel.email,
        phone: customerModel.phone,
        avatarUrl: customerModel.avatarUrl,
        defaultAddressId: customerModel.defaultAddressId,
        addresses: addresses,
      );

      debugPrint("✅ [Repository] -> getCustomerDetails: Data received from DataSource and converted to Entity.");
      return Right(customerEntity);
    } on ServerException catch (e) {
      debugPrint("❌ [Repository] -> getCustomerDetails: Server error received: ${e.message}");
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomerProfile(
    CustomerEntity customer,
    File? imageFile,
  ) async {
    try {
      debugPrint("✅ [Repository] -> updateCustomerProfile: Starting operation in repository.");
      String? avatarUrl = customer.avatarUrl;

      if (imageFile != null) {
        debugPrint(" passo [Repository] -> updateCustomerProfile: Uploading new photo...");
        avatarUrl = await remoteDataSource.uploadAvatar(imageFile);
        debugPrint("✅ [Repository] -> updateCustomerProfile: Photo upload successful.");
      }

      final customerToUpdate = CustomerModel(
        id: customer.id,
        fullName: customer.fullName,
        email: customer.email,
        phone: customer.phone,
        avatarUrl: avatarUrl,
        defaultAddressId: customer.defaultAddressId,
      );

      debugPrint(" passo [Repository] -> updateCustomerProfile: Sending information to DataSource...");
      final updatedCustomer = await remoteDataSource.updateCustomerProfile(
        customerToUpdate,
      );
      debugPrint("✅ [Repository] -> updateCustomerProfile: Information successfully saved in the database.");

      return Right(updatedCustomer);
    } on ServerException catch (e) {
      debugPrint("❌ [Repository] -> updateCustomerProfile: Server error received: ${e.message}");
      return Left(ServerFailure(message: e.message));
    }
  }
}