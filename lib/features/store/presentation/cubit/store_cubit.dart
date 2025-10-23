// lib/features/store/presentation/cubit/store_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart'; // <-- NoParams را لازم داریم
// --- حذف ایمپورت‌های geolocator و LatLng ---
import '../../domain/usecases/get_stores_usecase.dart';
import 'store_state.dart'; // <-- ایمپورت state

class StoreCubit extends Cubit<StoreState> {
  final GetStoresUsecase _getStoresUsecase;

  StoreCubit({required GetStoresUsecase getStoresUsecase})
      : _getStoresUsecase = getStoresUsecase,
        super(StoreInitial());

  // نام متد fetchStores صحیح است
  Future<void> fetchStores() async {
    if (isClosed) return;
    emit(StoreLoading());

    // --- فراخوانی Usecase با NoParams ---
    final failureOrStores = await _getStoresUsecase(NoParams()); // <-- اینجا باید NoParams باشد

    if (isClosed) return;

    failureOrStores.fold(
      (failure) {
        if (!isClosed) {
          String message = 'خطا در دریافت فروشگاه‌ها';
          if (failure is ServerFailure) {
             message = failure.message;
          }
          emit(StoreError(message: message));
        }
      },
      (stores) {
        if (!isClosed) {
          emit(StoreLoaded(stores: stores));
        }
      },
    );
  }
  // --- تابع _getCurrentLocation حذف شده ---
}