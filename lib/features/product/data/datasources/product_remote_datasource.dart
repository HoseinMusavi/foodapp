// lib/features/product/data/datasources/product_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/option_group_model.dart'; // <-- ایمپورت جدید
import '../models/product_category_model.dart'; // <-- ایمپورت جدید
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsByStoreId(int storeId);

  // --- متدهای جدید ---
  Future<List<ProductCategoryModel>> getProductCategories(int storeId);
  Future<List<OptionGroupModel>> getProductOptions(int productId);
  // --------------------
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductModel>> getProductsByStoreId(int storeId) async {
    try {
      // --- کوئری را به‌روز می‌کنیم تا نام دسته‌بندی را JOIN کند ---
      final response = await supabaseClient
          .from('products')
          .select('*, product_categories(name)') // <-- JOIN
          .eq('store_id', storeId);

      final products = (response as List)
          .map((data) => ProductModel.fromJson(data))
          .toList();
      return products;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Could not fetch products.');
    }
  }

  // --- پیاده‌سازی متدهای جدید ---

  @override
  Future<List<ProductCategoryModel>> getProductCategories(int storeId) async {
    try {
      final response = await supabaseClient
          .from('product_categories')
          .select()
          .eq('store_id', storeId)
          .order('sort_order'); // مرتب‌سازی

      final categories = (response as List)
          .map((data) => ProductCategoryModel.fromJson(data))
          .toList();
      return categories;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Could not fetch product categories.');
    }
  }

  @override
  Future<List<OptionGroupModel>> getProductOptions(int productId) async {
    try {
      // این کوئری پیچیده، گروه‌های آپشن و خود آپشن‌ها را
      // فقط برای محصولاتی که به این productId وصل هستند، واکشی می‌کند
      final response = await supabaseClient
          .from('product_option_groups')
          .select('option_groups(*, options(*))') // <-- JOIN تودرتو
          .eq('product_id', productId);

      final groups = (response as List).map((data) {
        // چون ما option_groups را درون product_option_groups واکشی کردیم
        // باید آن را از داخل Map استخراج کنیم
        return OptionGroupModel.fromJson(data['option_groups']);
      }).toList();

      return groups;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Could not fetch product options.');
    }
  }
}