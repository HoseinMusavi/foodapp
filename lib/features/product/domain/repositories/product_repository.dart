// lib/features/product/domain/repositories/product_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  /// این تابع لیستی از محصولات را بر اساس شناسه فروشگاه دریافت می‌کند.
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(int storeId);
}
