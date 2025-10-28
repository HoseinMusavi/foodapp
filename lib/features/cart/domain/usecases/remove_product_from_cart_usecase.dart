// lib/features/cart/domain/usecases/remove_product_from_cart_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

// ۱. تغییر در تعریف کلاس: به جای Params از نام جدید استفاده می‌کنیم
class RemoveProductFromCartUsecase
    implements UseCase<CartEntity, RemoveProductFromCartUsecaseParams> {
  final CartRepository repository;

  RemoveProductFromCartUsecase(this.repository);

  @override
  // ۲. تغییر در متد call
  Future<Either<Failure, CartEntity>> call(
    RemoveProductFromCartUsecaseParams params,
  ) async {
    return await repository.removeProductFromCart(params.product);
  }
}

// ۳. تغییر نام کلاس پارامتر
class RemoveProductFromCartUsecaseParams extends Equatable {
  final ProductEntity product;

  // ۴. تغییر نام سازنده (Constructor)
  const RemoveProductFromCartUsecaseParams({required this.product});

  @override
  List<Object> get props => [product];
}
