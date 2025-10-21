// lib/features/auth/presentation/pages/email_confirmation_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart'; // Import login page to navigate back

class EmailConfirmationPage extends StatelessWidget {
  const EmailConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                'ثبت‌نام شما تقریباً کامل شد!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'یک ایمیل فعال‌سازی به آدرس شما ارسال شد. لطفاً صندوق ورودی ایمیل خود را بررسی کرده و روی لینک فعال‌سازی کلیک کنید.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate the user to the login page
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('بازگشت به صفحه ورود'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
