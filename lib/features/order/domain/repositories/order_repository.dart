// lib/features/order/domain/repositories/order_repository.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:dartz/dartz.dart';

abstract class OrderRepository {
  Future<Either<Failure, Stream<OrderEntity>>> getOrderUpdates(int orderId);
  
  // ****** 1. این متد اضافه شد ******
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId);

  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
}