// lib/features/promotion/domain/repositories/promotion_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<Either<Failure, List<PromotionEntity>>> getPromotions();
}
