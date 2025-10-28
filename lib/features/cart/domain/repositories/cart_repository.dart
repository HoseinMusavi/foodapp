// lib/features/cart/domain/repositories/cart_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/domain/entities/option_entity.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addProductToCart(
    ProductEntity product,
    List<OptionEntity> selectedOptions,
  );

  // ✨ فیکس: امضای متدها تغییر کرد
  Future<Either<Failure, CartEntity>> removeProductFromCart(int cartItemId);
  
  Future<Either<Failure, CartEntity>> updateProductQuantity(
    int cartItemId,
    int newQuantity,
  );
}