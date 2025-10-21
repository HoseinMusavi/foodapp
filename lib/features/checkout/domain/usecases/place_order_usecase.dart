// lib/features/checkout/domain/usecases/place_order_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/checkout_repository.dart';

class PlaceOrderUsecase implements UseCase<OrderEntity, PlaceOrderParams> {
  final CheckoutRepository repository;

  PlaceOrderUsecase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) async {
    return await repository.placeOrder(params.cart);
  }
}

class PlaceOrderParams extends Equatable {
  final CartEntity cart;

  const PlaceOrderParams({required this.cart});

  @override
  List<Object> get props => [cart];
}
