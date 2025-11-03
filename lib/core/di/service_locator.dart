// lib/core/di/service_locator.dart

import 'package:customer_app/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:customer_app/features/promotion/data/repositories/promotion_repository_impl.dart';
import 'package:customer_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:customer_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:customer_app/features/promotion/data/datasources/promotion_remote_datasource.dart';
import 'package:customer_app/features/store/data/datasources/store_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Auth Feature ---
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// --- Cart Feature ---
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_product_to_cart_usecase.dart';
import '../../features/cart/domain/usecases/get_cart_usecase.dart';
import '../../features/cart/domain/usecases/remove_product_from_cart_usecase.dart';
import '../../features/cart/domain/usecases/update_product_quantity_usecase.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

// --- Customer Feature ---
import '../../features/customer/data/datasources/customer_remote_datasource.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/domain/usecases/get_customer_details.dart';
import '../../features/customer/domain/usecases/update_customer_profile.dart';
import '../../features/customer/presentation/cubit/customer_cubit.dart';
import '../../features/customer/domain/usecases/get_addresses_usecase.dart';
import '../../features/customer/domain/usecases/add_address_usecase.dart';

// --- Product Feature ---
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product_categories_usecase.dart';
import '../../features/product/domain/usecases/get_product_options_usecase.dart';
import '../../features/product/domain/usecases/get_products_by_store_usecase.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';

// --- Promotion Feature ---
import '../../features/promotion/domain/repositories/promotion_repository.dart';
import '../../features/promotion/domain/usecases/get_promotions_usecase.dart';

// --- Store Feature ---
import '../../features/store/data/repositories/store_repository_impl.dart';
import '../../features/store/domain/repositories/store_repository.dart';
import '../../features/store/domain/usecases/get_stores_usecase.dart';
import '../../features/store/presentation/cubit/dashboard_cubit.dart';
import '../../features/store/presentation/cubit/store_cubit.dart';

// --- Checkout Feature ---
import '../../features/checkout/data/datasources/checkout_remote_datasource.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../../features/checkout/domain/usecases/place_order_usecase.dart';
// --- ** ایمپورت یوزکیس جدید ** ---
import '../../features/checkout/domain/usecases/validate_coupon_usecase.dart';

// --- Order Feature ---
import '../../features/order/data/datasources/order_remote_datasource.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/domain/usecases/get_order_updates_usecase.dart';
import '../../features/order/presentation/cubit/order_tracking_cubit.dart';
import '../../features/order/domain/usecases/get_my_orders_usecase.dart';
import '../../features/order/presentation/cubit/order_history_cubit.dart';
import '../../features/order/domain/usecases/get_order_details_usecase.dart';
// ---

final sl = GetIt.instance;

Future<void> init() async {
  // #region External Dependencies
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(
    () => Dio(BaseOptions(baseUrl: 'https://fake-api.com')),
  );
  // #endregion

  // #region Features

  // --- Auth ---
  sl.registerFactory(() => AuthCubit(signupUseCase: sl(), loginUseCase: sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Store / Dashboard ---
  sl.registerFactory(
    () => DashboardCubit(getStoresUsecase: sl(), getPromotionsUsecase: sl()),
  );
  sl.registerFactory(() => StoreCubit(getStoresUsecase: sl()));
  sl.registerLazySingleton(() => GetStoresUsecase(sl()));
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Customer ---
  sl.registerLazySingleton(
    () => CustomerCubit(
      getCustomerDetailsUsecase: sl(),
      updateCustomerProfileUsecase: sl(),
      getAddressesUsecase: sl(),
      addAddressUsecase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetCustomerDetails(sl()));
  sl.registerLazySingleton(() => UpdateCustomerProfile(sl()));
  sl.registerLazySingleton(() => GetAddressesUsecase(sl()));
  sl.registerLazySingleton(() => AddAddressUsecase(sl()));
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Product ---
  sl.registerFactory(
    () => ProductCubit(
      // اطمینان از مطابقت نام پارامترها با Cubit
      getProductsUsecase: sl<GetProductsByStoreUsecase>(), 
      getCategoriesUsecase: sl<GetProductCategoriesUsecase>(),
      getOptionsUsecase: sl<GetProductOptionsUsecase>(),
    ),
  );
  sl.registerLazySingleton(() => GetProductsByStoreUsecase(sl()));
  sl.registerLazySingleton(() => GetProductCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetProductOptionsUsecase(sl()));
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Promotion ---
  sl.registerLazySingleton(() => GetPromotionsUsecase(sl()));
  sl.registerLazySingleton<PromotionRepository>(
    () => FakePromotionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Cart ---
  sl.registerFactory(
    () => CartBloc(
      getCart: sl(),
      addProductToCart: sl(),
      removeProductFromCart: sl(),
      updateProductQuantity: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetCartUsecase(sl()));
  sl.registerLazySingleton(() => AddProductToCartUsecase(sl()));
  sl.registerLazySingleton(() => RemoveProductFromCartUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductQuantityUsecase(sl()));
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Checkout ---
  sl.registerFactory(
    () => CheckoutCubit(
      placeOrderUsecase: sl(),
      validateCouponUsecase: sl(), // <-- ** اصلاحیه اصلی اینجا بود **
    ),
  );
  sl.registerLazySingleton(() => PlaceOrderUsecase(sl()));
  sl.registerLazySingleton(() => ValidateCouponUsecase(sl())); // <-- ** این خط اضافه شد **
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(supabaseClient: sl()),
  );
  // --- End Checkout ---

  // ========== Order Feature ==========
  // Cubit
  sl.registerFactory(() => OrderTrackingCubit(
        getOrderUpdatesUsecase: sl(),
        getOrderDetailsUsecase: sl(),
      ));
  sl.registerFactory(() => OrderHistoryCubit(getMyOrdersUsecase: sl()));

  // UseCases
  sl.registerLazySingleton(() => GetOrderUpdatesUsecase(sl()));
  sl.registerLazySingleton(() => GetMyOrdersUsecase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailsUsecase(sl()));

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDatasource: sl()),
  );

  // Datasource
  sl.registerLazySingleton<OrderRemoteDatasource>(
    () => OrderRemoteDataSourceImpl(supabaseClient: sl()),
  );
  // --- End Order ---

  // #endregion
}