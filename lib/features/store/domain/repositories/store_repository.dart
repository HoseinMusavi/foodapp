// lib/features/store/domain/repositories/store_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
// 1. --- حذف ایمپورت LatLng ---
// import '../../../../core/utils/lat_lng.dart';
import '../entities/store_entity.dart';

abstract class StoreRepository {
  // 2. --- حذف پارامترها از تعریف متد ---
  Future<Either<Failure, List<StoreEntity>>> getStores();
}