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

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    // دریافت همزمان داده‌ها
    final results = await Future.wait([
      getPromotionsUsecase(NoParams()),
      getStoresUsecase(NoParams()),
    ]);

    final promotionsResult =
        results[0] as Either<Failure, List<PromotionEntity>>;
    final storesResult = results[1] as Either<Failure, List<StoreEntity>>;

    promotionsResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DashboardStatus.failure,
            errorMessage: 'خطا در دریافت تبلیغات',
          ),
        );
      },
      (promotions) {
        storesResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: DashboardStatus.failure,
                errorMessage: 'خطا در دریافت فروشگاه‌ها',
              ),
            );
          },
          (stores) {
            emit(
              state.copyWith(
                status: DashboardStatus.success,
                promotions: promotions,
                stores: stores,
              ),
            );
          },
        );
      },
    );
  }

  void selectCategory(String categori) {}
}
