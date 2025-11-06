// lib/features/store/data/repositories/store_repository_impl.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/store/data/datasources/store_remote_datasource.dart';
import 'package:customer_app/features/store/domain/entities/store_review_entity.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:customer_app/features/store/domain/repositories/store_repository.dart';
import 'package:customer_app/features/store/domain/usecases/get_stores_usecase.dart';
import 'package:dartz/dartz.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  // TODO: Add network info
  StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StoreEntity>>> getStores(
      GetStoresParams params) async {
    try {
      final stores = await remoteDataSource.getFilteredStores(
        searchQuery: params.searchQuery,
        category: params.category,
      );
      return Right(stores);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
    // TODO: Add offline/cache failure
  }

  // --- متد جدید (بخش ۳) ---
  @override
  Future<Either<Failure, List<StoreReviewEntity>>> getStoreReviews(
      int storeId) async {
    try {
      final reviews = await remoteDataSource.getStoreReviews(storeId);
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'خطای ناشناخته: ${e.toString()}'));
    }
  }
  // ---
}