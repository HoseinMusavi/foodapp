// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // تعریف ثابت‌های رنگی برای دسترسی آسان
  static const Color _primaryColor = Color(0xFFF37A20); // نارنجی گرم و جذاب
  static const Color _secondaryColor = Color(
    0xFF2C3E50,
  ); // سرمه‌ای تیره برای متن
  static const Color _backgroundColor = Color(0xFFF8F9FA); // خاکستری بسیار روشن
  static const Color _surfaceColor = Colors.white;

  // متد برای دریافت تم روشن
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazir',
      brightness: Brightness.light,

      // ۱. طرح رنگی اصلی
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        onPrimary: Colors.white, // رنگ متن روی دکمه‌های اصلی
        onSecondary: Colors.white, // رنگ متن روی پس‌زمینه
        onSurface: _secondaryColor, // رنگ متن روی کارت‌ها
        error: Colors.redAccent,
      ),

      // ۲. استایل‌های متنی
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: _secondaryColor,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: _secondaryColor,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: _secondaryColor,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: _secondaryColor,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: _secondaryColor,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: _secondaryColor,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w500,
          color: _secondaryColor,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          color: _secondaryColor,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w500,
          color: _secondaryColor,
        ),
        bodyLarge: TextStyle(color: _secondaryColor),
        bodyMedium: TextStyle(color: _secondaryColor),
      ).apply(fontFamily: 'Vazir'),

      // ۳. تم ویجت‌های عمومی
      scaffoldBackgroundColor: _backgroundColor,

      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundColor,
        foregroundColor: _secondaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 20,
          color: _secondaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 1.0,
        color: _surfaceColor,
        surfaceTintColor: Colors.transparent, // جلوگیری از تغییر رنگ ناخواسته
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Vazir',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      // تم برای فیلدهای ورودی (در آینده استفاده خواهد شد)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _primaryColor, width: 2.0),
        ),
      ),
    );
  }
}
