// lib/features/order/data/repositories/order_repository_impl.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/data/datasources/order_remote_datasource.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remoteDatasource;

  OrderRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, Stream<OrderEntity>>> getOrderUpdates(
      int orderId) async {
    try {
      final stream = remoteDatasource.getOrderUpdates(orderId);
      return Right(stream);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ****** 1. این متد اضافه شد ******
  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async {
    try {
      final orderDetails = await remoteDatasource.getOrderDetails(orderId);
      return Right(orderDetails);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch order details: $e'));
    }
  }
  // ****** پایان بخش اضافه شده ******

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    try {
      final orders = await remoteDatasource.getMyOrders();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch orders: $e'));
    }
  }
}