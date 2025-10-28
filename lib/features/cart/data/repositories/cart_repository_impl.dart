// lib/features/cart/data/repositories/cart_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

// This class now implements the real logic
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CartEntity>> addProductToCart(
    ProductEntity product,
  ) async {
    try {
      await remoteDataSource.addProductToCart(product.id);
      // After adding, fetch the whole cart again to ensure consistency
      return getCart();
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cartItems = await remoteDataSource.getCartItems();
      // The entity list is converted from the model list
      return Right(CartEntity(items: cartItems));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeProductFromCart(
    ProductEntity product,
  ) async {
    try {
      await remoteDataSource.removeProductFromCart(product.id);
      return getCart();
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateProductQuantity(
    ProductEntity product,
    int newQuantity,
  ) async {
    try {
      await remoteDataSource.updateProductQuantity(product.id, newQuantity);
      return getCart();
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
