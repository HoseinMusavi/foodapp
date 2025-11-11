// lib/features/store/presentation/cubit/dashboard_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../promotion/domain/entities/promotion_entity.dart';
import '../../../promotion/domain/usecases/get_promotions_usecase.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/get_stores_usecase.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetStoresUsecase getStoresUsecase;
  final GetPromotionsUsecase getPromotionsUsecase;

  DashboardCubit({
    required this.getStoresUsecase,
    required this.getPromotionsUsecase,
  }) : super(const DashboardState());

  /// این تابع فقط داده‌های استاتیک صفحه (بنرها) را واکشی می‌کند
  Future<void> fetchDashboardData() async {
    if (isClosed || state.promotionStatus == DataStatus.loading) return;

    emit(state.copyWith(promotionStatus: DataStatus.loading));

    final promotionsResult = await getPromotionsUsecase(NoParams());

    promotionsResult.fold(
      (failure) {
        if (isClosed) return;
        emit(state.copyWith(
          promotionStatus: DataStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ));
      },
      (promotions) {
        if (isClosed) return;
        emit(state.copyWith(
          promotionStatus: DataStatus.success,
          promotions: promotions,
        ));
        // پس از بارگیری موفق بنرها، حالا فروشگاه‌ها را بارگیری کن
        _fetchStores();
      },
    );
  }

  /// این تابع فقط فروشگاه‌ها را بر اساس فیلترهای فعلی واکشی می‌کند
  Future<void> _fetchStores() async {
    if (isClosed) return;

    // وضعیت لودینگ را فقط برای فروشگاه‌ها تنظیم کن
    emit(state.copyWith(
      storeStatus: DataStatus.loading,
      clearError: true, // پاک کردن خطای قبلی (اگر وجود داشت)
    ));

    // پارامترهای فیلتر را از state فعلی بخوان
    final params = GetStoresParams(
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      category: state.selectedCategory.isEmpty || state.selectedCategory == 'همه'
          ? null
          : state.selectedCategory,
    );

    final storesResult = await getStoresUsecase(params);

    storesResult.fold(
      (failure) {
        if (isClosed) return;
        emit(state.copyWith(
          storeStatus: DataStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ));
      },
      (stores) {
        if (isClosed) return;
        emit(state.copyWith(
          storeStatus: DataStatus.success,
          stores: stores,
        ));
      },
    );
  }

  // --- ۱. متد عمومی جدید برای فراخوانی از UI ---
  /// این متد عمومی فقط فروشگاه‌ها را رفرش می‌کند (برای Pull-to-Refresh)
  Future<void> refreshStores() async {
    await _fetchStores();
  }

  /// این تابع فقط state را آپدیت و `_fetchStores` را فراخوانی می‌کند
  void selectCategory(String category) {
    if (isClosed) return;
    final newCategory = (category == 'همه') ? '' : category;
    
    if (state.selectedCategory == newCategory) return;
    
    emit(state.copyWith(selectedCategory: newCategory));
    _fetchStores(); // واکشی مجدد *فقط* فروشگاه‌ها
  }

  /// این تابع فقط state را آپدیت و `_fetchStores` را فراخوانی می‌کند
  void searchStores(String query) {
    if (isClosed) return;
    
    if (state.searchQuery == query) return;

    emit(state.copyWith(searchQuery: query));
    _fetchStores(); // واکشی مجدد *فقط* فروشگاه‌ها
  }

  // تابع کمکی
  String _mapFailureToMessage(Failure failure) {
    return (failure is ServerFailure) ? failure.message : 'خطای ناشناخته';
  }
}