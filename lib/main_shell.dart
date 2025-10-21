import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ‼️ ایمپورت Bloc
import 'core/di/service_locator.dart'; // ‼️ ایمپورت Service Locator
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/cart/presentation/pages/order_tracking_page.dart';
import 'features/customer/presentation/pages/customer_profile_page.dart';
import 'features/store/presentation/pages/store_list_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // ‼️ تغییر: لیست صفحات را اینجا تعریف می‌کنیم
  // BlocProvider را به دور CustomerProfilePage اضافه می‌کنیم
  static final List<Widget> _pages = <Widget>[
    const StoreListPage(),
    const CartPage(),
    const OrderTrackingPage(),
    BlocProvider(
      create: (_) => sl<CustomerCubit>()..fetchCustomerDetails(),
      child: const CustomerProfilePage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'فروشگاه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'سبد خرید',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'پیگیری',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حساب',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
      ),
    );
  }
}
