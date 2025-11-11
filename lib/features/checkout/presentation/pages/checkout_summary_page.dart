import 'package:customer_app/core/di/service_locator.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CheckoutSummaryPage extends StatefulWidget {
  final AddressEntity selectedAddress;

  const CheckoutSummaryPage({super.key, required this.selectedAddress});

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  final _couponController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );

    final cartState = context.watch<CartBloc>().state;
    final cart = (cartState is CartLoaded) ? cartState.cart : null;

    if (cart == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطا')),
        body: const Center(child: Text('سبد خرید یافت نشد! لطفا دوباره امتحان کنید.')),
      );
    }

    double finalTotalPrice = cart.totalPrice;
    double deliveryFee = 0;
    double discountAmount = 0;

    return BlocProvider(
      create: (context) => sl<CheckoutCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خلاصه سفارش و پرداخت'),
        ),
        body: BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              // **** Removed const and forceRefresh ****
              context.read<CartBloc>().add(CartStarted());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سفارش شما با شماره ${state.orderId} با موفقیت ثبت شد.'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/track-order',
                 (route) => route.isFirst,
                 arguments: state.orderId,
              );
            }
            if (state is CheckoutFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطا در ثبت سفارش: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            final isProcessing = state is CheckoutProcessing;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
              children: [
                _buildSectionCard(
                  context,
                  title: 'آدرس تحویل',
                  icon: Icons.location_on_outlined,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(widget.selectedAddress.title, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(
                      widget.selectedAddress.fullAddress,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    trailing: TextButton(
                      child: const Text('تغییر آدرس'),
                      onPressed: isProcessing ? null : () {
                         Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                 _buildSectionCard(
                  context,
                  title: 'محصولات (${cart.totalItems} کالا)',
                  icon: Icons.shopping_basket_outlined,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      cart.items.map((item) => '• ${item.quantity} عدد ${item.product.name}').join('\n'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6, color: Colors.grey[800]),
                    ),
                  )
                 ),
                 const SizedBox(height: 16),

                _buildSectionCard(
                  context,
                  title: 'کد تخفیف',
                  icon: Icons.discount_outlined,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                     children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            enabled: !isProcessing,
                            decoration: const InputDecoration(
                              hintText: 'کد تخفیف (اختیاری)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _applyCoupon(context, isProcessing),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isProcessing ? null : () => _applyCoupon(context, isProcessing),
                          child: const Text('اعمال'),
                        )
                      ],
                    ),
                  )
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context,
                  title: 'توضیحات سفارش (اختیاری)',
                  icon: Icons.note_alt_outlined,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: TextField(
                      controller: _notesController,
                      enabled: !isProcessing,
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'مثال: سس اضافه نفرستید، زنگ واحد ۲ را بزنید...',
                        border: OutlineInputBorder(),
                        isDense: true,
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  )
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(77),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                      children: [
                         _buildPriceRow(context, 'جمع کل سبد خرید', cart.totalPrice, formatCurrency),
                         _buildPriceRow(context, 'هزینه ارسال', deliveryFee, formatCurrency),
                         _buildPriceRow(context, 'تخفیف اعمال شده', discountAmount, formatCurrency, isDiscount: true),
                         const Divider(height: 24, thickness: 0.5),
                         _buildPriceRow(context, 'مبلغ نهایی قابل پرداخت', finalTotalPrice, formatCurrency, isTotal: true),
                      ],
                     ),
                  )
                ),
                 const SizedBox(height: 24),

                 ElevatedButton.icon(
                   icon: isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline),
                   label: Text(isProcessing ? 'در حال ثبت سفارش...' : 'پرداخت و ثبت نهایی'),
                   style: ElevatedButton.styleFrom(
                     minimumSize: const Size(double.infinity, 50),
                   ),
                   onPressed: isProcessing ? null : () {
                      context.read<CheckoutCubit>().submitOrder(
                        address: widget.selectedAddress,
                        couponCode: _couponController.text.trim().isEmpty ? null : _couponController.text.trim(),
                        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                      );
                   },
                 ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String title, double amount, NumberFormat format, {bool isTotal = false, bool isDiscount = false}) {
     final style = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]);
     final amountColor = isDiscount && amount > 0
        ? Colors.redAccent[700]
        : (isTotal ? Theme.of(context).colorScheme.primary : null);

      String formattedAmount = format.format(amount);
      if (isDiscount && amount > 0) {
         formattedAmount = '- $formattedAmount';
      } else if (isDiscount && amount == 0) {
        formattedAmount = '۰${format.currencyName}';
      }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(
             formattedAmount,
             style: style?.copyWith(color: amountColor, fontWeight: isTotal ? FontWeight.bold : null, letterSpacing: 0.5),
             // **** Corrected TextDirection ****
            //  textDirection: TextDirection.RTL,

          ),
        ],
      ),
    );
  }

  void _applyCoupon(BuildContext context, bool isProcessing) {
      if (isProcessing) return;
      final code = _couponController.text.trim();
      if (code.isNotEmpty) {
        // TODO: Implement coupon validation and application logic
        print("Applying coupon: $code");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قابلیت کد تخفیف هنوز پیاده‌سازی نشده است.')),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفا کد تخفیف را وارد کنید.')),
        );
      }
      FocusScope.of(context).unfocus();
  }
}