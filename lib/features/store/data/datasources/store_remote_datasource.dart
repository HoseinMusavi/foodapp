// lib/features/store/data/datasources/store_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  // --- این متد باید اینجا تعریف شده باشد ---
  Future<List<StoreModel>> getFilteredStores({
    String? searchQuery,
    String? category,
  });
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final SupabaseClient supabaseClient;

  StoreRemoteDataSourceImpl({required this.supabaseClient});

  // --- پیاده‌سازی متد جدید با فراخوانی RPC ---
  @override
  Future<List<StoreModel>> getFilteredStores({
    String? searchQuery,
    String? category,
  }) async {
    try {
      // پارامترهایی که به تابع RPC ارسال می‌شوند
      final params = {
        'p_search_query': searchQuery,
        'p_category': category,
      };

      // فراخوانی تابع RPC
      final response = await supabaseClient.rpc(
        'get_filtered_stores',
        params: params,
      );

      if (response is List) {
        final stores = response
            .map((storeData) => StoreModel.fromJson(storeData))
            .toList();
        return stores;
      }

      return [];
    } catch (e) {
      if (e is PostgrestException) {
        throw ServerException(
            message: 'خطا در فیلتر کردن فروشگاه‌ها: ${e.message}');
      }
      throw ServerException(
          message: 'Could not fetch stores: ${e.toString()}');
    }
  }
}