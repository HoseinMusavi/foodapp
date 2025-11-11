import 'package:dartz/dartz.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';

class AddAddressUsecase extends UseCase<void, AddressEntity> {
  final CustomerRepository repository;

  AddAddressUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddressEntity params) async {
    return await repository.addAddress(params);
  }
}