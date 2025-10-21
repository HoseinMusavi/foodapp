// lib/features/product/presentation/cubit/product_state.dart

part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

// وضعیت اولیه و در حال بارگذاری
class ProductLoading extends ProductState {}

// وضعیت موفقیت‌آمیز، همراه با لیستی از محصولات
class ProductLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

// وضعیت خطا، همراه با یک پیام
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
