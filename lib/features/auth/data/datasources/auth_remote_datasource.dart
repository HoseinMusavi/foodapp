// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<User> signup({
    required String email,
    required String password,
    required String fullName,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  Stream<User?> get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  // ... (currentUser and signup methods are unchanged)
  @override
  Stream<User?> get currentUser {
    return supabaseClient.auth.onAuthStateChange.map((authState) {
      return authState.session?.user;
    });
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (response.user == null) {
        throw const ServerException(
          message: 'Signup failed, please try again.',
        );
      }
      return response.user!;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    print("--- DATASOURCE: Login method called ---");
    try {
      print("--- DATASOURCE: Calling Supabase signInWithPassword... ---");
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print("--- DATASOURCE: Supabase call finished. Checking for user... ---");
      if (response.user == null) {
        print("--- DATASOURCE: User is null, throwing exception. ---");
        throw const ServerException(message: 'User not found after login.');
      }
      print("--- DATASOURCE: User found: ${response.user!.email} ---");
      return response.user!;
    } on AuthException catch (e) {
      print("--- DATASOURCE: Caught AuthException: ${e.message} ---");
      throw ServerException(message: e.message);
    } catch (e) {
      print("--- DATASOURCE: Caught generic exception: ${e.toString()} ---");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}
