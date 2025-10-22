// lib/features/store/domain/repositories/store_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت
import '../entities/store_entity.dart';

abstract class StoreRepository {
  /// این تابع لیستی از فروشگاه‌ها را بر اساس موقعیت مکانی دریافت می‌کند
  Future<Either<Failure, List<StoreEntity>>> getStores(
      LatLng location, double? radius);
}