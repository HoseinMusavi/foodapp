// lib/features/cart/domain/usecases/update_product_quantity_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class UpdateProductQuantityUsecase
    // ✨ فیکس: خروجی به CartEntity تغییر کرد
    extends UseCase<CartEntity, UpdateProductQuantityParams> {
  final CartRepository repository;

  UpdateProductQuantityUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(
      UpdateProductQuantityParams params) async {
    // ✨ فیکس: پارامترهای صحیح به ریپازیتوری پاس داده شد
    return await repository.updateProductQuantity(
      params.cartItemId,
      params.newQuantity,
    );
  }
}

class UpdateProductQuantityParams extends Equatable {
  // ✨ فیکس: پارامترها تغییر کردند
  final int cartItemId;
  final int newQuantity;

  const UpdateProductQuantityParams({
    required this.cartItemId,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [cartItemId, newQuantity];
}