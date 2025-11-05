// lib/features/auth/presentation/cubit/auth_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
// ۱. --- ایمپورت‌های مورد نیاز ---
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;
  // ۲. --- اضافه کردن logoutUseCase ---
  final LogoutUseCase logoutUseCase;
  
  // (کلاینت مستقیم Supabase دیگر اینجا لازم نیست)
  // final SupabaseClient _supabaseClient = Supabase.instance.client;

  AuthCubit({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.logoutUseCase, // ۳. --- اضافه شدن به constructor ---
  }) : super(AuthInitial());

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // ... (این متد بدون تغییر است)
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
    // ... (این متد بدون تغییر است)
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

  // --- ۴. بازنویسی کامل متد signOut ---
  Future<void> signOut() async {
    // برای خروج نیازی به حالت Loading نیست
    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) {
        // اگر خروج از حساب به هر دلیلی با خطا مواجه شد
        final message = (failure is ServerFailure) ? failure.message : 'Failed to sign out';
        emit(AuthFailure(message: message));
      },
      (success) {
        // اگر خروج موفق بود
        // AuthGate به صورت خودکار به صفحه Login هدایت می‌کند
        emit(AuthInitial()); // بازگشت به حالت اولیه
      },
    );
  }
}