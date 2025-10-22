// lib/features/store/presentation/cubit/dashboard_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart'; // <-- 1. ایمپورت
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/lat_lng.dart'; // <-- 2. ایمپورت
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
    try {
      emit(state.copyWith(status: DashboardStatus.loading));

      // 3. --- دریافت موقعیت مکانی قبل از هرچیز ---
      final locationData = await _getCurrentLocation();
      final latLng = LatLng(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
      );
      final storeParams = GetStoresParams(location: latLng); // 4. ساخت پارامتر

      // دریافت همزمان داده‌ها
      final results = await Future.wait([
        getPromotionsUsecase(NoParams()),
        getStoresUsecase(storeParams), // 5. استفاده از پارامتر جدید
      ]);
      // ... (بقیه کد فایل بدون تغییر باقی می‌ماند) ...

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
    } catch (e) {
      // 6. مدیریت خطاهای موقعیت مکانی
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectCategory(String categori) {}

  // 7. --- کپی کردن تابع کمکی موقعیت مکانی ---
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    
    final settings = LocationSettings(accuracy: LocationAccuracy.high);
    return await Geolocator.getCurrentPosition(locationSettings: settings);
  }
}