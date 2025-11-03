// lib/features/store/domain/usecases/get_stores_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:customer_app/features/store/domain/repositories/store_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// ۱. --- تغییر Usecase برای دریافت پارامتر ---
class GetStoresUsecase
    implements UseCase<List<StoreEntity>, GetStoresParams> {
  final StoreRepository repository;

  GetStoresUsecase(this.repository);

  @override
  Future<Either<Failure, List<StoreEntity>>> call(
      GetStoresParams params) async {
    // ۲. --- ارسال پارامترها به ریپازیتوری ---
    return await repository.getStores(
      searchQuery: params.searchQuery,
      category: params.category,
    );
  }
}

// ۳. --- ایجاد کلاس Params برای نگهداری پارامترهای فیلتر ---
class GetStoresParams extends Equatable {
  final String? searchQuery;
  final String? category;

  const GetStoresParams({this.searchQuery, this.category});

  @override
  List<Object?> get props => [searchQuery, category];
}