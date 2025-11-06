// lib/features/store/data/datasources/store_remote_datasource.dart

import 'package:customer_app/features/store/domain/entities/store_review_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreModel>> getFilteredStores({
    String? searchQuery,
    String? category,
  });

  // --- متد جدید (بخش ۳) ---
  /// Calls the RPC 'get_store_reviews_with_customer'
  Future<List<StoreReviewEntity>> getStoreReviews(int storeId);
  // ---
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final SupabaseClient supabaseClient;

  StoreRemoteDataSourceImpl({required this.supabaseClient});

  // --- متد جدید (بخش ۳) ---
  @override
  Future<List<StoreReviewEntity>> getStoreReviews(int storeId) async {
    try {
      final response = await supabaseClient.rpc(
        'get_store_reviews_with_customer',
        params: {'p_store_id': storeId},
      );

      if (response is List) {
        final reviews = response
            .map((data) => StoreReviewEntity.fromJson(data as Map<String, dynamic>))
            .toList();
        return reviews;
      }
      return [];
    } catch (e) {
      if (e is PostgrestException) {
        throw ServerException(message: 'خطا در واکشی نظرات: ${e.message}');
      }
      throw ServerException(message: 'Could not fetch reviews: ${e.toString()}');
    }
  }
  // ---

  @override
  Future<List<StoreModel>> getFilteredStores({
    String? searchQuery,
    String? category,
  }) async {
    try {
      final params = {
        'p_search_query': searchQuery,
        'p_category': category,
      };

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