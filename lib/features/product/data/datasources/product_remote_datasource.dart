// lib/features/product/data/datasources/product_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsByStoreId(int storeId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductModel>> getProductsByStoreId(int storeId) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select()
          .eq('store_id', storeId); // Filter by store_id

      final products = (response as List)
          .map((data) => ProductModel.fromJson(data))
          .toList();
      return products;
    } catch (e) {
      throw ServerException(message: 'Could not fetch products.');
    }
  }
}
