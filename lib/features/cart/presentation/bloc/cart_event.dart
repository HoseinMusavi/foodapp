// lib/features/cart/presentation/bloc/cart_event.dart

part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

// رویداد برای شروع و دریافت وضعیت اولیه سبد خرید
class CartStarted extends CartEvent {}

// رویداد برای افزودن یک محصول به سبد خرید
class CartProductAdded extends CartEvent {
  final ProductEntity product;

  const CartProductAdded(this.product);

  @override
  List<Object> get props => [product];
}

// رویداد برای حذف یک محصول از سبد خرید
class CartProductRemoved extends CartEvent {
  final ProductEntity product;

  const CartProductRemoved(this.product);

  @override
  List<Object> get props => [product];
}

class CartProductQuantityUpdated extends CartEvent {
  final ProductEntity product;
  final int newQuantity;

  const CartProductQuantityUpdated({
    required this.product,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [product, newQuantity];
}
