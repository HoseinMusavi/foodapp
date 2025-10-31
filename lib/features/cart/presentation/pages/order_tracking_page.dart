// lib/features/cart/presentation/pages/order_tracking_page.dart

import 'package:customer_app/core/di/service_locator.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/checkout/domain/entities/order_item_entity.dart';
import 'package:customer_app/features/order/presentation/cubit/order_tracking_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments as int?;

    if (orderId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطا')),
        body: const Center(child: Text('خطا: شماره سفارش یافت نشد.')),
      );
    }

    return BlocProvider(
      create: (context) => sl<OrderTrackingCubit>()
        ..startTrackingOrder(orderId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('جزئیات سفارش #${orderId.toString()}'),
        ),
        body: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
          builder: (context, state) {
            
            if (state is OrderTrackingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderTrackingError) {
              return Center(
                child: Text('خطا در دریافت سفارش: ${state.message}'),
              );
            }

            // ****** 1. اینجا اصلاح شد (از OrderTrackingStreaming به OrderTrackingLoaded) ******
            if (state is OrderTrackingLoaded) {
              // ****** 2. StreamBuilder حذف شد و order مستقیماً از state خوانده شد ******
              final order = state.order;
              
              // اگر سفارش لغو شده یا تحویل شده بود، UI ساده‌تری نشون میدیم
              if (order.status == OrderStatus.cancelled) {
                return _buildFinalStatusView(
                  context: context,
                  icon: Icons.cancel_rounded,
                  color: Theme.of(context).colorScheme.error,
                  title: 'سفارش لغو شد',
                  subtitle: 'این سفارش توسط شما یا رستوران لغو شده است.',
                );
              }
              if (order.status == OrderStatus.delivered) {
                 return _buildFinalStatusView(
                  context: context,
                  icon: Icons.check_circle_rounded,
                  color: Colors.green.shade700,
                  title: 'سفارش تحویل داده شد',
                  subtitle: 'از خرید شما متشکریم. نوش جان!',
                );
              }
              
              // در غیر این صورت، UI کامل پیگیری رو نشون میدیم
              return _buildTrackingDetails(context, order);
            }
            return const Center(child: Text('در حال بارگذاری...'));
          },
        ),
      ),
    );
  }

  // (ادامه کد بدون تغییر، چون از قبل منتظر OrderEntity بود)
  
  /// ویجت اصلی برای نمایش جزئیات سفارش (وقتی فعال است)
  Widget _buildTrackingDetails(BuildContext context, OrderEntity order) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ****** 3. کارت جدید اطلاعات فروشگاه اضافه شد ******
        _buildStoreInfoCard(context, order),
        const SizedBox(height: 16),
        _buildTrackingTimeline(context, order.status),
        const SizedBox(height: 24),
        _buildOrderItemsCard(context, order.items),
        const SizedBox(height: 16),
        _buildPriceSummaryCard(context, order),
        if(order.notes != null && order.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildNotesCard(context, order.notes!),
        ]
      ],
    );
  }

  /// ویجت برای نمایش وضعیت‌های نهایی (لغو شده / تحویل شده)
  Widget _buildFinalStatusView({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    // ... (کد این ویجت بدون تغییر) ...
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color.withOpacity(0.8)), // <-- ** 4. اخطار deprecated حل شد **
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
           const SizedBox(height: 40),
           ElevatedButton.icon(
             icon: const Icon(Icons.receipt_long_outlined),
             label: const Text('بازگشت به لیست سفارش‌ها'),
             style: ElevatedButton.styleFrom(
               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
               textStyle: Theme.of(context).textTheme.titleMedium,
             ),
             onPressed: () {
               if(Navigator.canPop(context)) {
                 Navigator.pop(context);
               }
             },
           )
        ],
      ),
    );
  }

  /// == بخش‌های UI ==

  // ****** 5. کارت جدید: اطلاعات فروشگاه ******
  Widget _buildStoreInfoCard(BuildContext context, OrderEntity order) {
    // اگر اطلاعات فروشگاه به هر دلیلی join نشده بود، چیزی نشان نده
    if (order.store == null) {
      return const SizedBox.shrink();
    }
    
    final store = order.store!;
    return Card(
       elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // (این بخش نیاز به ویجت CustomNetworkImage دارد)
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12.0),
            //   child: CustomNetworkImage(
            //     imageUrl: store.logoUrl,
            //     width: 60,
            //     height: 60,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            // const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سفارش از',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// کارت تایم‌لاین وضعیت سفارش
  Widget _buildTrackingTimeline(BuildContext context, OrderStatus currentStatus) {
    // ... (کد این ویجت بدون تغییر) ...
     final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.delivering,
    ];
    
    final currentIndex = allStatuses.indexOf(currentStatus);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'وضعیت سفارش',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Column(
              children: List.generate(allStatuses.length, (index) {
                final status = allStatuses[index];
                final bool isActive = index <= currentIndex;
                final bool isCurrent = index == currentIndex;
                
                return _buildTimelineStep(
                  context,
                  title: _getStatusText(status),
                  icon: _getStatusIcon(status),
                  isFirst: index == 0,
                  isLast: index == allStatuses.length - 1,
                  isActive: isActive,
                  isCurrent: isCurrent,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// ویجت یک مرحله از تایم‌لاین
  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
    bool isActive = false,
    bool isCurrent = false,
  }) {
    // ... (کد این ویجT بدون تغییر) ...
    final activeColor = isCurrent 
        ? Theme.of(context).colorScheme.primary 
        : Colors.green.shade600;
    final inactiveColor = Colors.grey[300]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 12,
              color: isFirst ? Colors.transparent : (isActive ? activeColor : inactiveColor),
            ),
            CircleAvatar(
              radius: isCurrent ? 18 : 16,
              backgroundColor: isActive ? activeColor : inactiveColor,
              child: Icon(icon, color: Colors.white, size: isCurrent ? 20 : 18),
            ),
            Container(
              width: 2,
              height: 40,
              color: isLast ? Colors.transparent : (isActive ? activeColor : inactiveColor),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Text(
            title,
            style: (isActive
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])
            )?.copyWith(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// کارت محصولات سفارش
  Widget _buildOrderItemsCard(BuildContext context, List<OrderItemEntity> items) {
    // ... (کد این ویجت بدون تغییر) ...
     return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'محصولات سفارش',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            // ****** 6. این چک اضافه شد (برای زمانی که آیتم‌ها هنوز لود نشدند) ******
            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('در حال بارگذاری آیتم‌های سفارش...'),
                ),
              )
            else
              ...items.map((item) => _buildOrderItemTile(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  /// ویجت یک آیتم در لیست محصولات
  Widget _buildOrderItemTile(BuildContext context, OrderItemEntity item) {
    // ... (کد این ویجت بدون تغییر) ...
     final formatCurrency = NumberFormat.simpleCurrency(locale: 'fa_IR', name: ' تومان', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '${item.quantity}x',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.options.isNotEmpty)
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      item.options.map((o) => o.optionName).join('، '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatCurrency.format(item.priceAtPurchase * item.quantity),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// کارت خلاصه پرداخت
  Widget _buildPriceSummaryCard(BuildContext context, OrderEntity order) {
    // ... (کد این ویجت بدون تغییر) ...
     final formatCurrency = NumberFormat.simpleCurrency(locale: 'fa_IR', name: ' تومان', decimalDigits: 0);
    
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خلاصه پرداخت',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildPriceRow(context, 'جمع کل سبد خرید', formatCurrency.format(order.subtotalPrice)),
            _buildPriceRow(context, 'هزینه ارسال', formatCurrency.format(order.deliveryFee)),
            if (order.discountAmount > 0)
              _buildPriceRow(
                context,
                'تخفیف اعمال شده',
                '- ${formatCurrency.format(order.discountAmount)}',
                color: Theme.of(context).colorScheme.error,
              ),
            const Divider(height: 20, thickness: 0.5),
            _buildPriceRow(
              context,
              'مبلغ نهایی پرداخت شده',
              formatCurrency.format(order.totalPrice),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// کارت توضیحات
  Widget _buildNotesCard(BuildContext context, String notes) {
     // ... (کد این ویجت بدون تغییر) ...
      return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توضیحات سفارش',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Text(
              notes,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }


  /// == توابع کمکی ==

  Widget _buildPriceRow(BuildContext context, String title, String amount, {Color? color, bool isTotal = false}) {
    // ... (کد این ویجت بدون تغییر) ...
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal 
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          Text(
            amount,
            style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
              : Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    // ****** 7. اخطار Unreachable case حل شد (حذف default) ******
    switch (status) {
      case OrderStatus.pending: return 'در انتظار تایید';
      case OrderStatus.confirmed: return 'تایید شده';
      case OrderStatus.preparing: return 'در حال آماده‌سازی';
      case OrderStatus.delivering: return 'در حال ارسال';
      case OrderStatus.delivered: return 'تحویل داده شد';
      case OrderStatus.cancelled: return 'لغو شده';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
     // ****** 8. اخطار Unreachable case حل شد (حذف default) ******
     switch (status) {
      case OrderStatus.pending: return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed: return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing: return Icons.kitchen_rounded;
      case OrderStatus.delivering: return Icons.delivery_dining_outlined;
      case OrderStatus.delivered: return Icons.check_circle_rounded;
      case OrderStatus.cancelled: return Icons.cancel_rounded;
    }
  }
}