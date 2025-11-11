// lib/features/store/presentation/cubit/store_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
// ۱. --- ایمپورت GetStoresParams ---
import '../../domain/usecases/get_stores_usecase.dart';
import '../../domain/entities/store_entity.dart';

part 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final GetStoresUsecase getStoresUsecase;

  StoreCubit({required this.getStoresUsecase}) : super(StoreInitial());

  Future<void> fetchStores() async {
    emit(StoreLoading());

    // ۲. --- استفاده از GetStoresParams خالی (بدون فیلتر) ---
    // این تابع RPC ما (get_filtered_stores) را با پارامترهای null فراخوانی می‌کند
    // و در نتیجه همه‌ی فروشگاه‌ها را برمی‌گرداند.
    final result = await getStoresUsecase(const GetStoresParams());

    result.fold(
      (failure) {
        final message =
            (failure is ServerFailure) ? failure.message : 'خطای ناشناخته';
        emit(StoreError(message));
      },
      (stores) => emit(StoreLoaded(stores)),
    );
  }
}