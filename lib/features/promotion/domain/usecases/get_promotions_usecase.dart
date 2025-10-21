// lib/features/promotion/domain/usecases/get_promotions_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetPromotionsUsecase implements UseCase<List<PromotionEntity>, NoParams> {
  final PromotionRepository repository;

  GetPromotionsUsecase(this.repository);

  @override
  Future<Either<Failure, List<PromotionEntity>>> call(NoParams params) async {
    return await repository.getPromotions();
  }
}
