// lib/features/checkout/domain/repositories/checkout_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../entities/order_entity.dart';

abstract class CheckoutRepository {
  /// یک سبد خرید را به عنوان ورودی می‌گیرد و سعی می‌کند سفارش را ثبت کند.
  /// در صورت موفقیت، اطلاعات سفارش ثبت شده ([OrderEntity]) را برمی‌گرداند.
  /// در صورت شکست، یک [Failure] برمی‌گرداند.
  Future<Either<Failure, OrderEntity>> placeOrder(CartEntity cart);
}
