import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> getCustomerDetails();
  Future<List<AddressModel>> getAddresses();
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer);
  Future<String> uploadAvatar(File imageFile);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;
  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CustomerModel> getCustomerDetails() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      debugPrint("✅ [DataSource] -> getCustomerDetails: Sending request to Supabase...");
      final response = await supabaseClient
          .from('customers')
          .select()
          .eq('id', user.id)
          .single()
          .timeout(const Duration(seconds: 15));

      debugPrint("✅ [DataSource] -> getCustomerDetails: Response received successfully.");
      return CustomerModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        debugPrint(" passo [DataSource] -> getCustomerDetails: Profile not found for new user.");
        throw const ServerException(message: 'Profile not found');
      }
      debugPrint("❌ [DataSource] -> getCustomerDetails: Postgrest Error: ${e.message}");
      throw ServerException(message: e.message);
    } catch (e) {
      debugPrint("❌ [DataSource] -> getCustomerDetails: Unexpected error or timeout: ${e.toString()}");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    debugPrint(" passo [DataSource] -> getAddresses: Called but not yet implemented.");
    return [];
  }

  @override
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer) async {
    try {
      debugPrint("✅ [DataSource] -> updateCustomerProfile: Sending upsert command to customers table...");
      final response = await supabaseClient
          .from('customers')
          .upsert(customer.toJson())
          .select()
          .single()
          .timeout(const Duration(seconds: 15));
      debugPrint("✅ [DataSource] -> updateCustomerProfile: Successful response from Supabase.");
      return CustomerModel.fromJson(response);
    } catch (e) {
      debugPrint("❌ [DataSource] -> updateCustomerProfile: Error during data upsert: ${e.toString()}");
      throw ServerException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const ServerException(message: 'User not authenticated');

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      debugPrint("✅ [DataSource] -> uploadAvatar: Uploading file to path: $filePath");
      await supabaseClient.storage.from('avatars').upload(filePath, imageFile);

      final imageUrl = supabaseClient.storage.from('avatars').getPublicUrl(filePath);
      debugPrint("✅ [DataSource] -> uploadAvatar: Public URL for the image received.");
      return imageUrl;
    } catch (e) {
      debugPrint("❌ [DataSource] -> uploadAvatar: Error during upload: ${e.toString()}");
      throw ServerException(message: 'Failed to upload avatar: ${e.toString()}');
    }
  }
}