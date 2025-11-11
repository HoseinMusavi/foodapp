// lib/features/product/presentation/pages/product_list_page.dart

// import 'package:flutter/foundation.dart' show listEquals; // Not needed currently

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../../store/domain/entities/store_entity.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/product_cubit.dart';
import '../widgets/product_options_modal.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class ProductListPage extends StatelessWidget {
  final StoreEntity store;
  const ProductListPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProductCubit>()..fetchProductData(store.id),
      child: ProductView(store: store),
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
  final ScrollController _categoryScrollController = ScrollController();
  int? _viewingOptionsForProductId;

  // ✨ فیکس: Map ها به state منتقل شدند
  Map<int, int> _categoryStartIndexMap = {}; // categoryId -> productIndex
  final Map<int, GlobalKey> _categoryTitleKeys = {}; // categoryId -> GlobalKey
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCategoryChip(int index) async {
     if (_categoryScrollController.hasClients) {
       final state = context.read<ProductCubit>().state;
       if (state is! ProductLoaded || state.categories.isEmpty) return;
       double totalWidth = _categoryScrollController.position.maxScrollExtent;
       // اطمینان از عدم تقسیم بر صفر اگر فقط یک دسته بندی وجود داشته باشد
       double targetScrollOffset = (state.categories.length > 1) 
          ? (totalWidth / (state.categories.length - 1)) * index 
          : 0.0;
       targetScrollOffset = targetScrollOffset.clamp(0.0, totalWidth);
       _categoryScrollController.animateTo( targetScrollOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, );
     }
  }

  void _scrollToProductCategory(int categoryIndex) async {
    final state = context.read<ProductCubit>().state;
    if (state is! ProductLoaded) return;
    final categories = state.categories;
    if (categoryIndex < 0 || categoryIndex >= categories.length) return;

    final categoryId = categories[categoryIndex].id;
    // Handle potential null category (using key -1)
    final effectiveKey = _categoryTitleKeys[categoryId ?? -1];

    if (effectiveKey != null && effectiveKey.currentContext != null) {
      setState(() { _isScrollingProgrammatically = true; });
      // Calculate header height dynamically
      // kToolbarHeight (ارتفاع AppBar) + 60.0 (ارتفاع هدر دسته‌بندی) + ارتفاع SafeArea بالای صفحه
      double headerHeight = kToolbarHeight + 60.0 + MediaQuery.of(context).padding.top; 
      
      await Scrollable.ensureVisible(
        effectiveKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        alignment: 0.0, // Align top edge of the item
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
      
      // Adjust scroll after ensureVisible finishes, to account for sticky header
      // این تاخیر کوتاه اجازه می‌دهد تا ensureVisible تمام شود و سپس اسکرول را تنظیم کنیم
      Future.delayed(const Duration(milliseconds: 50), () { 
        if (_scrollController.hasClients) {
          final box = effectiveKey.currentContext?.findRenderObject() as RenderBox?;
          final position = box?.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
          
          if (position != null) {
            // محاسبه آفست هدف: آفست فعلی + موقعیت آیتم - ارتفاع هدر - 10 پیکسل پدینگ
            double targetOffset = _scrollController.offset + position.dy - headerHeight - 10; 
            targetOffset = targetOffset < 0 ? 0 : targetOffset; // اطمینان از اینکه آفست منفی نیست

            // فقط در صورتی اسکرول کن که تفاوت قابل توجه باشد (جلوگیری از پرش)
            if ((_scrollController.offset - targetOffset).abs() > 1.0) {
              _scrollController.animateTo(
                targetOffset,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          }
        }
      });
      
      // تاخیر برای فعال کردن مجدد _onScroll
      Future.delayed(const Duration(milliseconds: 550), () {
       if(mounted){ setState(() { _isScrollingProgrammatically = false; }); }
      });
    } else {
      print("WARN: Could not find key or context for category ID: $categoryId");
    }
  }

  void _onScroll() {
    if (_isScrollingProgrammatically || !_scrollController.hasClients) return;

    final state = context.read<ProductCubit>().state;
    if (state is! ProductLoaded || state.categories.isEmpty) return;

    int? currentTopCategoryIndex;
    // محاسبه نقطه مرجع (لبه پایینی هدر چسبان)
    double headerBottomEdge = kToolbarHeight + 60.0 + MediaQuery.of(context).padding.top;
    double closestOffsetToHeader = double.infinity; // یافتن نزدیکترین عنوان *زیر* هدر

    for (var entry in _categoryTitleKeys.entries) {
      final keyContext = entry.value.currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox?;
        final position = box?.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
        if (position != null) {
          // آفست لبه بالایی عنوان دسته بندی نسبت به لبه پایینی هدر
          double offsetFromHeader = position.dy - headerBottomEdge;

          // عناوینی را در نظر بگیر که کمی بالا یا پایین لبه هدر هستند
          if (offsetFromHeader < closestOffsetToHeader && offsetFromHeader > - (box?.size.height ?? 50)) { 
            closestOffsetToHeader = offsetFromHeader;
            int foundIndex = state.categories.indexWhere((cat) => cat.id == entry.key);
            if (foundIndex != -1) {
              currentTopCategoryIndex = foundIndex;
            }
            // Handle "Uncategorized" (-1 key)
            else if (entry.key == -1) {
               int uncategorizedIndex = state.categories.indexWhere((cat) => cat.id == null);
               if(uncategorizedIndex != -1) {
                  currentTopCategoryIndex = uncategorizedIndex;
               }
            }
          }
        }
      }
    }

    // اگر نزدیک بالا بود یا هیچ دسته‌بندی پیدا نشد، 0 را در نظر بگیر
    currentTopCategoryIndex ??= (_scrollController.offset < 100) ? 0 : _selectedCategoryIndex;


    if (currentTopCategoryIndex != _selectedCategoryIndex) {
        if (mounted) {
          setState(() {
            _selectedCategoryIndex = currentTopCategoryIndex!;
          });
          _scrollToCategoryChip(currentTopCategoryIndex);
        }
    }
  }


  void _calculateCategoryStartIndicesAndKeys(List<ProductEntity> products, List<ProductCategoryEntity> categories) {
    print("Recalculating Category Indices and Keys...");
    final newStartIndexMap = <int, int>{}; // Use local map first
    final newTitleKeys = <int, GlobalKey>{};
    
    if (products.isEmpty && categories.isEmpty) {
        if(mounted) setState(() { 
          _categoryStartIndexMap = newStartIndexMap; 
          _categoryTitleKeys.clear();
        });
        return;
    }

    Map<int?, int> tempFirstIndexMap = {}; // categoryId -> first product index
    for (int i = 0; i < products.length; i++) {
        final categoryId = products[i].categoryId;
        if (!tempFirstIndexMap.containsKey(categoryId)) {
            tempFirstIndexMap[categoryId] = i;
        }
    }

    int lastIndexAssigned = 0; // پیگیری برای دسته‌بندی‌های بدون محصول
    for (var category in categories) {
        newTitleKeys[category.id] = GlobalKey(); // ساخت کلید بدون توجه به محصول
        newStartIndexMap[category.id] = tempFirstIndexMap[category.id] ?? lastIndexAssigned;
        lastIndexAssigned = newStartIndexMap[category.id]!;
    }

    // مدیریت محصولات با categoryId null
    if (tempFirstIndexMap.containsKey(null)) {
        newStartIndexMap[-1] = tempFirstIndexMap[null]!; // استفاده از 1- برای کلید null
        newTitleKeys[-1] = GlobalKey();
        // اگر دسته بندی "سایر" در categories وجود ندارد، آن را به صورت مجازی اضافه کن
        if (!categories.any((c) => c.id == null)) {
           // این بخش به منطق نمایش "سایر" در هدر بستگی دارد
           // اگر هدر "سایر" ندارد، نیازی به این کار نیست
        }
    }

    // به‌روزرسانی متغیرهای state
    if (mounted) {
        setState(() {
            _categoryStartIndexMap = newStartIndexMap;
            _categoryTitleKeys.clear();
            _categoryTitleKeys.addAll(newTitleKeys);
        });
    }

    print("Category Start Indices Updated: $_categoryStartIndexMap");
    print("Category Title Keys Updated: ${_categoryTitleKeys.keys}");
  }


  @override
  Widget build(BuildContext context) {
    final cartBloc = context.read<CartBloc>();

    return Scaffold(
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductLoaded) {
            // محاسبه کلیدها/اندیس‌ها هنگام بارگذاری داده
            _calculateCategoryStartIndicesAndKeys(state.products, state.categories);
            WidgetsBinding.instance.addPostFrameCallback((_) {
                // اجرای بررسی اسکرول اولیه پس از ساخت
                _onScroll();
            });
          }
          
          // ... بقیه منطق listener ...
          if (state is ProductLoaded && state.isLoadingOptions == false && state.currentOptions != null && _viewingOptionsForProductId != null) { 
            ProductEntity? product; try { product = state.products.firstWhere((p) => p.id == _viewingOptionsForProductId); } catch (e) { product = null; print("Error finding product: $e"); }
            if (product != null) {
                if (state.currentOptions!.isNotEmpty) { _showOptionsModal(context, product, state.currentOptions!, cartBloc); }
                else { cartBloc.add( CartProductAdded(product: product, selectedOptions: const []), ); ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('${product.name} به سبد خرید اضافه شد')), ); }
            }
            _viewingOptionsForProductId = null;
            } else if (state is ProductError && _viewingOptionsForProductId != null && state.message.contains('گزینه‌ها')) { 
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(state.message), backgroundColor: Colors.red), ); _viewingOptionsForProductId = null;
            }
        },
        builder: (context, state) {
          final previousState = context.read<ProductCubit>().state;
          final bool hasPreviousProducts = previousState is ProductLoaded && previousState.products.isNotEmpty;

          if (state is ProductInitial || (state is ProductLoading && !hasPreviousProducts)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            // ارائه Scaffold در اینجا برای AppBar یکپارچه
            return Scaffold(
              appBar: AppBar(title: Text(widget.store.name)), // AppBar ساده در حالت خطا
              body: Center( child: Padding( padding: const EdgeInsets.all(16.0), child: Text("خطا در بارگذاری منو: ${state.message}", textAlign: TextAlign.center), ) )
            );
          }

          ProductLoaded? loadedState;
          if (state is ProductLoaded) { loadedState = state; }
          else if (previousState is ProductLoaded) { loadedState = previousState; }

          if (loadedState == null){ return Scaffold(appBar: AppBar(title: Text(widget.store.name)), body: const Center(child: Text('وضعیت نامشخص'))); }

            // اطمینان از محاسبه کلیدها/اندیس‌ها *قبل* از ساخت Slivers
            if (_categoryTitleKeys.isEmpty && (loadedState.categories.isNotEmpty || loadedState.products.any((p) => p.categoryId == null))) {
                _calculateCategoryStartIndicesAndKeys(loadedState.products, loadedState.categories);
                // بازسازی پس از محاسبه اگر کلیدها تازه ساخته شدند
                WidgetsBinding.instance.addPostFrameCallback((_) { if(mounted) setState((){}); });
            }


          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // --- ✨ اینجا ویجت AppBar اصلاح شده فراخوانی می‌شود ---
                  _buildUxImprovedSliverAppBar(context, widget.store),
                  
                  SliverPersistentHeader(
                    delegate: _CategoryHeaderDelegate(
                      categories: loadedState.categories,
                      // TODO: افزودن دسته بندی "سایر" اگر محصولی با categoryId=null وجود دارد
                      // categories: _getCategoriesWithUncategorized(loadedState), 
                      selectedIndex: _selectedCategoryIndex,
                      scrollController: _categoryScrollController,
                      onCategorySelected: (index) {
                        if (_selectedCategoryIndex != index) { setState(() { _selectedCategoryIndex = index; }); }
                        _scrollToCategoryChip(index);
                        _scrollToProductCategory(index);
                      },
                    ),
                    pinned: true,
                  ),
                  _buildProductSliverList(context, loadedState, _categoryStartIndexMap, _categoryTitleKeys),
                ],
              ),
              if (state is ProductLoaded && state.isLoadingOptions)
                Container( color: Colors.black.withAlpha((255 * 0.3).round()), child: const Center(child: CircularProgressIndicator(color: Colors.white)), ),
              if (state is ProductLoading) // نمایش لودر هنگام رفرش
                Positioned( top: MediaQuery.of(context).padding.top + kToolbarHeight + 60, left: 0, right: 0, child: const LinearProgressIndicator(),),
            ],
          );
        },
      ),
    );
  }


  // --- 💎 این ویجت به طور کامل برای بهبود UX بازنویسی شده است 💎 ---
  Widget _buildUxImprovedSliverAppBar(BuildContext context, StoreEntity store) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      
      // --- ✨ بهبود UX (بخش ۱): عنوان استاندارد برای حالت جمع‌شده ---
      // این عنوان فقط زمانی که AppBar جمع است نمایش داده می‌شود.
      title: Text(store.name, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      centerTitle: true, // عنوان را در مرکز قرار می‌دهد
      // ---

      actions: [
        // دکمه‌های اطلاعات و جستجو حفظ شدند
        IconButton(icon: const Icon(Icons.search), onPressed: () {/* TODO: Search */}),
        IconButton(icon: const Icon(Icons.info_outline), onPressed: () {/* TODO: Store Info */}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // --- ❌ بهبود UX: عنوان خود FlexibleSpaceBar حذف شد ---
        // title: Text( store.name, ... ), // <-- حذف شد چون سلسله مراتب بصری را خراب می‌کرد
        
        background: Stack(
          fit: StackFit.expand,
          children: [
            // تصویر پس‌زمینه
            CustomNetworkImage(
              imageUrl: store.logoUrl ?? 'https://via.placeholder.com/400x200',
              fit: BoxFit.cover,
            ),
            
            // گرادیانت برای خوانایی متن
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((255 * 0.3).round()),
                    Colors.black.withAlpha((255 * 0.8).round())
                  ],
                  stops: const [0.0, 0.4, 1.0], // گرادیانت قوی‌تر در پایین
                ),
              ),
            ),
            
            // محتوای اصلی هدر (نام، امتیاز، زمان)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- ✨ بهبود UX (بخش ۱): نام فروشگاه با فونت بزرگ ---
                  // این نام اصلی فروشگاه در حالت باز است.
                  Text(
                    store.name,
                    style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black.withAlpha(150), blurRadius: 4, offset: Offset(0, 1))]
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // ---

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- ✨ بهبود UX (بخش ۲): دکمه نظرات (قابل کلیک) ---
                      // کل این بخش اکنون یک دکمه است
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/store-reviews', // روت صفحه نظرات
                            arguments: {
                              'storeId': store.id,
                              'storeName': store.name,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rate_rounded, color: Colors.yellow[600], size: 20),
                              const SizedBox(width: 4),
                              Text(
                                store.rating.toStringAsFixed(1),
                                style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${store.ratingCount}+ نظر)', // متن واضح‌تر
                                style: textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 16),
                            ],
                          ),
                        ),
                      ),
                      // ---

                      const Spacer(),
                      
                      // ویجت زمان تحویل (بدون تغییر)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((255 * 0.6).round()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              store.deliveryTimeEstimate,
                              style: textTheme.bodySmall?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  
                  // نمایش دسته‌بندی غذا (Cuisine)
                   if(store.cuisineType.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.only(top: 6.0),
                       child: Text(
                         store.cuisineType,
                         style: textTheme.bodyMedium?.copyWith(color: Colors.grey[200]),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- 💎 پایان بخش اصلاح‌شده 💎 ---


  Widget _buildProductSliverList(BuildContext context, ProductLoaded state, Map<int, int> categoryStartIndexMap, Map<int, GlobalKey> categoryTitleKeys) {
     if (state.products.isEmpty) { return const SliverFillRemaining( child: Center(child: Text("محصولی یافت نشد.")) ); }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = state.products[index];
            final categoryId = product.categoryId;

            int? categoryStartIndex = categoryStartIndexMap[categoryId ?? -1];
            bool isFirstItemInCategory = (index == categoryStartIndex);
            GlobalKey? categoryKey = categoryTitleKeys[categoryId ?? -1];

            final categoryName = categoryId == null
                ? "سایر" // نام پیش فرض برای محصولات بدون دسته بندی
                : state.categories
                    .firstWhere((cat) => cat.id == categoryId, orElse: () => const ProductCategoryEntity(id: -1, storeId: -1, name: 'نامشخص'))
                    .name;

            return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (isFirstItemInCategory)
                  Padding(
                    key: categoryKey ?? ValueKey('category_title_${categoryId ?? -1}_$index'), // Fallback key
                    padding: const EdgeInsets.only(top: 20, bottom: 12, right: 8, left: 8),
                    child: Text( categoryName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600), ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: _ProductCard( product: product, onTap: () {
                    setState(() { _viewingOptionsForProductId = product.id; });
                    context.read<ProductCubit>().fetchProductOptions(product.id);
                  }, ),
                ),
                if (index == state.products.length - 1) const SizedBox(height: 80), // پدینگ در انتها
              ], );
          },
          childCount: state.products.length,
        ),
      ),
    );
  }


  void _showOptionsModal(BuildContext context, ProductEntity product, List<OptionGroupEntity> options, CartBloc cartBloc) {
    if (!mounted) return;
    showModalBottomSheet( context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (modalContext) {
        return ProductOptionsModal( product: product, optionGroups: options, cartBloc: cartBloc, );
      }, );
  }

}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});
  @override
  Widget build(BuildContext context) { 
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( product.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 6),
                    if (product.description.isNotEmpty)
                      Padding( padding: const EdgeInsets.only(bottom: 8.0), child: Text( product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]), ), )
                    else
                      const SizedBox(height: 8), // اگر توضیحات نبود، فضا را حفظ کن

                    Row( children: [
                      Text( '${product.finalPrice.toStringAsFixed(0)} ت', style: textTheme.bodyLarge?.copyWith( color: colorScheme.primary, fontWeight: FontWeight.bold, ), ),
                      if (product.discountPrice != null && product.discountPrice! < product.price)
                        Padding( padding: const EdgeInsets.only(right: 8.0), child: Text( '${product.price.toStringAsFixed(0)} ت', style: textTheme.bodyMedium?.copyWith( color: Colors.grey, decoration: TextDecoration.lineThrough, ), ), ),
                    ], ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect( borderRadius: BorderRadius.circular(8.0), child: CustomNetworkImage( imageUrl: product.imageUrl, width: 90, height: 90, fit: BoxFit.cover, ), ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<ProductCategoryEntity> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final ScrollController scrollController;

  _CategoryHeaderDelegate({ required this.categories, required this.selectedIndex, required this.onCategorySelected, required this.scrollController, });

  @override
  Widget build( BuildContext context, double shrinkOffset, bool overlapsContent) {
    // اگر دسته‌بندی خالی بود، یک فضای خالی 60 پیکسلی برگردان
    if (categories.isEmpty) { 
      return Container(
         height: 60.0, 
         color: Theme.of(context).scaffoldBackgroundColor,
         // یک خط پایین اضافه می‌کنیم تا با حالت عادی یکسان باشد
         decoration: BoxDecoration( 
            color: Theme.of(context).scaffoldBackgroundColor, 
            border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.0))
         ),
      ); 
    }
    
    return Container( 
      height: 60.0, 
      decoration: BoxDecoration( 
        color: Theme.of(context).scaffoldBackgroundColor, 
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
              onSelected: (bool selected) { if (selected) { onCategorySelected(index); } },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100), 
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle( 
                color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                fontSize: 13
              ),
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(20), 
                side: BorderSide( color: isSelected ? Colors.transparent : Colors.grey.withAlpha(50), ), 
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
              labelPadding: const EdgeInsets.symmetric(horizontal: 14.0), 
              padding: EdgeInsets.zero, 
              showCheckmark: false, 
              visualDensity: VisualDensity.compact,
            ), 
          ); 
        }, 
      ), 
    ); 
  }

  @override double get maxExtent => 60.0;
  @override double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex || 
           categories != oldDelegate.categories;
           // از listEquals برای مقایسه عمیق لیست‌ها استفاده کنید اگر محتوای آنها تغییر می‌کند
           // listEquals(categories, oldDelegate.categories);
  }
}