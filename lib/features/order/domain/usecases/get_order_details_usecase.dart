// lib/features/order/domain/usecases/get_order_details_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetOrderDetailsUsecase
    extends UseCase<OrderEntity, GetOrderDetailsParams> {
  final OrderRepository repository;

  GetOrderDetailsUsecase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(
      GetOrderDetailsParams params) async {
    return await repository.getOrderDetails(params.orderId);
  }
}

class GetOrderDetailsParams extends Equatable {
  final int orderId;

  const GetOrderDetailsParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}