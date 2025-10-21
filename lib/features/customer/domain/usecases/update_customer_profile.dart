import 'dart:io';
import 'package:customer_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerProfile
    implements UseCase<CustomerEntity, UpdateCustomerParams> {
  final CustomerRepository repository;
  UpdateCustomerProfile(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(
    UpdateCustomerParams params,
  ) async {
    return await repository.updateCustomerProfile(
      params.customer,
      params.imageFile,
    );
  }
}

class UpdateCustomerParams {
  final CustomerEntity customer;
  final File? imageFile;
  UpdateCustomerParams({required this.customer, this.imageFile});
}