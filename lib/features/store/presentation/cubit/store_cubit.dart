// lib/features/store/presentation/cubit/store_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/failure.dart'; // <-- ایمپورت Failure
import '../../../../core/utils/lat_lng.dart';
import '../../domain/usecases/get_stores_usecase.dart';
import 'store_state.dart'; // <-- 1. به جای "part" از "import" استفاده می‌کنیم

class StoreCubit extends Cubit<StoreState> {
  final GetStoresUsecase _getStoresUsecase;

  StoreCubit({required GetStoresUsecase getStoresUsecase})
      : _getStoresUsecase = getStoresUsecase,
        super(StoreInitial()); // <-- 2. متد StoreInitial حالا تعریف شده است

  Future<void> fetchStoresNearUser() async {
    try {
      emit(StoreLoading()); // <-- 3. متد StoreLoading حالا تعریف شده است

      final locationData = await _getCurrentLocation();
      final latLng = LatLng(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
      );

      final params = GetStoresParams(location: latLng);
      final failureOrStores = await _getStoresUsecase(params);

      failureOrStores.fold(
        (failure) {
          // --- 4. ارور "message" در اینجا برطرف شد ---
          if (failure is ServerFailure) {
            emit(StoreError(message: failure.message));
          } else {
            emit(const StoreError(message: 'خطای ناشناخته رخ داد'));
          }
        },
        (stores) => emit(StoreLoaded(stores: stores)), // <-- 5. متد StoreLoaded حالا تعریف شده است
      );
    } on LocationServiceDisabledException {
      emit(const StoreError(message: 'سرویس موقعیت مکانی شما غیرفعال است.'));
    } on PermissionDeniedException {
      emit(const StoreError(message: 'دسترسی به موقعیت مکانی رد شد.'));
    } catch (e) {
      emit(StoreError(message: 'خطایی رخ داد: ${e.toString()}'));
    }
  }

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

    // رفع ارور deprecated (اختیاری اما خوب است)
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    return await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );
  }
}