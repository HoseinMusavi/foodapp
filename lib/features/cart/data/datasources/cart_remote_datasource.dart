// lib/features/cart/data/datasources/cart_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../product/data/models/product_model.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addProductToCart(int productId);
  Future<void> updateProductQuantity(int productId, int newQuantity);
  Future<void> removeProductFromCart(int productId);
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

    // Check if a cart already exists
    final cartResponse = await supabaseClient
        .from('carts')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (cartResponse != null && cartResponse['id'] != null) {
      return cartResponse['id'];
    }

    // If not, create a new cart
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
            '*, products(*, stores(*))',
          ) // Fetch item, product and store data
          .eq('cart_id', cartId);

      final items = (response as List).map((data) {
        final productData = data['products'];
        final storeData = productData['stores'];

        // Manually build the ProductModel with the nested storeName
        final product = ProductModel.fromJson(
          productData,
        ).copyWith(storeName: storeData['name']);

        return CartItemModel.fromSupabase(data, product);
      }).toList();

      return items;
    } catch (e) {
      throw ServerException(
        message: 'Could not fetch cart items. ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addProductToCart(int productId) async {
    try {
      final cartId = await _getOrCreateCartId();

      // "Upsert" logic: Insert a new item, or if it already exists, increment the quantity
      await supabaseClient.rpc(
        'add_to_cart',
        params: {
          'p_cart_id': cartId,
          'p_product_id': productId,
          'p_quantity': 1,
        },
      );
    } catch (e) {
      throw ServerException(message: 'Could not add product to cart.');
    }
  }

  @override
  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    if (newQuantity < 1) {
      await removeProductFromCart(productId);
      return;
    }
    try {
      final cartId = await _getOrCreateCartId();
      await supabaseClient
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('cart_id', cartId)
          .eq('product_id', productId);
    } catch (e) {
      throw ServerException(message: 'Could not update product quantity.');
    }
  }

  @override
  Future<void> removeProductFromCart(int productId) async {
    try {
      final cartId = await _getOrCreateCartId();
      await supabaseClient
          .from('cart_items')
          .delete()
          .eq('cart_id', cartId)
          .eq('product_id', productId);
    } catch (e) {
      throw ServerException(message: 'Could not remove product from cart.');
    }
  }
}
