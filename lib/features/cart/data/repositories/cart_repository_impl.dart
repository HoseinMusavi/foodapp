// lib/features/cart/data/repositories/cart_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/domain/entities/option_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final remoteCartItems = await remoteDataSource.getCartItems();
      final cartEntity = CartModel(items: remoteCartItems);
      return Right(cartEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addProductToCart(
    ProductEntity product,
    List<OptionEntity> selectedOptions,
  ) async {
    try {
      await remoteDataSource.addProductToCart(product, selectedOptions);
      // پس از افزودن، سبد خرید کامل را دوباره واکشی می‌کنیم
      return await getCart();
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  // ✨ فیکس: امضای متد و منطق داخلی آن اصلاح شد
  Future<Either<Failure, CartEntity>> removeProductFromCart(
    int cartItemId,
  ) async {
    try {
      await remoteDataSource.removeProductFromCart(cartItemId);
      // پس از حذف، سبد خرید کامل را دوباره واکشی می‌کنیم
      return await getCart();
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  // ✨ فیکس: امضای متد و منطق داخلی آن اصلاح شد
  Future<Either<Failure, CartEntity>> updateProductQuantity(
    int cartItemId,
    int newQuantity,
  ) async {
    try {
      await remoteDataSource.updateProductQuantity(cartItemId, newQuantity);
      // پس از به‌روزرسانی، سبد خرید کامل را دوباره واکشی می‌کنیم
      return await getCart();
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}