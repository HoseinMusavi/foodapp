import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerEntity>> getCustomerDetails();
  Future<Either<Failure, CustomerEntity>> updateCustomerProfile(
    CustomerEntity customer,
    File? imageFile,
  );
}