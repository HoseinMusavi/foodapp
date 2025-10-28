// lib/features/cart/domain/usecases/add_product_to_cart_usecase.dart

import 'package:customer_app/features/cart/domain/entities/cart_entity.dart';
import 'package:customer_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:customer_app/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class AddProductToCartUsecase
    implements UseCase<CartEntity, AddProductToCartParams> {
  final CartRepository repository;

  AddProductToCartUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(
    AddProductToCartParams params,
  ) async {
    return await repository.addProductToCart(params.product);
  }
}

class AddProductToCartParams extends Equatable {
  final ProductEntity product;

  const AddProductToCartParams({required this.product});

  @override
  List<Object> get props => [product];
}
