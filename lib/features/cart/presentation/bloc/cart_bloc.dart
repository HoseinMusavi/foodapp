import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart'; // Import Failure
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/domain/entities/option_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/usecases/add_product_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_product_from_cart_usecase.dart';
import '../../domain/usecases/update_product_quantity_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUsecase getCart;
  final AddProductToCartUsecase addProductToCart;
  final RemoveProductFromCartUsecase removeProductFromCart;
  final UpdateProductQuantityUsecase updateProductQuantity;

  CartBloc({
    required this.getCart,
    required this.addProductToCart,
    required this.removeProductFromCart,
    required this.updateProductQuantity,
  }) : super(CartLoading()) { // Start with loading state
    on<CartStarted>(_onCartStarted);
    on<CartProductAdded>(_onCartProductAdded);
    on<CartProductRemoved>(_onCartProductRemoved);
    on<CartProductQuantityUpdated>(_onCartProductQuantityUpdated);
  }

  // Helper function to map Failure to error message String
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  // Handler for CartStarted event
  void _onCartStarted(CartStarted event, Emitter<CartState> emit) async {
    // **** Corrected: Use forceRefresh flag ****
    // If refresh is not forced and the cart is already loaded, do nothing
    if (!event.forceRefresh && state is CartLoaded) {
       return; // Avoid unnecessary loading
    }
    // Otherwise, show loading state and fetch the cart
    emit(CartLoading());
    final failureOrCart = await getCart(NoParams());
    failureOrCart.fold(
      // Provide a more specific error message using the helper
      (failure) => emit(CartError('خطا در بارگذاری سبد خرید: ${_mapFailureToMessage(failure)}')),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  // Handler for CartProductAdded event
  void _onCartProductAdded(
    CartProductAdded event,
    Emitter<CartState> emit,
  ) async {
    // Optionally emit a state indicating update in progress if the current state is CartLoaded
    if (state is CartLoaded) {
      // You might want a specific state like CartUpdating or add a flag to CartLoaded
      // emit((state as CartLoaded).copyWith(isUpdating: true)); // Example if copyWith exists
    } else {
       emit(CartLoading()); // Show loading if cart wasn't loaded before
    }
    final failureOrCart = await addProductToCart(
      AddProductToCartParams(
        product: event.product,
        selectedOptions: event.selectedOptions,
      ),
    );
    failureOrCart.fold(
      (failure) => emit(CartError('خطا در افزودن محصول: ${_mapFailureToMessage(failure)}')),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  // Handler for CartProductRemoved event
  void _onCartProductRemoved(
    CartProductRemoved event,
    Emitter<CartState> emit,
  ) async {
     if (state is CartLoaded) {
       // Optionally emit updating state
     } else {
       // This case (removing from non-loaded cart) shouldn't happen, but handle defensively
       emit(CartLoading());
       add(CartStarted()); // Reload cart first? Or just show error?
       return;
     }
    final failureOrCart = await removeProductFromCart(
      RemoveProductFromCartUsecaseParams(cartItemId: event.cartItemId),
    );
    failureOrCart.fold(
      (failure) => emit(CartError('خطا در حذف محصول: ${_mapFailureToMessage(failure)}')),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  // Handler for CartProductQuantityUpdated event
  void _onCartProductQuantityUpdated(
    CartProductQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
      if (state is CartLoaded) {
       // Optionally emit updating state
     } else {
       emit(CartLoading());
       add(CartStarted());
       return;
     }
    final failureOrCart = await updateProductQuantity(
      UpdateProductQuantityParams(
        cartItemId: event.cartItemId,
        newQuantity: event.newQuantity,
      ),
    );
    failureOrCart.fold(
      (failure) => emit(CartError('خطا در به‌روزرسانی تعداد: ${_mapFailureToMessage(failure)}')),
      (cart) => emit(CartLoaded(cart)),
    );
  }
}