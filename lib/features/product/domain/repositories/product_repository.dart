// lib/features/product/domain/repositories/product_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/option_group_entity.dart'; // <-- ایمپورت جدید
import '../entities/product_category_entity.dart'; // <-- ایمپورت جدید
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(int storeId);

  // --- متدهای جدید ---
  Future<Either<Failure, List<ProductCategoryEntity>>> getProductCategories(
      int storeId);
  Future<Either<Failure, List<OptionGroupEntity>>> getProductOptions(
      int productId);
  // --------------------
}