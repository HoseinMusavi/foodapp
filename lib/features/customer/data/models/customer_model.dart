// lib/features/customer/data/models/customer_model.dart

import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';

 // (مسیر ایمپورت شما ممکن است متفاوت باشد)
// import '../../domain/entities/customer_entity.dart'; // (اگر این است، جایگزین کنید)


class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phone,
    super.avatarUrl,
    super.defaultAddressId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '', // (اطمینان از نال نبودن ایمیل)
      
      // --- شروع اصلاحیه ---
      // این فیلدها می‌توانند از دیتابیس null بیایند
      fullName: json['full_name'] as String? ?? '', // اگر null بود، رشته خالی بگذار
      phone: json['phone'] as String? ?? '',     // اگر null بود، رشته خالی بگذار
      avatarUrl: json['avatar_url'] as String?,  // این از قبل null-safe بود
      // --- پایان اصلاحیه ---
      
      defaultAddressId: json['default_address_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'default_address_id': defaultAddressId,
    };
  }
}

// 1. اطمینان حاصل کنید که ایمپورت 'package_rename/customer_entity.dart' 
//    به مسیر صحیح domain/entities/customer_entity.dart اشاره دارد.
// 2. اگر CustomerEntity شما fullName و phone را non-nullable (String) تعریف کرده،
//    این کد صحیح است. اگر آن‌ها را (String?) تعریف کرده‌اید،
//    کد به این شکل تغییر می‌کند:
//    fullName: json['full_name'] as String?,
//    phone: json['phone'] as String?,