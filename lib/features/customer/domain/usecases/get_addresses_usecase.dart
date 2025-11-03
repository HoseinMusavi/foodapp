import 'package:dartz/dartz.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';

class GetAddressesUsecase extends UseCase<List<AddressEntity>, NoParams> {
  final CustomerRepository repository;

  GetAddressesUsecase(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(NoParams params) async {
    return await repository.getAddresses();
  }
}