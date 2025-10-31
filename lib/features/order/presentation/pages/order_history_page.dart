// lib/features/order/presentation/pages/order_history_page.dart

import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/order/presentation/cubit/order_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cubit توسط MainShell فراهم شده، پس فقط read می‌کنیم
    final cubit = context.read<OrderHistoryCubit>();
    
    // اگر حالت اولیه بود، داده‌ها رو فچ می‌کنیم
    if (cubit.state is OrderHistoryInitial) {
      cubit.fetchOrderHistory();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه سفارش‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cubit.fetchOrderHistory(),
          ),
        ],
      ),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        builder: (context, state) {
          
          if (state is OrderHistoryLoading || state is OrderHistoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderHistoryFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'خطا در دریافت اطلاعات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                     const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => cubit.fetchOrderHistory(),
                      child: const Text('تلاش مجدد'),
                    )
                  ],
                ),
              ),
            );
          }

          if (state is OrderHistoryLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 24),
                    Text(
                      'هنوز سفارشی ثبت نکرده‌اید',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'اولین سفارش خود را ثبت کنید!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // نمایش لیست سفارش‌ها
            return RefreshIndicator(
              onRefresh: () => cubit.fetchOrderHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _OrderHistoryCard(order: order);
                },
              ),
            );
          }

          return const Center(child: Text('وضعیت نامشخص'));
        },
      ),
    );
  }
}

// ****** ویجت کارت کاملاً بازطراحی شد ******
class _OrderHistoryCard extends StatelessWidget {
  final OrderEntity order;
  
  const _OrderHistoryCard({required this.order});

  // مپ کردن وضعیت به متن فارسی
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'در انتظار تایید';
      case OrderStatus.confirmed: return 'تایید شده';
      case OrderStatus.preparing: return 'در حال آماده‌سازی';
      case OrderStatus.delivering: return 'در حال ارسال';
      case OrderStatus.delivered: return 'تحویل داده شد';
      case OrderStatus.cancelled: return 'لغو شده';
      default: return 'نامشخص';
    }
  }

  // مپ کردن وضعیت به رنگ
  Color _getStatusColor(OrderStatus status, BuildContext context) {
     switch (status) {
      case OrderStatus.pending: return Colors.orange.shade700;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.delivering:
        return Theme.of(context).colorScheme.primary;
      case OrderStatus.delivered: return Colors.green.shade700;
      case OrderStatus.cancelled: return Theme.of(context).colorScheme.error;
      default: return Colors.grey.shade700;
    }
  }

  // مپ کردن وضعیت به آیکون
  IconData _getStatusIcon(OrderStatus status) {
     switch (status) {
      case OrderStatus.pending: return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed: return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing: return Icons.kitchen_rounded;
      case OrderStatus.delivering: return Icons.delivery_dining_outlined;
      case OrderStatus.delivered: return Icons.check_circle_rounded;
      case OrderStatus.cancelled: return Icons.cancel_rounded;
      default: return Icons.receipt_long_outlined;
    }
  }


  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );
    final statusText = _getStatusText(order.status);
    final statusColor = _getStatusColor(order.status, context);
    final statusIcon = _getStatusIcon(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5)
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // ** با کلیک روی کارت، به صفحه پیگیری همون سفارش میریم **
        onTap: () {
          Navigator.pushNamed(
            context,
            '/track-order',
            arguments: order.id, // <-- پاس دادن ID سفارش
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(statusIcon, color: statusColor, size: 26),
            ),
            title: Text(
              'سفارش #${order.id}', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.4
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'تاریخ: ${DateFormat('d MMMM yyyy – HH:mm', 'fa_IR').format(order.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency.format(order.totalPrice),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.2
                  ),
                ),
                 const SizedBox(height: 4),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}