// lib/features/cart/domain/usecases/get_cart_usecase.dart

import 'package:customer_app/features/cart/domain/entities/cart_entity.dart';
import 'package:customer_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class GetCartUsecase implements UseCase<CartEntity, NoParams> {
  final CartRepository repository;

  GetCartUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(NoParams params) async {
    return await repository.getCart();
  }
}
