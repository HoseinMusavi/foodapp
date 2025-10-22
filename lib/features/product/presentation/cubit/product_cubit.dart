// lib/features/product/presentation/cubit/product_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:customer_app/features/product/domain/usecases/get_product_categories_usecase.dart';
import 'package:customer_app/features/product/domain/usecases/get_product_options_usecase.dart';
import 'package:customer_app/features/product/domain/usecases/get_products_by_store_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';


part 'product_state.dart'; // <-- از part/part of استفاده می‌کنیم

class ProductCubit extends Cubit<ProductState> {
  final GetProductsByStoreUsecase _getProductsUsecase;
  final GetProductCategoriesUsecase _getCategoriesUsecase; // <-- جدید
  final GetProductOptionsUsecase _getOptionsUsecase; // <-- جدید

  ProductCubit({
    required GetProductsByStoreUsecase getProductsUsecase,
    required GetProductCategoriesUsecase getCategoriesUsecase, // <-- جدید
    required GetProductOptionsUsecase getOptionsUsecase, // <-- جدید
  })  : _getProductsUsecase = getProductsUsecase,
        _getCategoriesUsecase = getCategoriesUsecase,
        _getOptionsUsecase = getOptionsUsecase,
        super(ProductInitial());

  Future<void> fetchProductData(int storeId) async {
    emit(ProductLoading());
    try {
      // ۱. واکشی همزمان محصولات و دسته‌بندی‌ها
      final results = await Future.wait([
     _getProductsUsecase(Params(storeId: storeId)), // <-- قبلی: GetProductsByStoreParams
        _getCategoriesUsecase(GetCategoriesParams(storeId: storeId)),
      ]);

      final productsResult = results[0] as Either<Failure, List<ProductEntity>>;
      final categoriesResult =
          results[1] as Either<Failure, List<ProductCategoryEntity>>;

      // مدیریت خطای هر دو درخواست
      if (productsResult.isLeft() || categoriesResult.isLeft()) {
        final failure =
            productsResult.isLeft() ? productsResult.swap().getOrElse(() => ServerFailure()) : categoriesResult.swap().getOrElse(() => ServerFailure());
        
        String message = 'خطا در واکشی محصولات';
        if(failure is ServerFailure) message = failure.message;
        emit(ProductError(message));
        return;
      }

      // موفقیت‌آمیز
      final products = productsResult.getOrElse(() => []);
      final categories = categoriesResult.getOrElse(() => []);

      emit(ProductLoaded(categories: categories, products: products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // متد جدید برای واکشی آپشن‌ها وقتی کاربر روی محصول کلیک می‌کند
  Future<void> fetchProductOptions(int productId) async {
    if (state is! ProductLoaded) return; // فقط اگر دیتا لود شده باشد

    final currentState = state as ProductLoaded;
    // وضعیت لودینگ آپشن را فعال می‌کنیم
    emit(currentState.copyWith(isLoadingOptions: true, currentOptions: null));

    final failureOrOptions =
        await _getOptionsUsecase(GetOptionsParams(productId: productId));

    failureOrOptions.fold(
      (failure) => emit(ProductError('خطا در دریافت گزینه‌ها')),
      (options) {
        // اگر آپشنی وجود نداشت، null برمی‌گردانیم
        if (options.isEmpty) {
          emit(currentState.copyWith(
              isLoadingOptions: false, currentOptions: [])); // لیست خالی یعنی آپشن ندارد
        } else {
          emit(currentState.copyWith(
              isLoadingOptions: false, currentOptions: options));
        }
      },
    );
  }
}