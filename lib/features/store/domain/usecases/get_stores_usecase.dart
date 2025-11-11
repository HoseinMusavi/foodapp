// lib/features/store/domain/usecases/get_stores_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoresUsecase implements UseCase<List<StoreEntity>, GetStoresParams> {
  final StoreRepository repository;

  GetStoresUsecase(this.repository);

  @override
  Future<Either<Failure, List<StoreEntity>>> call(
      GetStoresParams params) async {
    // --- اصلاح شد: repository.getStores(params) ---
    return await repository.getStores(params);
  }
}

class GetStoresParams extends Equatable {
  final String? searchQuery;
  final String? category;

  const GetStoresParams({this.searchQuery, this.category});

  @override
  List<Object?> get props => [searchQuery, category];
}