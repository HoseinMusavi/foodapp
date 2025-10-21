// lib/features/customer/presentation/pages/address_list_page.dart

import 'package:flutter/material.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/customer_entity.dart';

class AddressListPage extends StatelessWidget {
  final CustomerEntity customer;
  const AddressListPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('آدرس‌های من'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            tooltip: 'افزودن آدرس',
          ),
        ],
      ),
      body: customer.addresses.isEmpty
          ? const Center(child: Text('هیچ آدرسی ثبت نشده است.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: customer.addresses.length,
              itemBuilder: (context, index) {
                final address = customer.addresses[index];
                final isDefault = address.id == customer.defaultAddressId;
                return _buildAddressCard(context, address, isDefault);
              },
            ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressEntity address,
    bool isDefault,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDefault
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${address.city}, ${address.fullAddress}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'کدپستی: ${address.postalCode}',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('ویرایش'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('حذف'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
