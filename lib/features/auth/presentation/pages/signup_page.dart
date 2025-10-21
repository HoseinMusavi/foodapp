// lib/features/auth/presentation/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_app/core/di/service_locator.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState; // ‼️ IMPORT SUPABASE
import 'email_confirmation_page.dart'; // ‼️ IMPORT THE NEW PAGE

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return BlocProvider(
      create: (context) => sl<AuthCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('ساخت حساب کاربری')),
        body: BlocConsumer<AuthCubit, AuthState>(
          // --- ‼️ MAKE THE LISTENER ASYNC ‼️ ---
          listener: (context, state) async {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is AuthSuccess) {
              // --- ✨ THE MAGIC HAPPENS HERE ✨ ---
              // 1. Immediately sign the user out to destroy the temporary session.
              await Supabase.instance.client.auth.signOut();

              // 2. Navigate to the confirmation page.
              if (context.mounted) {
                // Good practice to check context
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const EmailConfirmationPage(),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'نام و نام خانوادگی',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'ایمیل',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'رمز عبور',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        context.read<AuthCubit>().signup(
                          email: emailController.text.trim().toLowerCase(),
                          password: passwordController.text.trim(),
                          fullName: fullNameController.text.trim(),
                        );
                      },
                      child: const Text('ثبت‌نام'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('قبلاً ثبت‌نام کرده‌اید؟ وارد شوید'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
