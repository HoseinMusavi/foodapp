// lib/features/cart/domain/usecases/remove_product_from_cart_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class RemoveProductFromCartUsecase
    // ✨ فیکس: خروجی به CartEntity تغییر کرد
    extends UseCase<CartEntity, RemoveProductFromCartUsecaseParams> {
  final CartRepository repository;

  RemoveProductFromCartUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(
      RemoveProductFromCartUsecaseParams params) async {
    // ✨ فیکس: cartItemId به ریپازیتوری پاس داده شد
    return await repository.removeProductFromCart(params.cartItemId);
  }
}

class RemoveProductFromCartUsecaseParams extends Equatable {
  // ✨ فیکس: پارامتر به cartItemId تغییر کرد
  final int cartItemId;

  const RemoveProductFromCartUsecaseParams({required this.cartItemId});

  @override
  List<Object> get props => [cartItemId];
}