// lib/features/store/domain/usecases/get_stores_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

// این UseCase وظیفه دریافت لیست فروشگاه‌ها را بر عهده دارد.
class GetStoresUsecase implements UseCase<List<StoreEntity>, NoParams> {
  final StoreRepository repository;

  GetStoresUsecase(this.repository);

  // چون برای دریافت لیست تمام فروشگاه‌ها پارامتری نیاز نداریم، از کلاس NoParams استفاده می‌کنیم.
  @override
  Future<Either<Failure, List<StoreEntity>>> call(NoParams params) async {
    return await repository.getStores();
  }
}
