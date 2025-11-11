part of 'checkout_cubit.dart';

// Base abstract class for all checkout states
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any checkout process begins.
class CheckoutInitial extends CheckoutState {}

/// State indicating that the order placement is in progress.
class CheckoutProcessing extends CheckoutState {}

/// State indicating successful order placement, containing the new [orderId].
class CheckoutSuccess extends CheckoutState {
  final int orderId;

  const CheckoutSuccess({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// State indicating a failure during the checkout process, containing an error [message].
class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure({required this.message});

  @override
  List<Object?> get props => [message];
}