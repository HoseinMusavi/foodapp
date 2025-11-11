// lib/features/order/presentation/pages/submit_review_page.dart

import 'package:customer_app/core/di/service_locator.dart' as di;
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/presentation/cubit/order_history_cubit.dart';
import 'package:customer_app/features/order/presentation/cubit/submit_review_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SubmitReviewPage extends StatelessWidget {
  final OrderEntity order;
  const SubmitReviewPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SubmitReviewCubit>(),
      // ما OrderHistoryCubit را از صفحه‌ی قبل دریافت می‌کنیم
      // تا بتوانیم پس از ثبت نظر، آن را رفرش کنیم.
      child: BlocProvider.value(
        value: context.read<OrderHistoryCubit>(),
        child: SubmitReviewView(order: order),
      ),
    );
  }
}

class SubmitReviewView extends StatefulWidget {
  final OrderEntity order;
  const SubmitReviewView({super.key, required this.order});

  @override
  State<SubmitReviewView> createState() => _SubmitReviewViewState();
}

class _SubmitReviewViewState extends State<SubmitReviewView> {
  final _commentController = TextEditingController();
  double _rating = 0.0; // ستاره‌ها اجباری هستند

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت نظر'),
      ),
      body: BlocConsumer<SubmitReviewCubit, SubmitReviewState>(
        listener: (context, state) {
          if (state is SubmitReviewSuccess) {
            // معیار پذیرش ۲.۵
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('از بازخورد شما متشکریم!'),
                  backgroundColor: Colors.green,
                ),
              );
            
            // رفرش کردن تاریخچه سفارشات (تا دکمه "ثبت نظر" مخفی شود)
            context.read<OrderHistoryCubit>().fetchOrderHistory();
            
            // بازگشت به صفحه تاریخچه
            Navigator.of(context).pop();
          } else if (state is SubmitReviewError) {
             ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is SubmitReviewSubmitting;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معیار پذیرش ۲.۲ (نام رستوران)
                  Text(
                    'نظر شما در مورد رستوران:',
                    style: textTheme.bodyLarge,
                  ),
                  Text(
                    widget.order.store?.name ?? 'نام فروشگاه',
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // معیار پذیرش ۲.۲ (انتخاب ستاره)
                  Text(
                    'امتیاز شما (اجباری)',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // معیار پذیرش ۲.۲ (فیلد متن)
                  Text(
                    'نظر شما (اختیاری)',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    readOnly: isSubmitting,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'تجربه خود را بنویسید...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // معیار پذیرش ۲.۲ (دکمه ثبت)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (widget.order.storeId == null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('خطای سیستمی: شناسه رستوران یافت نشد.'))
                              );
                              return;
                            }
                            // فراخوانی کیوبیت
                            context.read<SubmitReviewCubit>().submitReview(
                                  orderId: widget.order.id,
                                  storeId: widget.order.storeId!,
                                  rating: _rating,
                                  comment: _commentController.text,
                                );
                          },
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ثبت نهایی نظر'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}