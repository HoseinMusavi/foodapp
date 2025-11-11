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

// --- ۱. AuthCubit ایمپورت شود ---
import 'features/auth/presentation/cubit/auth_cubit.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    StoreListPage(),
    CartPage(),
    OrderHistoryPage(),
    CustomerProfilePage(),
  ];

  void _onItemTapped(int index) {
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
        // --- اصلاح شد: فراخوانی تابع از اینجا حذف شد ---
        // حالا این تابع فقط یک بار در AuthGate فراخوانی می‌شود
        BlocProvider.value(
          value: sl<CustomerCubit>(), // <-- .fetchCustomerDetails() حذف شد
        ),
        // ---
        BlocProvider(
          create: (context) => sl<StoreCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<OrderHistoryCubit>(),
        ),
        // --- ۲. AuthCubit اینجا اضافه شد ---
        BlocProvider(
          create: (context) => sl<AuthCubit>(),
        ),
      ],
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              label: 'فروشگاه‌ها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'سبد خرید',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
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