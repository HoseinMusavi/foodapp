// lib/features/promotion/data/datasources/promotion_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getPromotions();
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final SupabaseClient supabaseClient;

  PromotionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PromotionModel>> getPromotions() async {
    try {
      final response = await supabaseClient.from('promotions').select();
      final promotions = (response as List)
          .map((data) => PromotionModel.fromJson(data))
          .toList();
      return promotions;
    } catch (e) {
      throw ServerException(message: 'Could not fetch promotions.');
    }
  }
}
