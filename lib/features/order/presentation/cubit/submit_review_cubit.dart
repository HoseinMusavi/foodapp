// lib/features/order/presentation/cubit/submit_review_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/features/order/domain/usecases/submit_store_review_usecase.dart';
import 'package:equatable/equatable.dart';

part 'submit_review_state.dart';

class SubmitReviewCubit extends Cubit<SubmitReviewState> {
  final SubmitStoreReviewUsecase submitStoreReviewUsecase;

  SubmitReviewCubit({required this.submitStoreReviewUsecase})
      : super(SubmitReviewInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> submitReview({
    required int orderId,
    required int storeId,
    required double rating,
    String? comment,
  }) async {
    // معیار پذیرش ۲.۴ (اعتبارسنجی ستاره)
    if (rating == 0.0) {
      emit(const SubmitReviewError('لطفاً امتیاز ستاره‌ای را (بین ۱ تا ۵) وارد کنید.'));
      // برگرداندن به حالت اولیه پس از نمایش خطا
      await Future.delayed(const Duration(milliseconds: 1500)); // زمان کمتر
      if (!isClosed) emit(SubmitReviewInitial());
      return;
    }

    emit(SubmitReviewSubmitting());

    final params = SubmitStoreReviewParams(
      orderId: orderId,
      storeId: storeId,
      rating: rating.toInt(), // ستاره‌ها double هستند، ما int می‌فرستیم
      comment: (comment != null && comment.isEmpty) ? null : comment,
    );

    final failureOrSuccess = await submitStoreReviewUsecase(params);

    failureOrSuccess.fold(
      (failure) {
        emit(SubmitReviewError(_mapFailureToMessage(failure)));
      },
      (_) {
        emit(SubmitReviewSuccess());
      },
    );
  }
}