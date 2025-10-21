// lib/features/cart/presentation/bloc/cart_state.dart

part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

// وضعیت اولیه یا در حال بارگذاری
class CartLoading extends CartState {}

// وضعیت موفقیت‌آمیز که شامل اطلاعات کامل سبد خرید است
class CartLoaded extends CartState {
  final CartEntity cart;

  const CartLoaded(this.cart);

  @override
  List<Object> get props => [cart];
}

// وضعیت خطا
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}
