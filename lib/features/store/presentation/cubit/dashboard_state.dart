// lib/features/store/presentation/cubit/dashboard_state.dart

part of 'dashboard_cubit.dart';

// ۱. --- تفکیک وضعیت‌ها برای بخش‌های مختلف صفحه ---
enum DataStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  // --- وضعیت و داده‌های تبلیغات ---
  final DataStatus promotionStatus;
  final List<PromotionEntity> promotions;

  // --- وضعیت و داده‌های فروشگاه‌ها ---
  final DataStatus storeStatus;
  final List<StoreEntity> stores;

  // --- وضعیت فیلترها ---
  final String selectedCategory;
  final String searchQuery;

  // --- وضعیت خطا ---
  final String? errorMessage;

  const DashboardState({
    this.promotionStatus = DataStatus.initial,
    this.promotions = const [],
    this.storeStatus = DataStatus.initial,
    this.stores = const [],
    this.selectedCategory = '',
    this.searchQuery = '',
    this.errorMessage,
  });

  DashboardState copyWith({
    DataStatus? promotionStatus,
    List<PromotionEntity>? promotions,
    DataStatus? storeStatus,
    List<StoreEntity>? stores,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      promotionStatus: promotionStatus ?? this.promotionStatus,
      promotions: promotions ?? this.promotions,
      storeStatus: storeStatus ?? this.storeStatus,
      stores: stores ?? this.stores,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        promotionStatus,
        promotions,
        storeStatus,
        stores,
        selectedCategory,
        searchQuery,
        errorMessage
      ];
}