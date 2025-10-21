import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    String? avatarUrl,
    int? defaultAddressId,
  }) : super(
         id: id,
         fullName: fullName,
         email: email,
         phone: phone,
         avatarUrl: avatarUrl,
         defaultAddressId: defaultAddressId,
         addresses: const [],
       );

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatar_url'] as String?,
      defaultAddressId: json['default_address_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'default_address_id': defaultAddressId,
    };
  }
}
