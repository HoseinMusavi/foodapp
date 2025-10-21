// lib/features/promotion/data/repositories/promotion_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_datasource.dart'; // ‼️ CHANGE IMPORT

class FakePromotionRepositoryImpl implements PromotionRepository {
  // --- ‼️ CHANGE: Use the real remote data source ---
  final PromotionRemoteDataSource remoteDataSource;

  // --- ‼️ CHANGE: Update the constructor ---
  FakePromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotions() async {
    try {
      // --- ‼️ CHANGE: Call the method from the real data source ---
      final promotions = await remoteDataSource.getPromotions();
      return Right(promotions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
