// lib/features/product/presentation/cubit/product_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_by_store_usecase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsByStoreUsecase getProductsByStoreUsecase;

  ProductCubit({required this.getProductsByStoreUsecase})
    : super(ProductLoading());

  Future<void> fetchProductsByStore(int storeId) async {
    emit(ProductLoading());
    final failureOrProducts = await getProductsByStoreUsecase(
      Params(storeId: storeId),
    );

    failureOrProducts.fold(
      (failure) {
        emit(const ProductError('خطا در دریافت محصولات فروشگاه'));
      },
      (products) {
        emit(ProductLoaded(products));
      },
    );
  }
}
