// lib/features/order/domain/usecases/get_order_updates_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetOrderUpdatesUsecase
    extends UseCase<Stream<OrderEntity>, GetOrderUpdatesParams> {
  final OrderRepository repository;

  GetOrderUpdatesUsecase(this.repository);

  @override
  Future<Either<Failure, Stream<OrderEntity>>> call(
      GetOrderUpdatesParams params) async {
    return await repository.getOrderUpdates(params.orderId);
  }
}

class GetOrderUpdatesParams {
  final int orderId;

  GetOrderUpdatesParams({required this.orderId});
}