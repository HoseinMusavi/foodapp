// lib/features/store/data/repositories/store_repository_impl.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:customer_app/features/store/domain/repositories/store_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../datasources/store_remote_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  // --- پیاده‌سازی متد جدید ---
  @override
  Future<Either<Failure, List<StoreEntity>>> getStores({
    String? searchQuery,
    String? category,
  }) async {
    try {
      // --- فراخوانی متد جدید از datasource ---
      final stores = await remoteDataSource.getFilteredStores(
        searchQuery: searchQuery,
        category: category,
      );
      return Right(stores);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}