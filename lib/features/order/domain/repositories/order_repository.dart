// lib/features/order/domain/repositories/order_repository.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/domain/usecases/get_order_details_usecase.dart';
import 'package:customer_app/features/order/domain/usecases/get_order_updates_usecase.dart';
import 'package:customer_app/features/order/domain/usecases/submit_store_review_usecase.dart';
import 'package:dartz/dartz.dart';

abstract class OrderRepository {
  Future<Either<Failure, Stream<OrderEntity>>> getOrderUpdates(
      GetOrderUpdatesParams params);
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  Future<Either<Failure, OrderEntity>> getOrderDetails(
      GetOrderDetailsParams params);

  // --- متد جدید (بخش ۲) ---
  Future<Either<Failure, void>> submitStoreReview(
      SubmitStoreReviewParams params);
  // ---
  
  // --- متد جدید (بخش ۱.۳) ---
  Future<Either<Failure, Set<int>>> getReviewedOrderIds();
  // ---
}