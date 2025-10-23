// lib/features/store/data/datasources/store_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
// 1. --- حذف ایمپورت LatLng ---
// import '../../../../core/utils/lat_lng.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  // 2. --- تغییر نام متد و حذف پارامترها ---
  Future<List<StoreModel>> getAllStores(); // قبلی: getStoresNearMe(LatLng location, double? radius);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final SupabaseClient supabaseClient;

  StoreRemoteDataSourceImpl({required this.supabaseClient});

  // 3. --- تغییر نام متد پیاده‌سازی و حذف پارامترها ---
  @override
  Future<List<StoreModel>> getAllStores() async { // قبلی: getStoresNearMe(LatLng location, double? radius)
    try {
      // استفاده از select ساده صحیح است
      final response = await supabaseClient.from('stores').select();

      final stores = (response as List)
          .map((storeData) => StoreModel.fromJson(storeData))
          .toList();

      return stores;
    } catch (e) {
      if (e is PostgrestException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Could not fetch stores: ${e.toString()}');
    }
  }
}