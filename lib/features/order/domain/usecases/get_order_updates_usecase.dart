// lib/features/order/domain/usecases/get_order_updates_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// --- اصلاح شد: UseCase<Stream<OrderEntity>, GetOrderUpdatesParams> ---
class GetOrderUpdatesUsecase
    implements UseCase<Stream<OrderEntity>, GetOrderUpdatesParams> {
  final OrderRepository repository;

  GetOrderUpdatesUsecase(this.repository);

  // --- اصلاح شد: call(GetOrderUpdatesParams params) ---
  @override
  Future<Either<Failure, Stream<OrderEntity>>> call(
      GetOrderUpdatesParams params) async {
    // --- اصلاح شد: repository.getOrderUpdates(params) ---
    return await repository.getOrderUpdates(params);
  }
}

class GetOrderUpdatesParams extends Equatable {
  final int orderId;

  const GetOrderUpdatesParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}