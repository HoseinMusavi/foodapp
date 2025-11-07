// lib/main.dart

import 'package:customer_app/core/di/service_locator.dart' as di;
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/features/auth/presentation/pages/login_page.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/features/cart/presentation/pages/order_tracking_page.dart';
import 'package:customer_app/features/checkout/domain/entities/order_entity.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:customer_app/features/customer/presentation/pages/address_details_form_page.dart';
import 'package:customer_app/features/customer/presentation/pages/map_address_selection_page.dart';
import 'package:customer_app/features/customer/presentation/pages/select_address_page.dart';
import 'package:customer_app/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customer_app/core/utils/lat_lng.dart' as core_lat_lng;
// --- Checkout ---
import 'package:customer_app/features/checkout/presentation/pages/checkout_summary_page.dart';
// --- ایمپورت‌های جدید ---
import 'package:customer_app/features/order/presentation/cubit/order_history_cubit.dart';
import 'package:customer_app/features/order/presentation/pages/submit_review_page.dart';
import 'package:customer_app/features/store/presentation/pages/store_reviews_page.dart'; // <-- ایمپورت جدید (بخش ۳)
// ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zjtnzzammmyuagxatwgf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdG56emFtbW15dWFneGF0d2dmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwNzI5NjksImV4cCI6MjA2OTY0ODk2OX0.arRyVtvhA0w5xdopkQC8bRZ0hnKKtIJIaXtYkoKMbJw',
  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<CartBloc>()..add(CartStarted()),
        ),
        BlocProvider(
          create: (context) => di.sl<OrderHistoryCubit>(), 
        ),
      ],
      child: MaterialApp(
        title: 'فود اپ',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());

      case '/select-address':
        return MaterialPageRoute(builder: (_) => const SelectAddressPage());

      case '/map-select':
        return MaterialPageRoute(
            builder: (_) => const MapAddressSelectionPage());

      case '/address-details-form':
        final location = settings.arguments as core_lat_lng.LatLng;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: di.sl<CustomerCubit>(),
            child: AddressDetailsFormPage(location: location),
          ),
        );

      case '/checkout-summary':
        if (settings.arguments is AddressEntity) {
          final address = settings.arguments as AddressEntity;
          return MaterialPageRoute(
            builder: (_) => CheckoutSummaryPage(selectedAddress: address),
          );
        } else {
          print('Error: Invalid arguments type for /checkout-summary. Expected AddressEntity, got ${settings.arguments?.runtimeType}');
          return MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: const Center(child: Text('خطا در بارگذاری خلاصه سفارش'))));
        }

      case '/track-order':
        return MaterialPageRoute(
          settings: settings, 
          builder: (_) => const OrderTrackingPage(),
        );
        
      case '/submit-review':
        if (settings.arguments is OrderEntity) {
          final order = settings.arguments as OrderEntity;
          return MaterialPageRoute(
            builder: (_) => SubmitReviewPage(order: order),
          );
        } else {
          return MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: const Center(child: Text('خطا: سفارش معتبر نیست.'))));
        }

      // --- مسیر جدید اضافه شد (بخش ۳) ---
      case '/store-reviews':
        // ما storeId و storeName را به عنوان Map پاس خواهیم داد
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final int? storeId = args['storeId'];
          final String? storeName = args['storeName'];

          if (storeId != null && storeName != null) {
            return MaterialPageRoute(
              builder: (_) => StoreReviewsPage(
                storeId: storeId,
                storeName: storeName,
              ),
            );
          }
        }
        return MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: const Center(child: Text('خطا: شناسه رستوران نامعتبر است.'))));
      // ---

      default:
        print('Warning: Route ${settings.name} not defined.');
        return null;
    }
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          
          final customerState = di.sl<CustomerCubit>().state;
          if (customerState is CustomerInitial) {
            di.sl<CustomerCubit>().fetchCustomerDetails();
          }
          
          try {
            final cartState = context.read<CartBloc>().state;
            if(cartState is! CartLoaded && cartState is! CartLoading){
              context.read<CartBloc>().add(CartStarted());
            }
          } catch(e) {
            print("AuthGate: Could not read CartBloc state on login: $e");
            context.read<CartBloc>().add(CartStarted());
          }

          try {
            final orderState = context.read<OrderHistoryCubit>().state;
            if (orderState is OrderHistoryInitial) {
               context.read<OrderHistoryCubit>().fetchOrderHistory();
            }
          } catch (e) {
            print("AuthGate: Could not read OrderHistoryCubit state on login: $e");
          }

          return const MainShell();
        } else {
          if (context.mounted) {
            try {
              context.read<CartBloc>().add(CartStarted(forceRefresh: true));
            } catch (e) {
              print("Could not find CartBloc provider in AuthGate during logout reset: $e");
            }
          }
          return const LoginPage();
        }
      },
    );
  }
}