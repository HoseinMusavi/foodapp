// lib/features/store/data/datasources/store_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/lat_lng.dart'; // <-- ایمپورت
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  // نام متد را برای هماهنگی با بک‌اند تغییر می‌دهیم
  Future<List<StoreModel>> getStoresNearMe(LatLng location, double? radius);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final SupabaseClient supabaseClient;

  StoreRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StoreModel>> getStoresNearMe(
      LatLng location, double? radius) async {
    try {
      // --- تغییر اصلی: فراخوانی تابع RPC که در بک‌اند ساختیم ---
      final response = await supabaseClient.rpc(
        'get_stores_near_me',
        params: {
          'p_lat': location.latitude,
          'p_long': location.longitude,
          // اگر شعاع نال بود، بک‌اند از مقدار پیش‌فرض خودش استفاده می‌کند
          if (radius != null) 'p_distance_meters': radius,
        },
      );

      // بقیه کد مثل قبل است
      final stores = (response as List)
          .map((storeData) => StoreModel.fromJson(storeData))
          .toList();

      return stores;
    } catch (e) {
      // مدیریت بهتر خطاها
      if (e is PostgrestException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Could not fetch stores: ${e.toString()}');
    }
  }
}