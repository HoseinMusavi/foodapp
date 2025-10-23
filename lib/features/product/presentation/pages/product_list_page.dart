// lib/features/product/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/foundation.dart' show listEquals; // برای مقایسه لیست در shouldRebuild

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart'; // برای ارسال ایونت
import '../../../store/domain/entities/store_entity.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/product_cubit.dart';
import '../widgets/product_options_modal.dart'; // ایمپورت ویجت مودال

class ProductListPage extends StatelessWidget {
  final StoreEntity store;
  const ProductListPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    // فراهم کردن ProductCubit در اینجا و فراخوانی واکشی اولیه
    return BlocProvider(
      create: (context) => sl<ProductCubit>()..fetchProductData(store.id),
      // BlocProvider برای CartBloc لازم نیست چون در MainShell فراهم شده
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
  int _selectedCategoryIndex = 0;
  // کنترلر عادی برای لیست دسته‌بندی‌ها
  final ScrollController _categoryScrollController = ScrollController();
  // متغیری برای نگه داشتن productId محصولی که آپشن‌هایش نمایش داده می‌شود
  int? _viewingOptionsForProductId;

  @override
  void initState() {
    super.initState();
    // هیچ فراخوانی اولیه‌ای اینجا نیست
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  // --- توابع اسکرول هماهنگ فعلاً پیاده‌سازی نشده‌اند ---
  void _scrollToCategory(int index) async {
     print("WARN: Programmatic category scrolling not fully implemented.");
     // می‌توانید منطق اسکرول به آیتم index با _categoryScrollController را اضافه کنید
  }

  void _scrollToProduct(int categoryIndex) async {
     print("WARN: Programmatic product scrolling not fully implemented.");
     // اسکرول به محصول اول دسته‌بندی در SliverList نیاز به محاسبه Offset دارد
  }
  // ---

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        // مدیریت نمایش پاپ‌آپ آپشن‌ها
        if (state is ProductLoaded &&
            state.isLoadingOptions == false && // لودینگ آپشن تمام شده باشد
            state.currentOptions != null &&    // آپشن‌ها واکشی شده باشند (حتی اگر خالی باشند)
            _viewingOptionsForProductId != null) { // ID محصولی که کلیک شده را داشته باشیم

          ProductEntity? product;
          try {
            product = state.products.firstWhere((p) => p.id == _viewingOptionsForProductId);
          } catch (e) {
            product = null;
            print("Error finding product for options modal: $e");
          }

          if (product != null) {
            if (state.currentOptions!.isNotEmpty) {
              _showOptionsModal(context, product, state.currentOptions!);
            } else {
              context.read<CartBloc>().add(
                 CartProductAdded(product: product, selectedOptions: const []),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} به سبد خرید اضافه شد')),
              );
            }
          }
          _viewingOptionsForProductId = null; // ریست کردن
        }
        // مدیریت خطا هنگام لود آپشن‌ها
        else if (state is ProductError && _viewingOptionsForProductId != null && state.message.contains('گزینه‌ها')) { // اضافه کردن چک message
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
           );
          _viewingOptionsForProductId = null; // ریست کردن
        }
      },
     builder: (context, state) {
        // --- مدیریت وضعیت‌های مختلف ---

        // ۱. خواندن state قبلی (اگر ProductLoaded بود)
        final previousState = context.read<ProductCubit>().state;
        final bool hasPreviousProducts = previousState is ProductLoaded && previousState.products.isNotEmpty;

        // ۲. نمایش لودینگ اولیه
        if (state is ProductInitial || (state is ProductLoading && !hasPreviousProducts)) {
            // فقط اگر state اولیه است یا در حال لودینگ هستیم *و* هیچ محصولی از قبل نداشتیم
            return const Center(child: CircularProgressIndicator());
        }

        // ۳. نمایش خطا
        if (state is ProductError) {
          return Center(
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text("خطا در بارگذاری منو: ${state.message}", textAlign: TextAlign.center),
             )
          );
        }

        // ۴. نمایش UI اصلی (چه در حالت Loaded چه Loading برای رفرش)
        // داده‌ها را از state فعلی (اگر Loaded است) یا state قبلی (اگر Loading برای رفرش است) می‌گیریم
        ProductLoaded? loadedState;
        if (state is ProductLoaded) {
           loadedState = state;
        } else if (previousState is ProductLoaded) {
           loadedState = previousState;
        }

        if (loadedState != null) {
           return Stack(
             children: [
               _buildProductListUI(context, loadedState), // همیشه از loadedState معتبر استفاده کن
               // نمایش پوشش لودینگ هنگام واکشی آپشن‌ها
               if (state is ProductLoaded && state.isLoadingOptions)
                 Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                 ),
               // نمایش نشانگر لودینگ برای رفرش (اگر state فعلی Loading باشد)
               if (state is ProductLoading)
                  Positioned(
                     top: MediaQuery.of(context).padding.top + kToolbarHeight + 70, // زیر هدر دسته‌بندی
                     left: 0,
                     right: 0,
                     child: const Center(child: LinearProgressIndicator()),
                  ),
             ],
           );
        }

        // حالت پیش‌فرض یا ناشناخته (نباید اتفاق بیفتد)
        return const Center(child: Text('وضعیت نامشخص'));
      },
    );
  }

  // --- ویجت اصلی UI صفحه ---
  Widget _buildProductListUI(BuildContext context, ProductLoaded state) {
    // اگر دسته‌بندی یا محصولی وجود نداشت (بعد از لود موفق)
    if (state.categories.isEmpty || state.products.isEmpty) {
       return const Center(child: Text('منوی این رستوران در حال حاضر خالی است.'));
    }

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
            onCategorySelected: (index) {
              if (index >= 0 && index < state.categories.length) {
                 setState(() {
                   _selectedCategoryIndex = index;
                 });
                 _scrollToCategory(index);
                 _scrollToProduct(index);
              }
            },
          ),
          pinned: true,
        ),
        // استفاده از SliverList
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < 0 || index >= state.products.length) return null;

                final product = state.products[index];
                // اصلاح firstWhere با cast و orElse
                final category = state.categories.cast<ProductCategoryEntity>().firstWhere(
                  (cat) => cat.id == product.categoryId,
                  orElse: () => const ProductCategoryEntity(id: -1, storeId: -1, name: 'نامشخص'),
                );

                bool isNewCategory = index == 0 ||
                    (index > 0 && state.products[index - 1].categoryId != product.categoryId);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNewCategory)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 24, bottom: 16, right: 8),
                        child: Text(
                          category.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    _ProductCard(
                      product: product,
                      onTap: () {
                        setState(() {
                           _viewingOptionsForProductId = product.id;
                        });
                        context
                            .read<ProductCubit>()
                            .fetchProductOptions(product.id);
                      },
                    ),
                  ],
                );
              },
              childCount: state.products.length,
            ),
          ),
        ),
      ],
    );
  }

  // --- نمایش پاپ‌آپ آپشن‌ها ---
  void _showOptionsModal(BuildContext context, ProductEntity product, List<OptionGroupEntity> options) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return BlocProvider.value(
          value: BlocProvider.of<CartBloc>(context),
          child: ProductOptionsModal(
             product: product,
             optionGroups: options,
          ),
        );
      },
    );
  }

} // <-- پایان کلاس _ProductViewState


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
                    if (product.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      )
                    else
                       const SizedBox(height: 12),

                    Text(
                      '${product.finalPrice.toStringAsFixed(0)} تومان',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold
                           ),
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


// --- ویجت هدر دسته‌بندی‌ها (با ListView معمولی) ---
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<ProductCategoryEntity> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final ScrollController scrollController;

  _CategoryHeaderDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.scrollController,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: 60.0,
      decoration: BoxDecoration(
         border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.0))
      ),
      child: ListView.builder(
        controller: scrollController,
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(categories[index].name),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  onCategorySelected(index);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
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
                      : Colors.grey.withAlpha(50),
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.zero,
              showCheckmark: false,
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
           !listEquals(categories, oldDelegate.categories);
  }
}