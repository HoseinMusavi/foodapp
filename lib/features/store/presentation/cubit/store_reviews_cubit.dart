// lib/features/store/presentation/cubit/store_reviews_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/store/domain/entities/store_review_entity.dart';
import 'package:customer_app/features/store/domain/usecases/get_store_reviews_usecase.dart';
import 'package:equatable/equatable.dart';

part 'store_reviews_state.dart';

class StoreReviewsCubit extends Cubit<StoreReviewsState> {
  final GetStoreReviewsUsecase getStoreReviewsUsecase;

  StoreReviewsCubit({required this.getStoreReviewsUsecase})
      : super(StoreReviewsInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> fetchReviews(int storeId) async {
    emit(StoreReviewsLoading());
    final failureOrReviews =
        await getStoreReviewsUsecase(GetStoreReviewsParams(storeId: storeId));

    failureOrReviews.fold(
      (failure) => emit(StoreReviewsError(_mapFailureToMessage(failure))),
      (reviews) => emit(StoreReviewsLoaded(reviews)),
    );
  }
}