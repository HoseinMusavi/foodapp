// lib/features/store/data/datasources/store_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreModel>> getAllStores();
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final SupabaseClient supabaseClient;

  StoreRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StoreModel>> getAllStores() async {
    try {
      // Select all rows from the 'stores' table
      final response = await supabaseClient.from('stores').select();

      // Convert the list of maps to a list of StoreModel
      final stores = (response as List)
          .map((storeData) => StoreModel.fromJson(storeData))
          .toList();

      return stores;
    } catch (e) {
      // If something goes wrong, throw a ServerException
      throw ServerException(message: 'Could not fetch stores.');
    }
  }
}
