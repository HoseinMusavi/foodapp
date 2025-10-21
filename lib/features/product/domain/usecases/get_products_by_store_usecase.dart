// lib/features/product/domain/usecases/get_products_by_store_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByStoreUsecase
    implements UseCase<List<ProductEntity>, Params> {
  final ProductRepository repository;

  GetProductsByStoreUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(Params params) async {
    return await repository.getProductsByStore(params.storeId);
  }
}

// برای ارسال پارامترها به UseCase به شکلی ساختاریافته، از این کلاس استفاده می‌کنیم.
class Params extends Equatable {
  final int storeId;

  const Params({required this.storeId});

  @override
  List<Object> get props => [storeId];
}
