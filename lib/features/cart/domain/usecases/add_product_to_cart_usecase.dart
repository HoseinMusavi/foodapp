// lib/features/cart/domain/usecases/add_product_to_cart_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/product_entity.dart';
// ✨ ایمپورت OptionEntity
import '../../../product/domain/entities/option_entity.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class AddProductToCartUsecase
    extends UseCase<CartEntity, AddProductToCartParams> {
  final CartRepository repository;

  AddProductToCartUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(AddProductToCartParams params) async {
    return await repository.addProductToCart(
      params.product,
      // ✨ آپشن‌ها به ریپازیتوری پاس داده می‌شوند
      params.selectedOptions,
    );
  }
}

class AddProductToCartParams extends Equatable {
  final ProductEntity product;
  // ✨ اضافه شد: لیستی برای نگهداری آپشن‌های انتخاب شده
  final List<OptionEntity> selectedOptions;

  const AddProductToCartParams({
    required this.product,
    // ✨ اضافه شد: آپشن‌ها در کانستراکتور
    required this.selectedOptions,
  });

  @override
  // ✨ اضافه شد: آپشن‌ها به props
  List<Object> get props => [product, selectedOptions];
}