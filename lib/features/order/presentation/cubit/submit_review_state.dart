// lib/features/order/presentation/cubit/submit_review_state.dart

part of 'submit_review_cubit.dart';


abstract class SubmitReviewState extends Equatable {
  const SubmitReviewState();

  @override
  List<Object> get props => [];
}

class SubmitReviewInitial extends SubmitReviewState {}

class SubmitReviewSubmitting extends SubmitReviewState {}

class SubmitReviewSuccess extends SubmitReviewState {}

class SubmitReviewError extends SubmitReviewState {
  final String message;
  const SubmitReviewError(this.message);

  @override
  List<Object> get props => [message];
}