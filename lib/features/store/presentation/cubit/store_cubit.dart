// lib/features/store/presentation/cubit/store_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/get_stores_usecase.dart';

part 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final GetStoresUsecase getStoresUsecase;

  StoreCubit({required this.getStoresUsecase}) : super(StoreLoading());

  Future<void> fetchStores() async {
    // در شروع، وضعیت لودینگ را ارسال می‌کنیم
    emit(StoreLoading());

    // UseCase را با پارامتر خالی (NoParams) فراخوانی می‌کنیم
    final failureOrStores = await getStoresUsecase(NoParams());

    // نتیجه را مدیریت می‌کنیم
    failureOrStores.fold(
      (failure) {
        // در صورت شکست، وضعیت خطا را ارسال می‌کنیم
        emit(const StoreError('خطا در دریافت لیست فروشگاه‌ها'));
      },
      (stores) {
        // در صورت موفقیت، وضعیت موفق و لیست فروشگاه‌ها را ارسال می‌کنیم
        emit(StoreLoaded(stores));
      },
    );
  }
}
