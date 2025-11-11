// lib/features/order/domain/usecases/submit_store_review_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SubmitStoreReviewUsecase implements UseCase<void, SubmitStoreReviewParams> {
  final OrderRepository repository;

  SubmitStoreReviewUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitStoreReviewParams params) async {
    // اعتبار سنجی ورودی (معیار پذیرش ۲.۴)
    if (params.rating < 1 || params.rating > 5) {
      return Left(ServerFailure(message: 'امتیاز باید بین ۱ تا ۵ باشد.'));
    }

    return await repository.submitStoreReview(params);
  }
}

class SubmitStoreReviewParams extends Equatable {
  final int orderId;
  final int storeId;
  final int rating;
  final String? comment;

  const SubmitStoreReviewParams({
    required this.orderId,
    required this.storeId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [orderId, storeId, rating, comment];
}