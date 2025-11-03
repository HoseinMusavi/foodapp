// lib/features/store/domain/repositories/store_repository.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StoreRepository {
  // --- اصلاح امضای متد برای دریافت پارامترهای فیلتر ---
  Future<Either<Failure, List<StoreEntity>>> getStores({
    String? searchQuery,
    String? category,
  });
}