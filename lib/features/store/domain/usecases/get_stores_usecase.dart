// lib/features/store/domain/usecases/get_stores_usecase.dart

import 'package:dartz/dartz.dart';
// 1. --- حذف ایمپورت‌های Equatable و LatLng ---
// import 'package:equatable/equatable.dart';
// import '../../../../core/utils/lat_lng.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart'; // NoParams را ایمپورت می‌کنیم
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

// 2. --- پارامتر GetStoresParams را به NoParams برمی‌گردانیم ---
class GetStoresUsecase implements UseCase<List<StoreEntity>, NoParams> {
  final StoreRepository repository;

  GetStoresUsecase(this.repository);

  // 3. --- نوع پارامتر ورودی به NoParams تغییر کرد ---
  @override
  Future<Either<Failure, List<StoreEntity>>> call(NoParams params) async {
    // 4. --- دیگر پارامتری برای پاس دادن به ریپازیتوری نداریم ---
    return await repository.getStores();
  }
}

// 5. --- کلاس GetStoresParams کامل حذف شد ---
// class GetStoresParams extends Equatable { ... }