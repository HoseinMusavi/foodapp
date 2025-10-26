// lib/features/cart/presentation/bloc/cart_bloc.dart

import 'package:bloc/bloc.dart';
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
  }) : super(CartLoading()) {
    on<CartStarted>(_onCartStarted);
    on<CartProductAdded>(_onCartProductAdded);
    on<CartProductRemoved>(_onCartProductRemoved);
    on<CartProductQuantityUpdated>(_onCartProductQuantityUpdated);
  }

  void _onCartStarted(CartStarted event, Emitter<CartState> emit) async {
    final failureOrCart = await getCart(NoParams());
    failureOrCart.fold(
      (failure) => emit(const CartError('خطا در بارگذاری سبد خرید')),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  void _onCartProductAdded(
    CartProductAdded event,
    Emitter<CartState> emit,
  ) async {
    final failureOrCart = await addProductToCart(
      AddProductToCartParams(
        product: event.product,
        selectedOptions: event.selectedOptions,
      ),
    );
    failureOrCart.fold(
      (failure) => emit(const CartError('خطا در افزودن محصول')),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  void _onCartProductRemoved(
    CartProductRemoved event,
    Emitter<CartState> emit,
  ) async {
    // ✨ فیکس: (رفع خطاهای قبلی)
    // از UseCase و پارامترهای جدید استفاده شد
    final failureOrCart = await removeProductFromCart(
      RemoveProductFromCartUsecaseParams(cartItemId: event.cartItemId),
    );
    failureOrCart.fold(
      (failure) => emit(const CartError('خطا در حذف محصول')),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  void _onCartProductQuantityUpdated(
    CartProductQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    // ✨ فیکس: (رفع خطاهای قبلی)
    // از UseCase و پارامترهای جدید استفاده شد
    final failureOrCart = await updateProductQuantity(
      UpdateProductQuantityParams(
        cartItemId: event.cartItemId,
        newQuantity: event.newQuantity,
      ),
    );
    failureOrCart.fold(
      (failure) => emit(const CartError('خطا در به‌روزرسانی تعداد محصول')),
      (cart) => emit(CartLoaded(cart)),
    );
  }
}