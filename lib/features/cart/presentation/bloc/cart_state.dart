// lib/features/cart/presentation/bloc/cart_state.dart
part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => []; // changed from List<Object>
}

// وضعیت اولیه یا در حال بارگذاری
class CartLoading extends CartState {}

// وضعیت موفقیت‌آمیز، همراه با آبجکت سبد خرید
class CartLoaded extends CartState {
  final CartEntity cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart]; // changed from List<Object>

  // متد کمکی برای کپی کردن وضعیت با تغییرات
  CartLoaded copyWith({
    CartEntity? cart,
  }) {
    return CartLoaded(
      cart ?? this.cart,
    );
  }
}

// وضعیت خطا، همراه با یک پیام
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message]; // changed from List<Object>
}