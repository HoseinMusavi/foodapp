// lib/features/store/presentation/pages/store_reviews_page.dart

import 'package:customer_app/core/di/service_locator.dart' as di;
import 'package:customer_app/core/widgets/custom_network_image.dart';
import 'package:customer_app/features/store/domain/entities/store_review_entity.dart';
import 'package:customer_app/features/store/presentation/cubit/store_reviews_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart' as intl;

class StoreReviewsPage extends StatelessWidget {
  final int storeId;
  final String storeName;

  const StoreReviewsPage({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StoreReviewsCubit>()..fetchReviews(storeId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('نظرات رستوران $storeName'),
        ),
        body: BlocBuilder<StoreReviewsCubit, StoreReviewsState>(
          builder: (context, state) {
            if (state is StoreReviewsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StoreReviewsError) {
              return Center(child: Text('خطا: ${state.message}'));
            }
            if (state is StoreReviewsLoaded) {
              if (state.reviews.isEmpty) {
                return const Center(child: Text('هنوز نظری برای این رستوران ثبت نشده است.'));
              }
              // معیار ۳.۵ (مرتب‌سازی) در RPC بک‌اند انجام شده است (ORDER BY created_at DESC)
              return ListView.builder(
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  return _ReviewCard(review: state.reviews[index]);
                },
              );
            }
            return const Center(child: Text('در حال بارگذاری نظرات...'));
          },
        ),
      ),
    );
  }
}

// ویجت نمایش هر ردیف نقد (مطابق معیار ۳.۴)
class _ReviewCard extends StatelessWidget {
  final StoreReviewEntity review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formatDate = intl.DateFormat('d MMMM yyyy', 'fa_IR');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shadowColor: Colors.black.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // دایره‌ای
                  child: CustomNetworkImage(
                    imageUrl: review.customerAvatarUrl ?? 'https://via.placeholder.com/150',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatDate.format(review.createdAt),
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating.toDouble(),
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 18.0,
                  direction: Axis.horizontal,
                ),
              ],
            ),
            // نمایش متن نظر (فقط اگر وجود داشته باشد)
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                review.comment!,
                style: textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}