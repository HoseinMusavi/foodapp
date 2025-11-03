import 'package:dartz/dartz.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerEntity>> getCustomerDetails();
  Future<Either<Failure, CustomerEntity>> updateCustomerProfile(
      CustomerEntity customer);

  // دو متد زیر را اضافه کنید
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, void>> addAddress(AddressEntity address);
}