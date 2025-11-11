// lib/features/order/data/datasources/order_remote_datasource.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/features/checkout/data/models/order_model.dart';
import 'package:customer_app/features/order/domain/usecases/submit_store_review_usecase.dart';
// --- اصلاح شد: ایمپورت 'package://' نادرست بود ---
import 'package:supabase_flutter/supabase_flutter.dart';
// ---

abstract class OrderRemoteDatasource {
  Stream<OrderModel> getOrderUpdates(int orderId);
  Future<List<OrderModel>> getMyOrders();
  Future<OrderModel> getOrderDetails(int orderId);

  Future<void> submitStoreReview(SubmitStoreReviewParams params);
  Future<Set<int>> getReviewedOrderIds();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDatasource {
  final SupabaseClient supabaseClient;

  OrderRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> submitStoreReview(SubmitStoreReviewParams params) async {
    try {
      final customerId = supabaseClient.auth.currentUser?.id;
      if (customerId == null) {
        throw const ServerException(message: 'کاربر احراز هویت نشده است.');
      }

      await supabaseClient.from('store_reviews').insert({
        'store_id': params.storeId,
        'customer_id': customerId,
        'order_id': params.orderId,
        'rating': params.rating,
        'comment': params.comment,
      });
    } on PostgrestException catch (e) { // حالا PostgrestException شناسایی می‌شود
      // TODO: Check for unique constraint violation if we add it
      throw ServerException(message: 'خطا در ثبت نظر: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'خطای ناشناخته: ${e.toString()}');
    }
  }

  @override
  Future<Set<int>> getReviewedOrderIds() async {
    try {
      final customerId = supabaseClient.auth.currentUser?.id;
      if (customerId == null) return <int>{}; // برگرداندن لیست خالی

      final response = await supabaseClient
          .from('store_reviews')
          .select('order_id')
          .eq('customer_id', customerId);
      
      if (response is List) {
        return response
            .map((item) => (item['order_id'] as num).toInt())
            .toSet();
      }
      return <int>{};
    } catch (e) {
      print('Error fetching reviewed order IDs: $e');
      return <int>{}; // در صورت خطا، لیست خالی برگردان
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select(
            '*, store_id(*)', 
          )
          .order('created_at', ascending: false);

      if (response is List) {
        final orders =
            response.map((data) => OrderModel.fromJson(data)).toList();
        return orders;
      }
      return [];
    } catch (e) {
      throw ServerException(message: 'Could not fetch orders: ${e.toString()}');
    }
  }

  @override
  Stream<OrderModel> getOrderUpdates(int orderId) {
    try {
      final stream = supabaseClient
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('id', orderId)
          .map((maps) => OrderModel.fromJson(maps.first));
      return stream;
    } catch (e) {
      throw ServerException(message: 'Could not stream order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select(
            '*, store_id(*), address_id(*), order_items(*, product_id(*), order_item_options(*))',
          )
          .eq('id', orderId)
          .single();
      return OrderModel.fromJson(response);
    } catch (e) {
      throw ServerException(
          message: 'Could not get order details: ${e.toString()}');
    }
  }
}