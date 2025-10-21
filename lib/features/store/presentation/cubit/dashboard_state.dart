// lib/features/store/presentation/cubit/dashboard_state.dart

part of 'dashboard_cubit.dart';

// An enum to represent the different statuses of the state
enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<StoreEntity> stores;
  final List<PromotionEntity> promotions;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stores = const [],
    this.promotions = const [],
    this.errorMessage,
  });

  // A helper method to create a copy of the state with new values
  DashboardState copyWith({
    DashboardStatus? status,
    List<StoreEntity>? stores,
    List<PromotionEntity>? promotions,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
      promotions: promotions ?? this.promotions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stores, promotions, errorMessage];
}
