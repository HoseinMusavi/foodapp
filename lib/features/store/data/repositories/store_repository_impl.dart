// lib/features/store/data/repositories/store_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StoreEntity>>> getStores(
      LatLng location, double? radius) async {
    try {
      // پارامترها را به دیتاسورس پاس می‌دهیم
      final stores = await remoteDataSource.getStoresNearMe(location, radius);
      return Right(stores);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}