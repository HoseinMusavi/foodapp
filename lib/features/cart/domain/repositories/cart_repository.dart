// lib/features/cart/domain/repositories/cart_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  /// وضعیت فعلی سبد خرید را برمی‌گرداند.
  Future<Either<Failure, CartEntity>> getCart();

  /// یک محصول را به سبد خرید اضافه می‌کند.
  /// اگر محصول از قبل وجود داشته باشد، تعداد آن را یکی اضافه می‌کند.
  /// در نهایت، وضعیت جدید و به‌روز شده سبد خرید را برمی‌گرداند.
  Future<Either<Failure, CartEntity>> addProductToCart(ProductEntity product);

  /// یک محصول را به طور کامل از سبد خرید حذف می‌کند.
  Future<Either<Failure, CartEntity>> removeProductFromCart(
    ProductEntity product,
  );

  /// تعداد یک محصول مشخص در سبد خرید را تغییر می‌دهد.
  /// اگر تعداد به صفر برسد، محصول حذف می‌شود.
  Future<Either<Failure, CartEntity>> updateProductQuantity(
    ProductEntity product,
    int newQuantity,
  );
}
