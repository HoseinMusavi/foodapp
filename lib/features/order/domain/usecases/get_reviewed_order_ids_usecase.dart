// lib/features/order/domain/usecases/get_reviewed_order_ids_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetReviewedOrderIdsUsecase implements UseCase<Set<int>, NoParams> {
  final OrderRepository repository;

  GetReviewedOrderIdsUsecase(this.repository);

  @override
  Future<Either<Failure, Set<int>>> call(NoParams params) async {
    return await repository.getReviewedOrderIds();
  }
}