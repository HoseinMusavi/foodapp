import 'package:customer_app/core/di/service_locator.dart' as di; // service_locator.dart as di
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

  // --- متغیرهای جدید برای نگه‌داشتن وضعیت ---
  double _discountAmount = 0.0;
  String _validatedCouponCode = '';
  // ---

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

    // --- اصلاح شد: اینها بر اساس استیت محاسبه می‌شوند ---
    // TODO: هزینه ارسال را از بک‌اند بگیرید
    double deliveryFee = 0; 
    double finalTotalPrice = cart.totalPrice + deliveryFee - _discountAmount;
    // ---

    return BlocProvider(
      create: (context) => di.sl<CheckoutCubit>(), // از di.sl استفاده شد
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خلاصه سفارش و پرداخت'),
        ),
        body: BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            // --- listener برای ثبت نهایی سفارش ---
            if (state is CheckoutSuccess) {
              context.read<CartBloc>().add(CartStarted(forceRefresh: true)); // forceRefresh اضافه شد

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
            } else if (state is CheckoutFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطا در ثبت سفارش: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            // --- listener جدید برای کد تخفیف ---
            else if (state is CheckoutCouponValidating) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 16),
                        Text('در حال بررسی کد تخفیف...'),
                      ],
                    ),
                    backgroundColor: Colors.blueGrey,
                  ),
                );
            } else if (state is CheckoutCouponFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
            } else if (state is CheckoutCouponSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('تخفیف ${state.discountAmount} تومان اعمال شد.'),
                    backgroundColor: Colors.green,
                  ),
                );
              // ذخیره مقادیر موفق در State ویجت
              setState(() {
                _discountAmount = state.discountAmount;
                _validatedCouponCode = _couponController.text.trim();
              });
            }
            // --- پایان بخش جدید ---
          },
          builder: (context, state) {
            // --- اصلاح شد: isProcessing حالا شامل اعتبارسنجی کوپن هم می‌شود ---
            final isProcessing = state is CheckoutProcessing;
            final isCouponValidating = state is CheckoutCouponValidating;
            final isCouponApplied = state is CheckoutCouponSuccess;
            // ---

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
                      onPressed: isProcessing ? null : () { // در هنگام ثبت نهایی غیرفعال شود
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

                // --- بخش کد تخفیف اصلاح شد ---
                _buildSectionCard(
                  context,
                  title: 'کد تخفیف',
                  icon: Icons.discount_outlined,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Row(
                         children: [
                           Expanded(
                             child: TextField(
                               controller: _couponController,
                               // اگر در حال پردازش *یا* کوپن اعمال شده است، غیرفعال کن
                               enabled: !isProcessing && !isCouponApplied, 
                               decoration: InputDecoration(
                                 hintText: 'کد تخفیف (اختیاری)',
                                 border: const OutlineInputBorder(),
                                 isDense: true,
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                 // اگر کوپن اعمال شده، سبز کن
                                 fillColor: isCouponApplied ? Colors.green.withAlpha(50) : null,
                                 filled: isCouponApplied,
                               ),
                               textInputAction: TextInputAction.done,
                               onSubmitted: (_) => _applyCoupon(context, cart.totalPrice, isProcessing || isCouponValidating),
                               onChanged: (value) {
                                  // اگر کاربر کد را عوض کرد، تخفیف اعمال شده را ریست کن
                                  if (_discountAmount > 0 || _validatedCouponCode.isNotEmpty) {
                                    setState(() {
                                      _discountAmount = 0;
                                      _validatedCouponCode = '';
                                    });
                                    // استیت کیوبیت را هم ریست کن (با فراخوانی تابع با کد خالی)
                                    context.read<CheckoutCubit>().applyCoupon(couponCode: '', subtotal: cart.totalPrice);
                                  }
                                },
                             ),
                           ),
                           const SizedBox(width: 8),
                           ElevatedButton(
                             // اگر در حال پردازش یا اعتبارسنجی یا اعمال شده، غیرفعال کن
                             onPressed: isProcessing || isCouponValidating || isCouponApplied ? null : () => _applyCoupon(context, cart.totalPrice, false),
                             // اگر در حال اعتبارسنجی است لودینگ نشان بده
                             child: isCouponValidating
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : (isCouponApplied ? const Icon(Icons.check) : const Text('اعمال')),
                           )
                         ],
                        ),
                        // نمایش پیام خطا از کیوبیت
                        if (state is CheckoutCouponFailure)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.message,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                      ],
                    ),
                  )
                ),
                // --- پایان بخش اصلاح شده ---
                const SizedBox(height: 16),

                _buildSectionCard(
                  context,
                  title: 'توضیحات سفارش (اختیاری)',
                  icon: Icons.note_alt_outlined,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: TextField(
                      controller: _notesController,
                      enabled: !isProcessing, // در هنگام ثبت نهایی غیرفعال شود
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
                  // اصلاح شد: withAlpha(77)
                  color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(77),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         children: [
                           _buildPriceRow(context, 'جمع کل سبد خرید', cart.totalPrice, formatCurrency),
                           _buildPriceRow(context, 'هزینه ارسال', deliveryFee, formatCurrency),
                           // --- اصلاح شد: از متغیر _discountAmount استفاده می‌کند ---
                           _buildPriceRow(context, 'تخفیف اعمال شده', _discountAmount, formatCurrency, isDiscount: true),
                           const Divider(height: 24, thickness: 0.5),
                           // --- اصلاح شد: از متغیر finalTotalPrice استفاده می‌کند ---
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
                  onPressed: isProcessing || isCouponValidating ? null : () { // هنگام اعتبارسنجی کوپن هم غیرفعال شود
                       context.read<CheckoutCubit>().submitOrder(
                         address: widget.selectedAddress,
                         // --- اصلاح شد: _validatedCouponCode ارسال می‌شود ---
                         couponCode: _validatedCouponCode.isEmpty ? null : _validatedCouponCode,
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
      : (isTotal ? Theme.of(context).colorScheme.primary : Colors.grey[800]); // اصلاح شد: رنگ خاکستری برای مقادیر عادی

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
            style: style?.copyWith(color: amountColor, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, letterSpacing: 0.5), // اصلاح شد: fontWeight
          ),
        ],
      ),
    );
  }

  // --- تابع اعمال کوپن اصلاح و تکمیل شد ---
  void _applyCoupon(BuildContext context, double subtotal, bool isProcessing) {
     if (isProcessing) return; // اگر هر نوع پردازشی در جریان است، خارج شو
     final code = _couponController.text.trim();
     if (code.isNotEmpty) {
       // --- فراخوانی متد از کیوبیت ---
       context.read<CheckoutCubit>().applyCoupon(
             couponCode: code,
             subtotal: subtotal, // --- اصلاح شد: totalPrice سبد خرید پاس داده شد ---
           );
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('لطفا کد تخفیف را وارد کنید.')),
       );
     }
     FocusScope.of(context).unfocus();
  }
  // ---
}