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
  // اینجا اصلاح شد
  final SupabaseClient supabaseClient;

  CustomerRemoteDataSourceImpl({required this.supabaseClient});
  // پایان اصلاح

  @override
  Future<CustomerModel> getCustomerDetails() async {
    // اینجا اصلاح شد
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException(message: 'User not authenticated');
    }
    try {
      final response = await supabaseClient // اینجا اصلاح شد
          .from('customers')
          .select()
          .eq('id', userId)
          .single();
      return CustomerModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch customer details: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer) async {
    try {
      final response = await supabaseClient // اینجا اصلاح شد
          .from('customers')
          .update(customer.toJson())
          .eq('id', customer.id)
          .select()
          .single();
      return CustomerModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update customer profile: $e');
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    // اینجا اصلاح شد
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException(message: 'User not authenticated');
    }
    try {
      final response = await supabaseClient // اینجا اصلاح شد
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
    // اینجا اصلاح شد
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw ServerException(message: 'User not authenticated');
    }

    try {
      await supabaseClient // اینجا اصلاح شد
          .from('addresses')
          .insert(address.toInsertJson());
    } catch (e) {
      throw ServerException(message: 'Failed to add address: $e');
    }
  }
}