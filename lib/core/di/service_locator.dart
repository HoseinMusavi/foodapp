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

// --- Product Feature ---
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product_categories_usecase.dart'; // <-- ایمپورت
import '../../features/product/domain/usecases/get_product_options_usecase.dart';    // <-- ایمپورت
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
import '../../features/store/presentation/cubit/store_cubit.dart'; // <-- !! ایمپورت StoreCubit !!

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
  // --- !!! این خط اضافه شد !!! ---
  sl.registerFactory(() => StoreCubit(getStoresUsecase: sl()));
  // ------------------------------
  sl.registerLazySingleton(() => GetStoresUsecase(sl()));
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Customer ---
  sl.registerFactory(
    () => CustomerCubit(
      getCustomerDetailsUseCase: sl(), // نام صحیح getCustomerDetailsUseCase است
      updateCustomerProfileUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetCustomerDetails(sl()));
  sl.registerLazySingleton(() => UpdateCustomerProfile(sl()));
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Product ---
  sl.registerFactory(
    () => ProductCubit(
      getProductsUsecase: sl(),
      getCategoriesUsecase: sl(),
      getOptionsUsecase: sl(),
    ),
  );
  // **!! اطمینان از عدم ثبت تکراری GetProductsByStoreUsecase !!**
  // فقط یک بار باید ثبت شود (اینجا یا جای دیگر)
  sl.registerLazySingleton(() => GetProductsByStoreUsecase(sl()));
  sl.registerLazySingleton(() => GetProductCategoriesUsecase(sl())); // ثبت یوزکیس جدید
  sl.registerLazySingleton(() => GetProductOptionsUsecase(sl()));    // ثبت یوزکیس جدید
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Promotion ---
  sl.registerLazySingleton(() => GetPromotionsUsecase(sl()));
  sl.registerLazySingleton<PromotionRepository>(
    () => FakePromotionRepositoryImpl(remoteDataSource: sl()), // توجه: این Fake است
  );
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Cart ---
  sl.registerFactory( // **!! تغییر به registerFactory !!**
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

  // #endregion
}