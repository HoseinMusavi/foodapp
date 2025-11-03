// lib/main_shell.dart

import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:customer_app/features/store/presentation/cubit/store_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/pages/cart_page.dart';

import 'features/customer/presentation/pages/customer_profile_page.dart';
import 'features/store/presentation/cubit/dashboard_cubit.dart';
import 'features/store/presentation/pages/store_list_page.dart';

// ایمپورت‌های بخش سفارش
import 'features/order/presentation/cubit/order_history_cubit.dart';
import 'features/order/presentation/pages/order_history_page.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // ****** 1. ترتیب ویجت‌ها اصلاح شد ******
  static const List<Widget> _widgetOptions = <Widget>[
    StoreListPage(),
    CartPage(),         // <-- سبد خرید (ایندکس ۱)
    OrderHistoryPage(), // <-- سفارش‌ها (ایندکس ۲)
    CustomerProfilePage(),
  ];

  void _onItemTapped(int index) {
    // ****** 2. منطق رفرش اصلاح شد ******
    // اگر روی تب تاریخچه سفارش‌ها (ایندکس ۲) کلیک شد، لیست رو رفرش می‌کنیم
    if (index == 2) { 
      try {
        context.read<OrderHistoryCubit>().fetchOrderHistory();
      } catch (e) {
        print("Could not refetch order history: $e");
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DashboardCubit>()..fetchDashboardData(),
        ),
        BlocProvider.value(
          value: sl<CustomerCubit>()..fetchCustomerDetails(),
        ),
        BlocProvider(
          create: (context) => sl<StoreCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<OrderHistoryCubit>(),
        ),
      ],
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        // ****** 3. ترتیب آیتم‌ها اصلاح شد ******
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              label: 'فروشگاه‌ها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), // <-- آیتم سبد خرید
              label: 'سبد خرید', 
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), // <-- آیتم سفارش‌ها
              label: 'سفارش‌ها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'پروفایل',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[700], 
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}