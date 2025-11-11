// lib/features/customer/data/datasources/customer_remote_datasource.dart

import 'package:customer_app/core/error/exceptions.dart';
import 'package:customer_app/features/customer/data/models/address_model.dart';
import 'package:customer_app/features/customer/data/models/customer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> getCustomerDetails();
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer);
  Future<List<AddressModel>> getAddresses();
  Future<void> addAddress(AddressModel address);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;

  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CustomerModel> getCustomerDetails() async {
    print('[LOG-DATASOURCE] 1. getCustomerDetails() called.');
    final userId = supabaseClient.auth.currentUser?.id;
    final userEmail = supabaseClient.auth.currentUser?.email;
    print('[LOG-DATASOURCE] 2. UserID: $userId, Email: $userEmail');

    if (userId == null || userEmail == null) {
      print('[LOG-DATASOURCE] 3. ERROR: User not authenticated.');
      throw ServerException(message: 'User not authenticated');
    }

    try {
      print('[LOG-DATASOURCE] 4. Calling supabase.from(customers)... with .maybeSingle()');
      final response = await supabaseClient
          .from('customers')
          .select()
          .eq('id', userId)
          .maybeSingle();

      print('[LOG-DATASOURCE] 5. Supabase response received: $response');

      if (response == null) {
        print('[LOG-DATASOURCE] 6. Response is NULL. Creating empty model for new user.');
        // این یک کاربر جدید است
        return CustomerModel(
          id: userId,
          email: userEmail,
          fullName: '', // خالی می‌فرستیم تا UI تشخیص دهد
          phone: '',   // خالی می‌فرستیم تا UI تشخیص دهد
          avatarUrl: null,
          defaultAddressId: null,
        );
      }
      
      print('[LOG-DATASOURCE] 7. Response is NOT null. Parsing CustomerModel...');
      // اگر کاربر قبلاً وجود داشت
      return CustomerModel.fromJson(response);
    } catch (e) {
      print('[LOG-DATASOURCE] 8. CATCH ERROR: Failed to fetch customer details: $e');
      throw ServerException(message: 'Failed to fetch customer details: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer) async {
    print('[LOG-DATASOURCE] updateCustomerProfile called.');
    try {
      final response = await supabaseClient
          .from('customers')
          .update(customer.toJson())
          .eq('id', customer.id)
          .select()
          .single();
      print('[LOG-DATASOURCE] Update successful: $response');
      return CustomerModel.fromJson(response);
    } catch (e) {
      print('[LOG-DATASOURCE] CATCH ERROR: Failed to update profile: $e');
      throw ServerException(message: 'Failed to update customer profile: $e');
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    // ... (این متد فعلا لاگ نیاز ندارد)
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException(message: 'User not authenticated');
    }
    try {
      final response = await supabaseClient
          .from('addresses')
          .select('*, location:location::text')
          .eq('customer_id', userId);

      final addresses = (response as List)
          .map((data) => AddressModel.fromJson(data))
          .toList();
      return addresses;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch addresses: $e');
    }
  }

  @override
  Future<void> addAddress(AddressModel address) async {
    // ... (این متد فعلا لاگ نیاز ندارد)
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException(message: 'User not authenticated');
    }

    try {
      await supabaseClient
          .from('addresses')
          .insert(address.toInsertJson());
    } catch (e) {
      throw ServerException(message: 'Failed to add address: $e');
    }
  }
}