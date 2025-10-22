// lib/features/product/data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/option_group_entity.dart'; // <-- ایمپورت جدید
import '../../domain/entities/product_category_entity.dart'; // <-- ایمپورت جدید
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(
    int storeId,
  ) async {
    try {
      final products = await remoteDataSource.getProductsByStoreId(storeId);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // --- پیاده‌سازی متدهای جدید ---

  @override
  Future<Either<Failure, List<ProductCategoryEntity>>> getProductCategories(
      int storeId) async {
    try {
      final categories =
          await remoteDataSource.getProductCategories(storeId);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<OptionGroupEntity>>> getProductOptions(
      int productId) async {
    try {
      final options = await remoteDataSource.getProductOptions(productId);
      return Right(options);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}