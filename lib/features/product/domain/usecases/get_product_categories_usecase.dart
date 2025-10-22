// lib/features/product/domain/usecases/get_product_categories_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_category_entity.dart';
import '../repositories/product_repository.dart';

class GetProductCategoriesUsecase
    implements UseCase<List<ProductCategoryEntity>, GetCategoriesParams> {
  final ProductRepository repository;

  GetProductCategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductCategoryEntity>>> call(
      GetCategoriesParams params) async {
    return await repository.getProductCategories(params.storeId);
  }
}

class GetCategoriesParams extends Equatable {
  final int storeId;

  const GetCategoriesParams({required this.storeId});

  @override
  List<Object> get props => [storeId];
}