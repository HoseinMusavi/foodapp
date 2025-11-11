// lib/features/store/presentation/cubit/store_reviews_state.dart

part of 'store_reviews_cubit.dart';

abstract class StoreReviewsState extends Equatable {
  const StoreReviewsState();

  @override
  List<Object> get props => [];
}

class StoreReviewsInitial extends StoreReviewsState {}

class StoreReviewsLoading extends StoreReviewsState {}

class StoreReviewsLoaded extends StoreReviewsState {
  final List<StoreReviewEntity> reviews;
  const StoreReviewsLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class StoreReviewsError extends StoreReviewsState {
  final String message;
  const StoreReviewsError(this.message);

  @override
  List<Object> get props => [message];
}