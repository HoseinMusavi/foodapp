// lib/features/product/data/repositories/product_repository_impl.dart
import 'package:customer_app/features/product/domain/entities/option_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_category_entity.dart'; // ایمپورت Entity
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
// ایمپورت مدل‌ها برای map کردن لازم است
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
      // تبدیل صریح برای اطمینان (هرچند ضمنی هم کار می‌کند)
      final List<ProductEntity> productEntities = productModels
          .map((model) => model as ProductEntity)
          .toList();
      return Right(productEntities);
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
      // --- *** مهم: تبدیل صریح Model به Entity *** ---
      // این اطمینان می‌دهد که نوع لیست دقیقاً List<ProductCategoryEntity> است
      final List<ProductCategoryEntity> categoryEntities = categoryModels
          .map((model) => ProductCategoryEntity( // ساخت Entity جدید
                 id: model.id,
                 storeId: model.storeId,
                 name: model.name,
                 sortOrder: model.sortOrder,
              ))
          .toList();
      return Right(categoryEntities);
      // ---------------------------------------------
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
       // تبدیل صریح برای اطمینان
       final List<OptionGroupEntity> optionGroupEntities = optionGroupModels
           .map((model) => OptionGroupEntity( // ساخت Entity جدید
                  id: model.id,
                  storeId: model.storeId,
                  name: model.name,
                  // آپشن‌های داخلی هم باید Entity باشند
                  options: model.options.map((optModel) => OptionEntity(
                     id: optModel.id,
                     optionGroupId: optModel.optionGroupId,
                     name: optModel.name,
                     priceDelta: optModel.priceDelta
                  )).toList(),
            ))
           .toList();
      return Right(optionGroupEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
       return Left(ServerFailure(message: e.toString()));
    }
  }
}