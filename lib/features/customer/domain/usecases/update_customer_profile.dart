import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

// UseCase حالا CustomerEntity را به عنوان پارامتر می پذیرد
class UpdateCustomerProfile extends UseCase<CustomerEntity, CustomerEntity> {
  final CustomerRepository repository;

  UpdateCustomerProfile(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(CustomerEntity params) async {
    // پارامتر دریافتی (params) همان CustomerEntity است
    return await repository.updateCustomerProfile(params);
  }
}