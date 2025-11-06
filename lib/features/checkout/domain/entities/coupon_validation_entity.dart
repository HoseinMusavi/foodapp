// lib/features/checkout/domain/entities/coupon_validation_entity.dart

import 'package:equatable/equatable.dart';

class CouponValidationEntity extends Equatable {
  final double discountAmount;
  final String? errorMessage;

  const CouponValidationEntity({
    required this.discountAmount,
    this.errorMessage,
  });

  // یک factory constructor برای ساختن نمونه از JSON (پاسخ RPC)
  factory CouponValidationEntity.fromJson(Map<String, dynamic> json) {
    return CouponValidationEntity(
      // پاسخ RPC سوپابیس ممکن است double نباشد، তাই تبدیل می‌کنیم
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['error_message'] as String?,
    );
  }

  // اگر خطایی وجود داشته باشد، یعنی کد نامعتبر است
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [discountAmount, errorMessage];
}