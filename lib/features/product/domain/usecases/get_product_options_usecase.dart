// lib/features/product/domain/usecases/get_product_options_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/option_group_entity.dart';
import '../repositories/product_repository.dart';

class GetProductOptionsUsecase
    implements UseCase<List<OptionGroupEntity>, GetOptionsParams> {
  final ProductRepository repository;

  GetProductOptionsUsecase(this.repository);

  @override
  Future<Either<Failure, List<OptionGroupEntity>>> call(
      GetOptionsParams params) async {
    return await repository.getProductOptions(params.productId);
  }
}

class GetOptionsParams extends Equatable {
  final int productId;

  const GetOptionsParams({required this.productId});

  @override
  List<Object> get props => [productId];
}