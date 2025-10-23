// lib/features/store/presentation/cubit/dashboard_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
// 1. --- حذف ایمپورت‌های geolocator و LatLng ---
// import 'package:geolocator/geolocator.dart';
// import '../../../../core/utils/lat_lng.dart';
import '../../../../core/usecase/usecase.dart'; // NoParams را لازم داریم
import '../../../promotion/domain/entities/promotion_entity.dart';
import '../../../promotion/domain/usecases/get_promotions_usecase.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/get_stores_usecase.dart'; // GetStoresUsecase را لازم داریم

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetStoresUsecase getStoresUsecase;
  final GetPromotionsUsecase getPromotionsUsecase;

  DashboardCubit({
    required this.getStoresUsecase,
    required this.getPromotionsUsecase,
  }) : super(const DashboardState());

  Future<void> fetchDashboardData() async {
    if (isClosed) return;
    // حالت لودینگ را فقط اگر اولین بار است یا stores خالی است emit می‌کنیم
    // تا در رفرش‌های بعدی، لیست قبلی نمایش داده شود
    if (state.stores.isEmpty) {
       emit(state.copyWith(status: DashboardStatus.loading));
    } else {
      // اگر لیست خالی نیست، فقط status را loading می‌کنیم تا RefreshIndicator کار کند
      emit(state.copyWith(status: DashboardStatus.loading));
    }


    // 2. --- دریافت موقعیت مکانی حذف شد ---

    // دریافت همزمان داده‌ها با NoParams برای فروشگاه‌ها
    final results = await Future.wait([
      getPromotionsUsecase(NoParams()),
      getStoresUsecase(NoParams()), // <-- 3. تغییر به NoParams
    ]);

    if (isClosed) return;

    final promotionsResult =
        results[0] as Either<Failure, List<PromotionEntity>>;
    final storesResult = results[1] as Either<Failure, List<StoreEntity>>;

    // بررسی خطاها
    String? errorMessage;
    if (promotionsResult.isLeft()) {
       final failure = promotionsResult.swap().getOrElse(() => ServerFailure());
       errorMessage = (failure is ServerFailure) ? failure.message : 'خطا در دریافت تبلیغات';
    } else if (storesResult.isLeft()) {
       final failure = storesResult.swap().getOrElse(() => ServerFailure());
       errorMessage = (failure is ServerFailure) ? failure.message : 'خطا در دریافت فروشگاه‌ها';
    }

    if (errorMessage != null) {
      if (!isClosed) {
        emit(state.copyWith(status: DashboardStatus.failure, errorMessage: errorMessage));
      }
      return; // در صورت خطا، ادامه نده
    }

    // اگر هر دو موفق بودند
    final promotions = promotionsResult.getOrElse(() => []);
    final stores = storesResult.getOrElse(() => []);

    if (!isClosed) {
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          promotions: promotions,
          stores: stores,
          errorMessage: null, // خطای قبلی را پاک کن
        ),
      );
    }
  }

  void selectCategory(String categori) {}

  // 4. --- تابع _getCurrentLocation کامل حذف شد ---
}