// lib/features/store/data/repositories/store_repository_impl.dart


import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
// 1. --- حذف ایمپورت LatLng ---
// import '../../../../core/utils/lat_lng.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  // 2. --- حذف پارامترها از تعریف متد ---
  @override
  Future<Either<Failure, List<StoreEntity>>> getStores() async {
    try {
      // 3. --- فراخوانی متد صحیح دیتاسورس (بدون پارامتر) ---
      final stores = await remoteDataSource.getAllStores(); // قبلی: getStoresNearMe(location, radius)
      return Right(stores);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) { // افزودن catch عمومی برای خطاهای غیرمنتظره
      return Left(ServerFailure(message: e.toString()));
    }
  }
}