// lib/features/store/domain/usecases/get_store_reviews_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/store/domain/entities/store_review_entity.dart';
import 'package:customer_app/features/store/domain/repositories/store_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetStoreReviewsUsecase
    implements UseCase<List<StoreReviewEntity>, GetStoreReviewsParams> {
  final StoreRepository repository;

  GetStoreReviewsUsecase(this.repository);

  @override
  Future<Either<Failure, List<StoreReviewEntity>>> call(
      GetStoreReviewsParams params) async {
    return await repository.getStoreReviews(params.storeId);
  }
}

class GetStoreReviewsParams extends Equatable {
  final int storeId;

  const GetStoreReviewsParams({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}