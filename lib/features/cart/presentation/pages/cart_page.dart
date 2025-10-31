import 'package:collection/collection.dart';
import 'package:customer_app/features/checkout/presentation/pages/checkout_summary_page.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
// import 'package:customer_app/features/product/domain/entities/product_entity.dart'; // Unused
import 'package:flutter/material.dart'; // <-- Added import for TextDirection
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';
import 'package:intl/intl.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سبد خرید شما'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'بارگذاری مجدد',
            onPressed: () {
              // **** Removed const ****
              context.read<CartBloc>().add(CartStarted());
            },
          )
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 3),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartLoaded) {
            if (state.cart.items.isEmpty) {
              return _buildEmptyCartView(context);
            }

            final groupedByStore = groupBy(
                state.cart.items,
                (CartItemEntity item) =>
                    item.product.storeName ?? 'فروشگاه نامشخص');

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // **** Removed const ****
                       context.read<CartBloc>().add(CartStarted());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: groupedByStore.keys.length,
                      itemBuilder: (context, index) {
                        final storeName = groupedByStore.keys.elementAt(index);
                        final itemsFromStore = groupedByStore[storeName]!;
                        return _StoreCartCard(
                          storeName: storeName,
                          items: itemsFromStore,
                        );
                      },
                    ),
                  ),
                ),
                _TotalsCard(cart: state.cart),
              ],
            );
          }

          if (state is CartError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'خطا در بارگذاری سبد خرید:\n${state.message}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('تلاش مجدد'),
                      // **** Removed const ****
                      onPressed: () => context.read<CartBloc>().add(CartStarted()),
                    )
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('وضعیت نامشخص سبد خرید'));
        },
      ),
    );
  }

  Widget _buildEmptyCartView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'سبد خرید شما خالی است.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
           const SizedBox(height: 8),
           Text(
            'محصولات مورد علاقه خود را اضافه کنید!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          // ElevatedButton.icon(
          //   icon: const Icon(Icons.storefront_outlined),
          //   label: const Text('مشاهده فروشگاه‌ها'),
          //   onPressed: () {
          //     // TODO: Navigate back to store list or home
          //      if (Navigator.of(context).canPop()) {
          //        Navigator.of(context).pop();
          //      }
          //   },
          // ),
        ],
      ),
    );
  }
}

class _StoreCartCard extends StatelessWidget {
  final String storeName;
  final List<CartItemEntity> items;

  const _StoreCartCard({required this.storeName, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => _CartItemRow(item: items[index]),
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16, thickness: 0.5),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemEntity item;

  const _CartItemRow({required this.item});

  Widget _buildOptions(BuildContext context, CartItemEntity item) {
    if (item.selectedOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    // final optionsByGroup = groupBy( // Grouping might be overly complex here
    //   item.selectedOptions,
    //   (OptionEntity option) => option.groupName ?? 'گزینه‌ها',
    // );
     final optionsText = item.selectedOptions.map((opt) => opt.name).join('، ');


    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text( // Simpler display
            optionsText,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600], height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
      // child: Column( // Original grouping code (kept for reference)
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: optionsByGroup.entries.map((entry) {
      //     // final groupName = entry.key; // Unused variable
      //     final optionsInGroup = entry.value.map((opt) => opt.name).join('، ');
      //     return Text(
      //       optionsInGroup,
      //       style: Theme.of(context)
      //           .textTheme
      //           .bodySmall
      //           ?.copyWith(color: Colors.grey[600], height: 1.4),
      //       maxLines: 2,
      //       overflow: TextOverflow.ellipsis,
      //     );
      //   }).toList(),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: '',
      decimalDigits: 0,
    );

    final unitPrice = item.totalPrice / item.quantity;

    return InkWell(
      onTap: () {
        // TODO: Navigate to product details page?
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CustomNetworkImage(
                imageUrl: item.product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  _buildOptions(context, item),
                  const SizedBox(height: 4),
                  Text(
                    '${formatCurrency.format(unitPrice)} تومان',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 _buildQuantityControls(context, item, colorScheme),
                 const SizedBox(height: 8),
                 Text(
                   '${formatCurrency.format(item.totalPrice)} ت',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5
                    ),
                    // **** Corrected TextDirection ****
                    // textDirection: TextDirection.ltr,
                 )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItemEntity item, ColorScheme colorScheme){
      return Row(
            children: [
              _buildQuantityButton(
                context: context,
                icon: Icons.add_circle_outline,
                color: colorScheme.primary,
                onPressed: () {
                  context.read<CartBloc>().add(
                        CartProductQuantityUpdated(
                          cartItemId: item.id,
                          newQuantity: item.quantity + 1,
                        ),
                      );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('${item.quantity}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              _buildQuantityButton(
                context: context,
                icon: item.quantity > 1 ? Icons.remove_circle_outline : Icons.delete_forever_outlined,
                color: item.quantity > 1 ? colorScheme.error : Colors.red[800],
                onPressed: () {
                  if (item.quantity > 1) {
                    context.read<CartBloc>().add(
                          CartProductQuantityUpdated(
                            cartItemId: item.id,
                            newQuantity: item.quantity - 1,
                          ),
                        );
                  } else {
                    showDialog(
                       context: context,
                       builder: (dialogContext) => AlertDialog(
                         title: Text('حذف ${item.product.name}'),
                         content: const Text('آیا از حذف این آیتم از سبد خرید مطمئن هستید؟'),
                         actions: [
                            TextButton(
                              child: const Text('لغو'),
                              onPressed: () => Navigator.of(dialogContext).pop(),
                            ),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(backgroundColor: colorScheme.errorContainer),
                              child: Text('حذف', style: TextStyle(color: colorScheme.onErrorContainer)),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.read<CartBloc>().add(
                                      CartProductRemoved(cartItemId: item.id),
                                    );
                              },
                            ),
                         ],
                       )
                    );
                  }
                },
              ),
            ],
          );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 22, color: color ?? Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final CartEntity cart;
  const _TotalsCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: '',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 4.0,
      shape: const RoundedRectangleBorder(
         borderRadius: BorderRadius.only(
           topLeft: Radius.circular(16),
           topRight: Radius.circular(16),
         )
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'جمع کل (${cart.totalItems} کالا):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${formatCurrency.format(cart.totalPrice)} تومان',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.5
                      ),
                  // **** Corrected TextDirection ****
                  // textDirection: TextDirection.ltr,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('انتخاب آدرس و ادامه'),
                style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 14),
                   textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                onPressed: cart.items.isEmpty
                    ? null
                    : () async {
                        final selectedAddress = await Navigator.pushNamed(
                          context,
                          '/select-address',
                        );

                        if (selectedAddress is AddressEntity && context.mounted) {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => CheckoutSummaryPage(
                                 selectedAddress: selectedAddress,
                               ),
                             ),
                           );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}