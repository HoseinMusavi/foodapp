// lib/features/product/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ۱. این پکیج باید نصب شده باشد: flutter pub add scrollable_positioned_list
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../../store/domain/entities/store_entity.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/product_cubit.dart';

class ProductListPage extends StatelessWidget {
  final StoreEntity store;
  const ProductListPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProductCubit>()..fetchProductData(store.id),
      child: Scaffold(
        body: ProductView(store: store),
      ),
    );
  }
}

class ProductView extends StatefulWidget {
  final StoreEntity store;
  const ProductView({super.key, required this.store});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final ItemScrollController _categoryScrollController = ItemScrollController();
  // ۲. (اصلاح) لیسنر دسته‌بندی را به ویجت متصل می‌کنیم
  final ItemPositionsListener _categoryPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _productScrollController = ItemScrollController();
  final ItemPositionsListener _productPositionsListener =
      ItemPositionsListener.create();

  int _selectedCategoryIndex = 0;
  // ۳. (اصلاح) این فیلد استفاده نشده بود و حذف شد
  // bool _isScrollingProducts = false; 
  bool _isScrollingCategories = false;

  @override
  void initState() {
    super.initState();
    _productPositionsListener.itemPositions.addListener(_onProductScroll);
  }

  @override
  void dispose() {
    _productPositionsListener.itemPositions.removeListener(_onProductScroll);
    super.dispose();
  }

  void _onProductScroll() {
    if (_isScrollingCategories) return; 

    final firstVisibleProductIndex =
        _productPositionsListener.itemPositions.value.firstOrNull?.index;
    
    if (firstVisibleProductIndex == null) return;

    final state = context.read<ProductCubit>().state;
    if (state is ProductLoaded) {
      // اطمینان از اینکه ایندکس در محدوده لیست است
      if (firstVisibleProductIndex < state.products.length) {
        final product = state.products[firstVisibleProductIndex];
        final newCategoryIndex = state.categories
            .indexWhere((cat) => cat.id == product.categoryId);

        if (newCategoryIndex != -1 &&
            newCategoryIndex != _selectedCategoryIndex) {
          setState(() {
            _selectedCategoryIndex = newCategoryIndex;
          });
          _scrollToCategory(newCategoryIndex);
        }
      }
    }
  }

  void _scrollToCategory(int index) async {
    await _categoryScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _scrollToProduct(int categoryIndex) async {
    _isScrollingCategories = true;

    final state = context.read<ProductCubit>().state;
    if (state is! ProductLoaded) return;

    final productIndex = state.products
        .indexWhere((p) => p.categoryId == state.categories[categoryIndex].id);

    if (productIndex != -1) {
      await _productScrollController.scrollTo(
        index: productIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // کمی تاخیر می‌دهیم تا اسکرول تمام شود
    await Future.delayed(const Duration(milliseconds: 350));
    _isScrollingCategories = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductLoaded &&
            state.isLoadingOptions == false &&
            state.currentOptions != null) {
          if (state.currentOptions!.isNotEmpty) {
            _showOptionsModal(context, state.currentOptions!);
          } else {
            // TODO: محصول را مستقیماً به سبد خرید اضافه کن (این برای پارت بعدی است)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'این محصول آپشنی ندارد. (در حال پیاده‌سازی افزودن به سبد)')),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductError) {
          return Center(child: Text(state.message));
        }
        if (state is ProductLoaded) {
          return _buildProductListUI(context, state);
        }
        return const Center(child: Text('در حال بارگذاری منو...'));
      },
    );
  }

  Widget _buildProductListUI(BuildContext context, ProductLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(widget.store.name,
                style: const TextStyle(
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)])),
            background: CustomNetworkImage(
              imageUrl: widget.store.logoUrl,
              fit: BoxFit.cover,
            ),
          ),
          // TODO: افزودن دکمه‌های جستجو و اطلاعات رستوران
        ),
        SliverPersistentHeader(
          delegate: _CategoryHeaderDelegate(
            categories: state.categories,
            selectedIndex: _selectedCategoryIndex,
            scrollController: _categoryScrollController,
            positionsListener: _categoryPositionsListener, // ۴. (اصلاح) اتصال لیسنر
            onCategorySelected: (index) {
              setState(() {
                _selectedCategoryIndex = index;
              });
              _scrollToCategory(index);
              _scrollToProduct(index);
            },
          ),
          pinned: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          // ۵. (اصلاح) استفاده از نام کلاس صحیح
          sliver: ScrollablePositionedList.builder( 
            itemScrollController: _productScrollController,
            itemPositionsListener: _productPositionsListener,
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final category = state.categories
                  .firstWhere((cat) => cat.id == product.categoryId, orElse: () => state.categories.first); // افزودن orElse برای اطمینان

              bool isNewCategory = index == 0 ||
                  state.products[index - 1].categoryId != product.categoryId;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNewCategory)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 24, bottom: 16, right: 8),
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  _ProductCard(
                    product: product,
                    onTap: () {
                      context
                          .read<ProductCubit>()
                          .fetchProductOptions(product.id);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showOptionsModal(
      BuildContext context, List<OptionGroupEntity> options) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // TODO: این ویجت باید به یک StatefulWidget تبدیل شود
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("انتخاب گزینه‌ها",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final group = options[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(group.name,
                                  style: Theme.of(context).textTheme.titleLarge),
                            ),
                            // TODO: اینجا باید از RadioButton یا Checkbox
                            ...group.options.map(
                              (option) => ListTile(
                                title: Text(option.name),
                                trailing: Text(
                                    '+ ${option.priceDelta.toStringAsFixed(0)} تومان'),
                                onTap: () {
                                  // TODO: مدیریت انتخاب
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: افزودن به سبد خرید با آپشن‌های انتخاب شده
                        Navigator.of(context).pop();
                      },
                      child: const Text('افزودن به سبد خرید'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --- ویجت کارت محصول ---
class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${product.finalPrice.toStringAsFixed(0)} تومان',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CustomNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ویجت هدر چسبان دسته‌بندی‌ها ---
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<ProductCategoryEntity> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final ItemScrollController scrollController;
  final ItemPositionsListener positionsListener; // ۶. (اصلاح) افزودن لیسنر

  _CategoryHeaderDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.scrollController,
    required this.positionsListener, // ۷. (اصلاح) افزودن لیسنر
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: 60.0,
      // ۸. (اصلاح) استفاده از نام کلاس صحیح
      child: ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener, // ۹. (اصلاح) اتصال لیسنر
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: ChoiceChip(
              label: Text(categories[index].name),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  onCategorySelected(index);
                }
              },
              // ۱۰. (اصلاح) رفع ارور deprecated
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128), // قبلی: surfaceVariant.withOpacity
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      // ۱۱. (اصلاح) رفع ارور deprecated
                      : Colors.grey.withAlpha(77), // قبلی: withOpacity(0.3)
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex ||
        categories != oldDelegate.categories;
  }
}