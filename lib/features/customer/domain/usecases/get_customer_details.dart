import 'package:customer_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomerDetails implements UseCase<CustomerEntity, NoParams> {
  final CustomerRepository repository;
  GetCustomerDetails(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(NoParams params) async {
    return await repository.getCustomerDetails();
  }
}
