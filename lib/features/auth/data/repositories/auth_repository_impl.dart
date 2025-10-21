// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<User?> get currentUser => remoteDataSource.currentUser;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    print("--- REPOSITORY: Login method called ---");
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      print("--- REPOSITORY: Login successful in datasource ---");
      return Right(user);
    } on ServerException catch (e) {
      print(
        "--- REPOSITORY: Caught ServerException with message: ${e.message} ---",
      );
      return Left(ServerFailure(message: e.message));
    }
  }

  // ... (logout and signup methods are unchanged)
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await remoteDataSource.signup(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
