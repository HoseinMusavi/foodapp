// lib/main.dart

import 'package:customer_app/core/di/service_locator.dart' as di;
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/features/auth/presentation/pages/login_page.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/features/cart/presentation/pages/order_tracking_page.dart';
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
    return BlocProvider(
      create: (context) => di.sl<CartBloc>()..add(CartStarted()),
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

      // ****** اینجا اصلاح شد ******
      case '/track-order':
        // ما باید آبجکت settings رو به MaterialPageRoute پاس بدیم
        // تا صفحه OrderTrackingPage بتونه arguments (یعنی orderId) رو بخونه.
        return MaterialPageRoute(
          settings: settings, // <-- این خط حیاتی اضافه شد
          builder: (_) => const OrderTrackingPage(),
        );
      // ****** پایان اصلاح ******

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

          return const MainShell();
        } else {
          // Reset cart on logout
          if (context.mounted) {
            try {
              // Ensure CartStarted accepts forceRefresh (non-const constructor)
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