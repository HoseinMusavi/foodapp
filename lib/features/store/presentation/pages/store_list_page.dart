// lib/features/store/presentation/pages/store_list_page.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:customer_app/features/promotion/domain/entities/promotion_entity.dart';
import 'package:customer_app/features/store/presentation/cubit/dashboard_cubit.dart';
import '../../domain/entities/store_entity.dart';
import '../../../product/presentation/pages/product_list_page.dart';

// --- ۱. بازطراحی مدل دسته‌بندی با آیکون ---
class _CategoryItem {
  final String name;
  final IconData icon; // به جای imageUrl از IconData استفاده می‌کنیم
  _CategoryItem({required this.name, required this.icon});
}

class StoreListPage extends StatefulWidget {
  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // --- ۲. تعریف لیست جدید دسته‌بندی‌ها با آیکون‌های Material ---
  final List<_CategoryItem> categoryItems = [
    _CategoryItem(name: 'همه', icon: Icons.storefront_outlined),
    _CategoryItem(name: 'برگر', icon: Icons.fastfood_outlined),
    _CategoryItem(name: 'پیتزا', icon: Icons.local_pizza_outlined),
    _CategoryItem(name: 'ایرانی', icon: Icons.rice_bowl_outlined),
    _CategoryItem(name: 'کافه', icon: Icons.local_cafe_outlined),
    _CategoryItem(name: 'آسیایی', icon: Icons.ramen_dining_outlined),
    // می‌توانید دسته‌بندی‌های دیگری مثل "سایر" را هم اضافه کنید
    // _CategoryItem(name: 'سایر', icon: Icons.tap_and_play_outlined),
  ];
  
  final GlobalKey _storesTitleKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        
        final storesTitleContext = _storesTitleKey.currentContext;
        if (storesTitleContext != null) {
          Scrollable.ensureVisible(
            storesTitleContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.0,
          );
        }
      });
    }
  }


  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted && query != context.read<DashboardCubit>().state.searchQuery) {
        context.read<DashboardCubit>().searchStores(query);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<DashboardCubit, DashboardState>(
        listenWhen: (prev, current) => 
            (prev.searchQuery != current.searchQuery) ||
            (prev.storeStatus != current.storeStatus && current.storeStatus == DataStatus.failure),
        listener: (context, state) {
          if (state.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
            _searchController.clear();
          }
          if (state.storeStatus == DataStatus.failure) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'خطا در واکشی فروشگاه‌ها'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          buildWhen: (prev, current) => prev.promotionStatus != current.promotionStatus,
          builder: (context, state) {
            
            if (state.promotionStatus == DataStatus.loading || state.promotionStatus == DataStatus.initial) {
              return _buildFullPageLoadingSkeleton();
            }

            if (state.promotionStatus == DataStatus.failure) {
              return _buildErrorWidget(
                message: state.errorMessage ?? 'خطا در برقراری ارتباط با سرور',
                onRetry: () =>
                    context.read<DashboardCubit>().fetchDashboardData(),
              );
            }

            return GestureDetector(
              onTap: () {
                if (_searchFocusNode.hasFocus) {
                  _searchFocusNode.unfocus();
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<DashboardCubit>().refreshStores();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildSliverAppBar(context),
                    
                    SliverToBoxAdapter(
                      child: _buildCategoriesSliver(context),
                    ),
                    
                    BlocBuilder<DashboardCubit, DashboardState>(
                      // --- (۱) اصلاحیه: حالا به لیست فروشگاه‌ها هم حساس است ---
                      // تا بتوانیم storeId را در لیست جستجو کنیم
                      buildWhen: (p, c) => p.promotions != c.promotions || p.stores != c.stores,
                      builder: (context, state) {
                        if (state.promotions.isEmpty) {
                          return const SliverToBoxAdapter(child: SizedBox.shrink());
                        }
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSectionTitle('پیشنهادهای ویژه'),
                            // --- (۲) اصلاحیه: ارسال کل state ---
                            _buildPromotionsSliver(context, state),
                          ]),
                        );
                      },
                    ),
                    
                    BlocBuilder<DashboardCubit, DashboardState>(
                      buildWhen: (prev, current) =>
                          prev.storeStatus != current.storeStatus ||
                          prev.selectedCategory != current.selectedCategory,
                      builder: (context, state) {
                        if (state.storeStatus == DataStatus.loading) {
                          return SliverList(
                             delegate: SliverChildListDelegate([
                               _buildSectionTitle(
                                 state.selectedCategory.isEmpty
                                    ? 'همه فروشگاه‌ها'
                                     : 'فروشگاه‌های ${state.selectedCategory}',
                                 key: _storesTitleKey,
                               ),
                               _buildStoresLoadingSkeletonBox(),
                             ]),
                          );
                        }
                        
                        if (state.stores.isEmpty) {
                           return SliverList(
                             delegate: SliverChildListDelegate([
                               _buildSectionTitle(
                                 state.selectedCategory.isEmpty
                                    ? 'همه فروشگاه‌ها'
                                    : 'فروشگاه‌های ${state.selectedCategory}',
                                 key: _storesTitleKey,
                               ),
                               _buildEmptyState('فروشگاهی با این مشخصات یافت نشد!'),
                             ]),
                           );
                        }

                        return SliverList(
                          delegate: SliverChildListDelegate([
                             _buildSectionTitle(
                               state.selectedCategory.isEmpty
                                  ? 'همه فروشگاه‌ها'
                                  : 'فروشگاه‌های ${state.selectedCategory}',
                               key: _storesTitleKey,
                             ),
                            _buildStoresGrid(context, state.stores),
                          ]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.5,
      title: const Text(
        'فود اپ',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ).copyWith(bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: (query) {
                _debounce?.cancel();
                if (mounted && query != context.read<DashboardCubit>().state.searchQuery) {
                  context.read<DashboardCubit>().searchStores(query);
                }
              },
              decoration: InputDecoration(
                hintText: 'جستجو در میان رستوران‌ها...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    );
                  }
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFullPageLoadingSkeleton() {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('دسته‌بندی‌ها'),
                
                SizedBox(
                  height: 70.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    itemCount: 6,
                    itemBuilder: (context, index) => Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                  ),
                ),

                _buildSectionTitle('پیشنهادهای ویژه'),
                Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                _buildSectionTitle('همه فروشگاه‌ها'),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildStoresLoadingSkeletonBox(),
        )
      ],
    );
  }


  Widget _buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: Colors.grey[400], size: 80),
            const SizedBox(height: 20),
            Text(
              'خطایی رخ داد',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSliver(BuildContext context) {
    return SizedBox(
      height: 70.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        itemCount: categoryItems.length,
        itemBuilder: (context, index) {
          final category = categoryItems[index];
          
          return BlocSelector<DashboardCubit, DashboardState, bool>(
            selector: (state) =>
                state.selectedCategory == category.name ||
                (state.selectedCategory.isEmpty && category.name == 'همه'),
            builder: (context, isSelected) {
              final colorScheme = Theme.of(context).colorScheme;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Material(
                  color: isSelected ? colorScheme.primary.withAlpha(40) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30.0),
                    onTap: () {
                      context
                          .read<DashboardCubit>()
                          .selectCategory(category.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(30.0),
                         border: Border.all(
                           color: isSelected ? colorScheme.primary : Colors.transparent,
                           width: 1.5,
                         ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 20,
                            color: isSelected ? colorScheme.primary : Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? colorScheme.primary : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- (۳) اصلاحیه: متد اکنون کل state را می‌گیرد ---
  Widget _buildPromotionsSliver(
    BuildContext context,
    DashboardState state, // به جای List<PromotionEntity>
  ) {
    final promotions = state.promotions; // لیست بنرها
    final allStores = state.stores; // لیست *همه* فروشگاه‌ها
    
    return Column(
      children: [
        SizedBox(
          height: 160.0,
          child: PageView.builder(
            controller: _pageController,
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return GestureDetector(
                onTap: () {
                  // --- (۴) اصلاحیه: منطق کامل ناوبری ---
                  if (promotion.storeId != null) {
                    try {
                      // جستجو در لیست فروشگاه‌های موجود در state
                      final targetStore = allStores.firstWhere(
                        (store) => store.id == promotion.storeId,
                      );
                      
                      // ناوبری به صفحه فروشگاه
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListPage(
                            store: targetStore,
                          ),
                        ),
                      );
                    } catch (e) {
                      // اگر به هر دلیلی فروشگاه پیدا نشد
                      print('Store with id ${promotion.storeId} not found in state.');
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                           content: Text('فروشگاه مورد نظر یافت نشد'),
                           backgroundColor: Colors.red,
                         ),
                       );
                    }
                  } else {
                    // اگر بنر storeId نداشت (مثلاً بنر عمومی اپلیکیشن)
                    print('This promotion is general and has no store link.');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: CachedNetworkImage(
                      imageUrl: promotion.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, u) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (c, u, e) => Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: promotions.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Theme.of(context).colorScheme.primary,
            paintStyle: PaintingStyle.fill,
          ),
        ),
      ],
    );
  }

  Widget _buildStoresGrid(BuildContext context, List<StoreEntity> stores) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth > 600) ? 3 : 2;

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), 
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.82,
        ),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildStoreCard(context, stores[index]),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStoresLoadingSkeletonBox() {
    return Shimmer.fromColors(
       baseColor: Colors.grey[200]!,
       highlightColor: Colors.grey[100]!,
       child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.82,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
       ),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }


  Widget _buildStoreCard(BuildContext context, StoreEntity store) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListPage(
              store: store,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: CachedNetworkImage(
                imageUrl: store.logoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[100]),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.store, color: Colors.grey[300], size: 40),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      store.cuisineType,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color ??
                                    Colors.black,
                                fontFamily: 'Vazir',
                              ),
                              children: [
                                TextSpan(
                                  text: store.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: ' (${store.ratingCount})',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            store.deliveryTimeEstimate,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}