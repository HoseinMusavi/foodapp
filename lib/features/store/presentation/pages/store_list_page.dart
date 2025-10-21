// lib/features/store/presentation/pages/store_list_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:customer_app/features/promotion/domain/entities/promotion_entity.dart';
import 'package:customer_app/features/store/presentation/cubit/dashboard_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/store_entity.dart';
import '../../../product/presentation/pages/product_list_page.dart';

// مدل دسته‌بندی را برای استفاده از عکس به‌روز می‌کنیم
class Category {
  final String name;
  final String imageUrl;
  Category({required this.name, required this.imageUrl});
}

class StoreListPage extends StatefulWidget {
  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  final _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => sl<DashboardCubit>()..fetchDashboardData(),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            // --- UX Improvement: Show skeleton loader on initial load ---
            if (state.status == DashboardStatus.loading &&
                state.stores.isEmpty) {
              return _buildLoadingSkeleton();
            }

            // --- UX Improvement: Show a user-friendly error widget with a retry button ---
            if (state.status == DashboardStatus.failure) {
              return _buildErrorWidget(
                message: state.errorMessage ?? 'خطا در برقراری ارتباط با سرور',
                onRetry: () =>
                    context.read<DashboardCubit>().fetchDashboardData(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<DashboardCubit>().fetchDashboardData(),
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context),
                  _buildSectionTitle('دسته‌بندی‌ها'),
                  _buildCategoriesSliver(),
                  if (state.promotions.isNotEmpty) ...[
                    _buildSectionTitle('پیشنهادهای ویژه'),
                    _buildPromotionsSliver(context, state.promotions),
                  ],
                  _buildSectionTitle('همه فروشگاه‌ها'),
                  // --- UX Improvement: Show empty state if no stores are available ---
                  if (state.stores.isEmpty)
                    _buildEmptyState('فروشگاهی یافت نشد!')
                  else
                    _buildStoresGrid(context, state.stores),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- AppBar with a floating search bar ---
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
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
            child: const TextField(
              // TODO: Implement search functionality
              decoration: InputDecoration(
                hintText: 'جستجو در میان رستوران‌ها...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- A reusable widget for section titles ---
  SliverToBoxAdapter _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- UX Improvement: A dedicated widget for the loading skeleton ---
  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          _buildSectionTitle('دسته‌بندی‌ها'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(width: 50, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildSectionTitle('پیشنهادهای ویژه'),
          SliverToBoxAdapter(
            child: Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          _buildSectionTitle('همه فروشگاه‌ها'),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                childCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UX Improvement: A dedicated widget for showing errors ---
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

  // --- UX Improvement: A widget for empty states ---
  SliverFillRemaining _buildEmptyState(String message) {
    return SliverFillRemaining(
      child: Center(
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
      ),
    );
  }

  // --- Categories with added animations and tap feedback ---
  SliverToBoxAdapter _buildCategoriesSliver() {
    final List<Category> categories = [
      Category(
        name: 'برگر',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
      ),
      Category(
        name: 'پیتزا',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/1404/1404945.png',
      ),
      Category(
        name: 'ایرانی',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/9029/9029938.png',
      ),
      Category(
        name: 'کافه',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/924/924514.png',
      ),
      Category(
        name: 'آسیایی',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/4060/4060226.png',
      ),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110.0,
        child: AnimationLimiter(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          // --- UX Improvement: Use InkWell for tap feedback ---
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // TODO: Navigate to category page or filter stores
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  // --- UX Improvement: Use CachedNetworkImage ---
                                  child: CachedNetworkImage(
                                    imageUrl: category.imageUrl,
                                    placeholder: (c, u) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (c, u, e) => Icon(
                                      Icons.fastfood_outlined,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Promotions carousel ---
  SliverToBoxAdapter _buildPromotionsSliver(
    BuildContext context,
    List<PromotionEntity> promotions,
  ) {
    if (promotions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 160.0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promotion = promotions[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    // --- UX Improvement: Use CachedNetworkImage ---
                    child: CachedNetworkImage(
                      imageUrl: promotion.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.grey[200]),
                      errorWidget: (c, u, e) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
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
      ),
    );
  }

  // --- Stores grid with animations ---
  Widget _buildStoresGrid(BuildContext context, List<StoreEntity> stores) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth > 600) ? 3 : 2;

    return AnimationLimiter(
      child: SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.82,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
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
          }, childCount: stores.length),
        ),
      ),
    );
  }

  // --- Store card with improved visuals and tap feedback ---
  Widget _buildStoreCard(BuildContext context, StoreEntity store) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1.0),
      ),
      clipBehavior: Clip
          .antiAlias, // Ensures the InkWell ripple stays within the card's rounded borders
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductListPage(storeId: store.id, storeName: store.name),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: CachedNetworkImage(
                imageUrl: store.logoUrl ?? '',
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
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        // --- UX Improvement: Use RichText for better visual hierarchy ---
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: 'Vazirmatn',
                            ),
                            children: [
                              TextSpan(
                                text: store.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' (${store.ratingCount})',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          store.deliveryTimeEstimate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey,
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
