import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// **** نوع LatLng سفارشی خودتان را ایمپورت کنید ****
import 'package:customer_app/core/utils/lat_lng.dart' as core_lat_lng; // <- ایمپورت نوع LatLng شما

class AddressDetailsFormPage extends StatefulWidget {
  // **** اینجا اصلاح شد ****
  final core_lat_lng.LatLng location; // <- تغییر نوع به نوع سفارشی شما
  const AddressDetailsFormPage({super.key, required this.location});

  @override
  State<AddressDetailsFormPage> createState() => _AddressDetailsFormPageState();
}

class _AddressDetailsFormPageState extends State<AddressDetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController(text: 'بهبهان'); // پیش فرض

  // متغیر برای پیگیری وضعیت لودینگ ذخیره
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _onSaveAddress() async {
    if (_formKey.currentState!.validate()) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا: کاربر احراز هویت نشده است')),
        );
        return;
      }

      setState(() { _isSaving = true; }); // شروع لودینگ

      final newAddress = AddressEntity(
        customerId: userId,
        title: _titleController.text,
        fullAddress: _addressController.text,
        postalCode: _postalCodeController.text.isEmpty
            ? null
            : _postalCodeController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      );

      // فراخوانی Cubit برای ذخیره آدرس
      // منتظر اتمام عملیات می‌مانیم
      await context.read<CustomerCubit>().saveAddress(newAddress);

      // چک کردن state برای اطمینان از عدم خطا قبل از بازگشت
      // (این بخش اختیاری است اما UX بهتری میدهد)
      if (mounted) { // حتما چک کنید ویجت هنوز وجود دارد
        final currentState = context.read<CustomerCubit>().state;
        if (currentState is CustomerAddressesError) {
           // اگر خطا رخ داده بود، لودینگ را متوقف کن و خطا را نشان بده
           setState(() { _isSaving = false; });
           // listener در صفحه قبل خطا را نشان میدهد، پس اینجا لازم نیست
           // ScaffoldMessenger.of(context).showSnackBar(
           //   SnackBar(content: Text('خطا در ذخیره: ${currentState.message}')),
           // );
        } else {
           // اگر خطایی نبود، صفحه را ببند
           // listener در صفحه قبل پیام موفقیت را نشان میدهد
           Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات آدرس'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'موقعیت: ${widget.location.latitude.toStringAsFixed(5)}, ${widget.location.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: 'عنوان آدرس', hintText: 'مثال: خانه، محل کار'),
                validator: (value) =>
                    value!.isEmpty ? 'عنوان اجباری است' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'آدرس کامل متنی', hintText: 'خیابان، کوچه، پلاک، واحد...'),
                maxLines: 3,
                 minLines: 1,
                validator: (value) =>
                    value!.isEmpty ? 'آدرس اجباری است' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                     child: TextFormField(
                       controller: _cityController,
                       decoration: const InputDecoration(labelText: 'شهر'),
                                     validator: (value) =>
                    value!.isEmpty ? 'شهر اجباری است' : null,
                     ),
                   ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(labelText: 'کد پستی (اختیاری)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'در حال ذخیره...' : 'ذخیره آدرس'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                // دکمه را در حین ذخیره غیرفعال کن
                onPressed: _isSaving ? null : _onSaveAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}