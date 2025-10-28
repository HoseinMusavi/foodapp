// lib/features/cart/presentation/bloc/cart_event.dart

part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class CartStarted extends CartEvent {}

class CartProductAdded extends CartEvent {
  final ProductEntity product;
  final List<OptionEntity> selectedOptions;

  const CartProductAdded({
    required this.product,
    required this.selectedOptions,
  });

  @override
  List<Object> get props => [product, selectedOptions];
}

class CartProductRemoved extends CartEvent {
  // ✨ فیکس: از ProductEntity به cartItemId تغییر کرد
  final int cartItemId;
  const CartProductRemoved({required this.cartItemId});

  @override
  List<Object> get props => [cartItemId];
}

class CartProductQuantityUpdated extends CartEvent {
  // ✨ فیکس: از ProductEntity به cartItemId تغییر کرد
  final int cartItemId;
  final int newQuantity;

  const CartProductQuantityUpdated({
    required this.cartItemId,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [cartItemId, newQuantity];
}