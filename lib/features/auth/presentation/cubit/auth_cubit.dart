// lib/features/auth/presentation/cubit/auth_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;

  AuthCubit({required this.signupUseCase, required this.loginUseCase})
    : super(AuthInitial());

  // ... (signup method is unchanged)
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(AuthLoading());
    final result = await signupUseCase(
      SignupParams(email: email, password: password, fullName: fullName),
    );
    result.fold((failure) {
      if (failure is ServerFailure) {
        emit(AuthFailure(message: failure.message));
      } else {
        emit(const AuthFailure(message: 'An unknown error occurred.'));
      }
    }, (user) => emit(AuthSuccess(user: user)));
  }

  Future<void> login({required String email, required String password}) async {
    print("--- CUBIT: Login method called ---");
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    print("--- CUBIT: Usecase finished, processing result ---");
    result.fold(
      (failure) {
        print("--- CUBIT: Result is a Failure ---");
        if (failure is ServerFailure) {
          print("--- CUBIT: Failure message: ${failure.message} ---");
          emit(AuthFailure(message: failure.message));
        } else {
          emit(const AuthFailure(message: 'An unknown error occurred.'));
        }
      },
      (user) {
        print("--- CUBIT: Result is a Success. User: ${user.email} ---");
        emit(AuthSuccess(user: user));
      },
    );
  }
}
