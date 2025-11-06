// lib/features/order/presentation/pages/order_history_page.dart

// --- اصلاح شد: ایمپورت di حذف شد ---
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/core/widgets/custom_network_image.dart';
import 'package:customer_app/features/order/presentation/cubit/order_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- اصلاح شد: BlocProvider حذف شد ---
    // کیوبیت حالا از main.dart (بالای این ویجت) تامین می‌شود
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه سفارشات'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderHistoryCubit>().fetchOrderHistory();
        },
        child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
          builder: (context, state) {
            // --- اصلاح شد: اگر state اولیه بود، واکشی کن ---
            if (state is OrderHistoryInitial) {
              context.read<OrderHistoryCubit>().fetchOrderHistory();
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is OrderHistoryLoading && state is! OrderHistoryLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderHistoryLoaded) {
              if (state.orders.isEmpty) {
                return LayoutBuilder( 
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(
                        child: Text('شما هنوز سفارشی ثبت نکرده‌اید.'),
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _OrderHistoryCard(
                    order: order,
                    reviewedOrderIds: state.reviewedOrderIds,
                  );
                },
              );
            }
            if (state is OrderHistoryError) {
              return Center(
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('خطا: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<OrderHistoryCubit>().fetchOrderHistory(),
                      child: const Text('تلاش مجدد'),
                    )
                  ],
                ),
              );
            }
            
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
    // --- پایان اصلاح ---
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderEntity order;
  final Set<int> reviewedOrderIds;

  const _OrderHistoryCard({
    required this.order,
    required this.reviewedOrderIds,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final formatCurrency = intl.NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );
    final formatDate = intl.DateFormat('d MMMM yyyy - HH:mm', 'fa_IR');

    final bool canReview = order.status == OrderStatus.delivered &&
        !reviewedOrderIds.contains(order.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(30), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/track-order', arguments: order.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CustomNetworkImage(
                      imageUrl: order.store?.logoUrl ?? 'https://via.placeholder.com/150',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.store?.name ?? 'نام فروشگاه',
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${order.id} • ${formatDate.format(order.createdAt)}',
                          style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, order.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مبلغ نهایی',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  Text(
                    formatCurrency.format(order.totalPrice),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('مشاهده فاکتور'),
                      onPressed: () {
                         Navigator.pushNamed(context, '/track-order', arguments: order.id);
                      },
                    ),
                  ),
                  if (canReview) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.star_outline, size: 20),
                        label: const Text('ثبت نظر'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondaryContainer,
                          foregroundColor: colorScheme.onSecondaryContainer,
                          elevation: 0,
                        ),
                        // --- اصلاح شد: فعال‌سازی دکمه ---
                        onPressed: () {
                          // (معیار پذیرش ۲.۱)
                          Navigator.pushNamed(
                            context,
                            '/submit-review',
                            arguments: order, // آبجکت کامل سفارش پاس داده می‌شود
                          );
                        },
                        // ---
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    final (label, color) = switch (status) {
      OrderStatus.pending => ('در انتظار', Colors.grey),
      OrderStatus.confirmed => ('تایید شده', Colors.blue),
      OrderStatus.preparing => ('در حال آماده‌سازی', Colors.orange),
      OrderStatus.delivering => ('در حال ارسال', Colors.cyan),
      OrderStatus.delivered => ('تحویل داده شد', Colors.green),
      OrderStatus.cancelled => ('لغو شده', Colors.red),
    };

    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}