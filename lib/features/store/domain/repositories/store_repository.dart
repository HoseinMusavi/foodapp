// lib/features/store/domain/repositories/store_repository.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/store/domain/entities/store_review_entity.dart';
import 'package:customer_app/features/store/domain/usecases/get_stores_usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/store_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreEntity>>> getStores(GetStoresParams params);

  // --- متد جدید (بخش ۳) ---
  Future<Either<Failure, List<StoreReviewEntity>>> getStoreReviews(int storeId);
  // ---
}