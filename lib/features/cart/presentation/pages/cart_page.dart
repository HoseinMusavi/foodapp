// lib/features/cart/presentation/pages/cart_page.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سبد خرید شما')),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
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

            // --- ✨ FIX: Handle possible null storeName ---
            final groupedByStore = groupBy(
              state.cart.items,
              (CartItemEntity item) =>
                  item.product.storeName ?? 'فروشگاه نامشخص',
            );

            return Column(
              children: [
                Expanded(
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
                _TotalsCard(cart: state.cart),
              ],
            );
          }
          return const Center(child: Text('در حال بارگذاری سبد خرید...'));
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بازگشت به فروشگاه‌ها'),
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.storefront,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  storeName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => _CartItemRow(item: items[index]),
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemEntity item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final finalPrice = item.product.discountPrice ?? item.product.price;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CustomNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${finalPrice.toStringAsFixed(0)} تومان',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _buildQuantityButton(
                context: context,
                icon: Icons.add,
                color: colorScheme.primary,
                onPressed: () {
                  context.read<CartBloc>().add(
                    CartProductQuantityUpdated(
                      product: item.product,
                      newQuantity: item.quantity + 1,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('${item.quantity}', style: textTheme.titleMedium),
              ),
              _buildQuantityButton(
                context: context,
                icon: item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                color: colorScheme.error,
                onPressed: () {
                  context.read<CartBloc>().add(
                    CartProductQuantityUpdated(
                      product: item.product,
                      newQuantity: item.quantity - 1,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final CartEntity cart;
  const _TotalsCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.all(12.0),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'جمع کل (${cart.totalItems} کالا):',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${cart.totalPrice.toStringAsFixed(0)} تومان',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cart.items.isEmpty ? null : () {},
                  child: const Text('ادامه و پرداخت'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
