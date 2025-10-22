// lib/features/product/presentation/cubit/product_state.dart
part of 'product_cubit.dart'; // <-- از part/part of استفاده می‌کنیم

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductCategoryEntity> categories; // <-- جدید: لیست دسته‌بندی‌ها
  final List<ProductEntity> products;

  // وضعیت جدید برای آپشن‌های محصول
  final List<OptionGroupEntity>? currentOptions;
  final bool isLoadingOptions;

  const ProductLoaded({
    required this.categories,
    required this.products,
    this.currentOptions,
    this.isLoadingOptions = false,
  });

  @override
  List<Object> get props =>
      [categories, products, isLoadingOptions, currentOptions ?? []];

  // متد کمکی برای کپی کردن وضعیت
  ProductLoaded copyWith({
    List<ProductCategoryEntity>? categories,
    List<ProductEntity>? products,
    List<OptionGroupEntity>? currentOptions,
    bool? isLoadingOptions,
  }) {
    return ProductLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      currentOptions: currentOptions ?? this.currentOptions,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}