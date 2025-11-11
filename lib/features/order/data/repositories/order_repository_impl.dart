// lib/features/order/data/repositories/order_repository_impl.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';

import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/data/datasources/order_remote_datasource.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:customer_app/features/order/domain/usecases/get_order_details_usecase.dart';
import 'package:customer_app/features/order/domain/usecases/get_order_updates_usecase.dart';
import 'package:customer_app/features/order/domain/usecases/submit_store_review_usecase.dart';
import 'package:dartz/dartz.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remoteDatasource;

  OrderRepositoryImpl({required this.remoteDatasource});

  // --- اصلاح شد: تمام catch ها اکنون (e, s) هستند تا Error ها را هم بگیرند ---

  @override
  Future<Either<Failure, void>> submitStoreReview(
      SubmitStoreReviewParams params) async {
    try {
      await remoteDatasource.submitStoreReview(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, s) { 
      print('OrderRepositoryImpl Error (submitStoreReview): $e\n$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Set<int>>> getReviewedOrderIds() async {
    try {
      final ids = await remoteDatasource.getReviewedOrderIds();
      return Right(ids);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, s) { 
      print('OrderRepositoryImpl Error (getReviewedOrderIds): $e\n$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    try {
      final orders = await remoteDatasource.getMyOrders();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, s) { 
      print('OrderRepositoryImpl Error (getMyOrders): $e\n$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Stream<OrderEntity>>> getOrderUpdates(
      GetOrderUpdatesParams params) async {
    try {
      final stream = remoteDatasource.getOrderUpdates(params.orderId);
      return Right(stream);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, s) { 
      print('OrderRepositoryImpl Error (getOrderUpdates): $e\n$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(
      GetOrderDetailsParams params) async {
    try {
      final order = await remoteDatasource.getOrderDetails(params.orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e, s) { 
      print('OrderRepositoryImpl Error (getOrderDetails): $e\n$s');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}