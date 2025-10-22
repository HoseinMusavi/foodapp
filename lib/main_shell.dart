// lib/main_shell.dart
import 'package:customer_app/features/store/presentation/cubit/store_cubit.dart'; // <-- ۱. ایمپورت StoreCubit
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/customer/presentation/cubit/customer_cubit.dart';
import 'features/customer/presentation/pages/customer_profile_page.dart';
import 'features/store/presentation/cubit/dashboard_cubit.dart';
import 'features/store/presentation/pages/store_list_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    StoreListPage(), // صفحه اصلی ما
    CartPage(),
    CustomerProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ۲. ما Cubit های اصلی را اینجا فراهم می‌کنیم
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DashboardCubit>()..fetchDashboardData(),
        ),
     BlocProvider(
                     create: (context) => sl<CustomerCubit>()..fetchCustomerDetails(),
  ),
        // --- ۳. این خط را اضافه کنید ---
        BlocProvider(
          create: (context) => sl<StoreCubit>(), // StoreCubit حالا فراهم شده
        ),
        // ------------------------------
        // CartBloc هم باید اینجا فراهم شود چون در صفحات مختلف نیاز است
        BlocProvider(
          create: (context) => sl<CartBloc>()..add(CartStarted()),
          lazy: false, // فوراً لود شود
        ),
      ],
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              icon: Icon(Icons.person_outline),
              label: 'پروفایل',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}