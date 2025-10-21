// lib/features/store/data/repositories/store_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart'; // ‼️ CHANGE IMPORT

class StoreRepositoryImpl implements StoreRepository {
  // --- ‼️ CHANGE: Use the real remote data source ---
  final StoreRemoteDataSource remoteDataSource;

  // --- ‼️ CHANGE: Update the constructor ---
  StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StoreEntity>>> getStores() async {
    try {
      // --- ‼️ CHANGE: Call the method from the real data source ---
      final stores = await remoteDataSource.getAllStores();
      return Right(stores);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
