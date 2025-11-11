// lib/features/order/domain/usecases/get_my_orders_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetMyOrdersUsecase extends UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository repository;

  GetMyOrdersUsecase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    return await repository.getMyOrders();
  }
}