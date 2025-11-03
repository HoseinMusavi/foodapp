import 'package:customer_app/core/di/service_locator.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// **** نوع LatLng سفارشی خودتان را ایمپورت کنید ****
import 'package:customer_app/core/utils/lat_lng.dart' as core_lat_lng; // <-- ایمپورت نوع LatLng شما

class SelectAddressPage extends StatelessWidget {
  const SelectAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    // اگر CustomerCubit به عنوان سینگلتون ثبت شده، می‌توانیم از BlocProvider خالی استفاده کنیم
    // در غیر این صورت باید create را بنویسیم
    // return BlocProvider(
    //   create: (context) => sl<CustomerCubit>()..getAddresses(),
    return BlocProvider.value( // با فرض اینکه سینگلتون است
       value: sl<CustomerCubit>()..getAddresses(), // فراخوانی getAddresses اینجا
       child: Scaffold(
        appBar: AppBar(
          title: const Text('انتخاب آدرس'),
        ),
        body: BlocConsumer<CustomerCubit, CustomerState>(
          listener: (context, state) {
             if (state is CustomerAddressesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطا: ${state.message}')),
              );
            }
            // اگر آدرس جدید ذخیره شد، لیست را دوباره بخوان
            if (state is CustomerAddressSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('آدرس جدید با موفقیت ذخیره شد.'), backgroundColor: Colors.green),
              );
              context.read<CustomerCubit>().getAddresses();
            }
          },
          builder: (context, state) {
             if (state is CustomerAddressesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // نمایش لیست آدرس‌ها (چه در حالت Loaded چه Saving چه Saved)
            // از آخرین لیست موجود استفاده میکنیم
            List<AddressEntity> addresses = [];
            if (state is CustomerAddressesLoaded) {
              addresses = state.addresses;
            } else if (context.read<CustomerCubit>().state is CustomerAddressesLoaded) {
              // اگر state فعلی Loaded نیست (مثلا Saving است)، از state قبلی بخوان
              addresses = (context.read<CustomerCubit>().state as CustomerAddressesLoaded).addresses;
            }


            return Column(
              children: [
                Expanded(
                  child: addresses.isEmpty && state is! CustomerAddressSaving
                      ? const Center(child: Text('هیچ آدرسی ذخیره نشده است.'))
                      : RefreshIndicator( // اضافه کردن قابلیت رفرش با کشیدن
                          onRefresh: () async {
                             context.read<CustomerCubit>().getAddresses();
                          },
                          child: ListView.builder(
                              itemCount: addresses.length,
                              itemBuilder: (context, index) {
                                final address = addresses[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on_outlined),
                                  title: Text(address.title),
                                  subtitle: Text(address.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                  onTap: () {
                                    // TODO: رفتن به صفحه خلاصه نهایی با این آدرس
                                    Navigator.pop(context, address); // فعلا فقط برمیگردیم
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'آدرس "${address.title}" انتخاب شد')),
                                    );
                                  },
                                );
                              },
                            ),
                        ),
                ),
                // نمایش لودر هنگام ذخیره آدرس جدید
                if (state is CustomerAddressSaving)
                   const Padding(
                     padding: EdgeInsets.all(8.0),
                     child: Column(
                       children: [
                         LinearProgressIndicator(),
                         SizedBox(height: 8),
                         Text('در حال ذخیره آدرس...'),
                       ],
                     ),
                   ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('افزودن آدرس جدید روی نقشه'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: state is CustomerAddressSaving ? null : () async { // غیرفعال کردن دکمه هنگام ذخیره
                      // ۱. رفتن به نقشه و گرفتن موقعیت (از نوع core_lat_lng.LatLng)
                      final selectedLocation = await Navigator.of(context).pushNamed(
                        '/map-select',
                      ) as core_lat_lng.LatLng?; // <- تغییر نوع به نوع سفارشی شما

                      if (selectedLocation == null) return; // کاربر لغو کرد

                      // ۲. رفتن به فرم جزئیات و ارسال موقعیت (از نوع core_lat_lng.LatLng)
                      // ignore: use_build_context_synchronously
                      await Navigator.of(context).pushNamed(
                        '/address-details-form',
                        arguments: selectedLocation, // <- ارسال نوع سفارشی شما
                      );
                      // نیازی به getAddresses نیست چون listener این کار را میکند
                    },
                  ),
                )
              ],
            );

            // این بخش دیگر لازم نیست چون حالت Saving را جداگانه مدیریت کردیم
            /*
            if (state is CustomerAddressSaving) {
               return const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('در حال ذخیره آدرس...'),
                ],
               ));
            }
            */

            // return const Center(child: Text('وضعیت نامشخص')); // حالت پیش فرض
          },
        ),
      ),
    );
  }
}