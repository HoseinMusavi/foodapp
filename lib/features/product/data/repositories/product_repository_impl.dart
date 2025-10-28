// lib/features/product/data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
// ایمپورت مدل‌ها برای تبدیل لازم است
import '../models/product_category_model.dart';
import '../models/product_model.dart';
import '../models/option_group_model.dart';


class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(
    int storeId,
  ) async {
    try {
      final productModels = await remoteDataSource.getProductsByStoreId(storeId);
      // تبدیل ضمنی به Entity (چون ProductModel extends ProductEntity)
      // برای اطمینان می‌توان صریحاً map کرد:
      // final List<ProductEntity> productEntities = productModels.map((model) => model as ProductEntity).toList();
      // return Right(productEntities);
      return Right(productModels); // تبدیل ضمنی معمولاً کافی است
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
       return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductCategoryEntity>>> getProductCategories(
      int storeId) async {
    try {
      final categoryModels =
          await remoteDataSource.getProductCategories(storeId);
      // --- ۱. تبدیل صریح Model به Entity ---
      // این اطمینان حاصل می‌کند که نوع لیست دقیقاً List<ProductCategoryEntity> است
      final List<ProductCategoryEntity> categoryEntities = categoryModels
          .map((model) => model as ProductCategoryEntity) // هر مدل یک Entity هم هست
          .toList();
      return Right(categoryEntities);
      // ------------------------------------
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
       return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OptionGroupEntity>>> getProductOptions(
      int productId) async {
    try {
      final optionGroupModels = await remoteDataSource.getProductOptions(productId);
       // تبدیل ضمنی به Entity
       // برای اطمینان می‌توان صریحاً map کرد:
       // final List<OptionGroupEntity> optionGroupEntities = optionGroupModels.map((model) => model as OptionGroupEntity).toList();
       // return Right(optionGroupEntities);
      return Right(optionGroupModels); // تبدیل ضمنی معمولاً کافی است
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
       return Left(ServerFailure(message: e.toString()));
    }
  }
}