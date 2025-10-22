// lib/features/store/domain/usecases/get_stores_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart'; // <-- ایمپورت
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت کلاس کمکی
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

// Usecase حالا پارامتر می‌گیرد، پس NoParams را حذف می‌کنیم
class GetStoresUsecase implements UseCase<List<StoreEntity>, GetStoresParams> {
  final StoreRepository repository;

  GetStoresUsecase(this.repository);

  // پارامتر ورودی از NoParams به GetStoresParams تغییر کرد
  @override
  Future<Either<Failure, List<StoreEntity>>> call(GetStoresParams params) async {
    // پارامترها را به ریپازیتوری پاس می‌دهیم
    return await repository.getStores(params.location, params.radius);
  }
}

// کلاس جدید برای پارامترهای ورودی
class GetStoresParams extends Equatable {
  final LatLng location;
  final double? radius; // شعاع (اختیاری)

  const GetStoresParams({required this.location, this.radius});

  @override
  List<Object?> get props => [location, radius];
}