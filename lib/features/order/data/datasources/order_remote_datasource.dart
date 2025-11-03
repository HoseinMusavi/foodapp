// lib/features/order/data/datasources/order_remote_datasource.dart

import 'dart:async';

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/features/checkout/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderRemoteDatasource {
  Stream<OrderModel> getOrderUpdates(int orderId);
  Future<OrderModel> getOrderDetails(int orderId);
  Future<List<OrderModel>> getMyOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDatasource {
  final SupabaseClient supabaseClient;

  OrderRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Stream<OrderModel> getOrderUpdates(int orderId) {
    try {
      // این متد فقط برای آپدیت STATUS است و join ندارد
      final stream = supabaseClient
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('id', orderId)
          .limit(1);

      return stream.map((dataList) {
        if (dataList.isEmpty) {
          throw ServerException(message: 'Order not found');
        }
        return OrderModel.fromJson(dataList.first);
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      // ****** 1. اینجا اصلاح شد: Join به stores اضافه شد ******
      final data = await supabaseClient
          .from('orders')
          .select('*, store:store_id(*), order_items(*, order_item_options(*))')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;

      // ****** 2. اینجا هم اصلاح شد: Join به stores اضافه شد ******
      final data = await supabaseClient
          .from('orders')
          .select('*, store:store_id(*), order_items(*, order_item_options(*))')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}