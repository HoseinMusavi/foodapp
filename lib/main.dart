// lib/main.dart

import 'package:customer_app/core/di/service_locator.dart' as di;
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/auth/presentation/pages/login_page.dart';
import 'package:customer_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:customer_app/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/features/cart/presentation/pages/order_tracking_page.dart';
import 'package:customer_app/features/checkout/presentation/pages/checkout_summary_page.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:customer_app/features/customer/presentation/pages/address_details_form_page.dart';
import 'package:customer_app/features/customer/presentation/pages/map_address_selection_page.dart';
import 'package:customer_app/features/customer/presentation/pages/select_address_page.dart';
import 'package:customer_app/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:customer_app/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:customer_app/features/product/presentation/cubit/product_cubit.dart';
import 'package:customer_app/features/product/presentation/pages/product_list_page.dart';
import 'package:customer_app/features/store/domain/entities/store_entity.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/core/utils/lat_lng.dart' as core_lat_lng;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await supabase.Supabase.initialize(
    url: 'https://zjtnzzammmyuagxatwgf.supabase.co',
    anonKey:         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdG56emFtbW15dWFneGF0d2dmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwNzI5NjksImV4cCI6MjA2OTY0ODk2OX0.arRyVtvhA0w5xdopkQC8bRZ0hnKKtIJIaXtYkoKMbJw',

  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider در بالاترین سطح، کلوب‌ها/کوبیت‌های سراسری را فراهم می‌کند.
    // توجه: create() باید تابعی باشد که به context وابسته نباشد (از sl استفاده می‌کنیم).
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()),
        BlocProvider<CustomerCubit>(create: (_) => di.sl<CustomerCubit>()),
        BlocProvider<CartBloc>(create: (_) => di.sl<CartBloc>()),
        // Product/Dashboard و ... را در صورت نیاز بالا اضافه کنید
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
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainShell());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/store-details':
        final store = settings.arguments as StoreEntity;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => di.sl<ProductCubit>(),
            child: ProductListPage(store: store),
          ),
        );
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());

      case '/select-address':
        return MaterialPageRoute(builder: (_) => const SelectAddressPage());

      case '/map-select':
        return MaterialPageRoute(builder: (_) => const MapAddressSelectionPage());

      case '/address-details-form':
        final location = settings.arguments as core_lat_lng.LatLng;
        return MaterialPageRoute(
          builder: (context) => AddressDetailsFormPage(location: location),
        );

      case '/checkout-summary':
        if (settings.arguments is AddressEntity) {
          final address = settings.arguments as AddressEntity;
          // اینجا ما CheckoutCubit را در سطح صفحه ارائه می‌کنیم.
          // اما CheckoutSummaryPage خودش یک نسخه امن هم دارد که از ancestor استفاده می‌کند.
          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => di.sl<CheckoutCubit>(),
              child: CheckoutSummaryPage(selectedAddress: address),
            ),
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('خطا در پارامترهای مسیر /checkout-summary')),
            ),
          );
        }

      case '/track-order':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrderTrackingPage(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}

/// AuthGate: IMPORTANT
/// - ما از StreamBuilder برای شنیدن auth state استفاده می‌کنیم، اما تمام تعاملات با Bloc/Cubit
///   که می‌توانند‌ provider-not-found بسازند، بعد از اولین فریم اجرا می‌شوند.
/// - این جلوگیری می‌کند از پیام‌های "used a BuildContext that does not include the provider".
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<supabase.AuthState>(
      stream: supabase.Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          // نکته: از addPostFrameCallback استفاده می‌کنیم تا خواندن و فراخوانی cubitها
          // پس از اولین فریم انجام شود (دیگر در همان چرخه‌ی build خوانده نمی‌شود).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // مشتری را اگر در حالت اولیه است بارگذاری کن
            try {
              final customerCubit = context.read<CustomerCubit>();
              if (customerCubit.state is CustomerInitial) {
                customerCubit.fetchCustomerDetails();
              }
            } catch (_) {
              // در صورت نبودن CustomerCubit، هیچ چیز انجام نمی‌شود
            }

            // رفرش سبد خرید
            try {
              context.read<CartBloc>().add(CartStarted(forceRefresh: true));
            } catch (_) {}
          });

          return const MainShell();
        } else {
          // در خروج، باز هم عملیات‌ها را بعد از فریم اجرا کن تا از خطا جلوگیری شود
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              context.read<CartBloc>().add(CartStarted(forceRefresh: true));
            } catch (_) {}
          });
          return const LoginPage();
        }
      },
    );
  }
}
