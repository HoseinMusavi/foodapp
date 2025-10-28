part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

// Event to load the cart initially or refresh it
class CartStarted extends CartEvent {
  // Optional flag to force reloading even if already loaded
  final bool forceRefresh;
  // **** Removed const from constructor ****
  CartStarted({this.forceRefresh = false}); // <- Removed const

  @override
  List<Object> get props => [forceRefresh];
}

// Event triggered when adding a product with selected options
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

// Event triggered when removing an item using its cart item ID
class CartProductRemoved extends CartEvent {
  final int cartItemId;
  const CartProductRemoved({required this.cartItemId});

  @override
  List<Object> get props => [cartItemId];
}

// Event triggered when updating the quantity of an item using its cart item ID
class CartProductQuantityUpdated extends CartEvent {
  final int cartItemId;
  final int newQuantity;

  const CartProductQuantityUpdated({
    required this.cartItemId,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [cartItemId, newQuantity];
}