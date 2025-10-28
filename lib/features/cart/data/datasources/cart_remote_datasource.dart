// lib/features/cart/data/datasources/cart_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../product/domain/entities/option_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/data/models/option_model.dart';
import '../../../product/data/models/product_model.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addProductToCart(
      ProductEntity product, List<OptionEntity> selectedOptions);
  Future<void> updateProductQuantity(int cartItemId, int newQuantity);
  Future<void> removeProductFromCart(int cartItemId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final SupabaseClient supabaseClient;

  CartRemoteDataSourceImpl({required this.supabaseClient});

  // Helper function to get or create a cart for the current user
  Future<String> _getOrCreateCartId() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated.');
    }

    final cartResponse = await supabaseClient
        .from('carts')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (cartResponse != null && cartResponse['id'] != null) {
      return cartResponse['id'];
    }

    final newCartResponse = await supabaseClient
        .from('carts')
        .insert({'user_id': user.id})
        .select('id')
        .single();
    return newCartResponse['id'];
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final cartId = await _getOrCreateCartId();
      final response = await supabaseClient
          .from('cart_items')
          .select(
            '''
            *, 
            products(
              *, 
              stores(name) 
            ), 
            cart_item_options(
              options(
                *,
                option_groups(name)
              )
            )
            ''',
          )
          .eq('cart_id', cartId);

      final items = (response as List).map((data) {
        
        // ✨ --- شروع فیکس اصلی ---
        // ۱. داده‌های محصول را استخراج کن
        final productData = data['products'] as Map<String, dynamic>? ?? {};
        
        // ۲. داده‌های فروشگاه تو در تو را استخراج کن
        final storeData = productData['stores'] as Map<String, dynamic>?;
        
        // ۳. یک کپی از داده‌های محصول بساز تا قابل ویرایش باشد
        final productJson = Map<String, dynamic>.from(productData);
        
        // ۴. نام فروشگاه را از داده‌های تو در تو به سطح بالای JSON محصول اضافه کن
        if (storeData != null) {
          productJson['storeName'] = storeData['name'];
        }
        
        // ۵. حالا ProductModel.fromJson می‌تواند 'storeName' را پیدا کند
        final product = ProductModel.fromJson(productJson);
        // ✨ --- پایان فیکس اصلی ---


        // خواندن آپشن‌های انتخاب شده
        final List<OptionModel> selectedOptions = [];
        if (data['cart_item_options'] != null) {
          selectedOptions.addAll(
            (data['cart_item_options'] as List).map((cio) {
              final optionData = cio['options'];
              if (optionData == null) return null; // Skip if option is null
              
              // Map group name from relation
              final optionGroupData = optionData['option_groups'];
              final String groupName = optionGroupData != null ? optionGroupData['name'] : 'Unknown Group';

              return OptionModel.fromJson(optionData).copyWith(groupName: groupName);
            }).whereType<OptionModel>(), // Filter out any nulls
          );
        }

        // پاس دادن آپشن‌ها به CartItemModel
        return CartItemModel.fromSupabase(data, product, selectedOptions);
      }).toList();

      return items;
    } catch (e) {
      throw ServerException(
        message: 'Could not fetch cart items. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addProductToCart(
    ProductEntity product,
    List<OptionEntity> selectedOptions,
  ) async {
    try {
      final cartId = await _getOrCreateCartId();

      // ۱. آیتم اصلی را در 'cart_items' درج کن و ID آن را بگیر
      final newCartItem = await supabaseClient
          .from('cart_items')
          .insert({
            'cart_id': cartId,
            'product_id': product.id,
            'quantity': 1, // فعلاً همیشه ۱
          })
          .select('id')
          .single();

      final newCartItemId = newCartItem['id'];
      if (newCartItemId == null) {
        throw const ServerException(message: 'Failed to create cart item.');
      }

      // ۲. اگر آپشنی وجود داشت، آن‌ها را در 'cart_item_options' درج کن
      if (selectedOptions.isNotEmpty) {
        final optionsToInsert = selectedOptions.map((opt) {
          return {
            'cart_item_id': newCartItemId,
            'option_id': opt.id,
          };
        }).toList();

        await supabaseClient
            .from('cart_item_options')
            .insert(optionsToInsert);
      }
      
    } catch (e) {
      throw ServerException(
          message: 'Could not add product to cart. ${e.toString()}');
    }
  }

  @override
  Future<void> updateProductQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity < 1) {
      await removeProductFromCart(cartItemId);
      return;
    }
    try {
      await supabaseClient
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId);
    } catch (e) {
      throw ServerException(message: 'Could not update product quantity.');
    }
  }

  @override
  Future<void> removeProductFromCart(int cartItemId) async {
    try {
      await supabaseClient
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
    } catch (e) {
      throw ServerException(message: 'Could not remove product from cart.');
    }
  }
}