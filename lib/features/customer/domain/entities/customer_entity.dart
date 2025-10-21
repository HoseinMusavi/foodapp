import 'package:equatable/equatable.dart';

import 'address_entity.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final List<AddressEntity> addresses;
  final int? defaultAddressId;

  const CustomerEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.addresses = const [],
    this.defaultAddressId,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    avatarUrl,
    addresses,
    defaultAddressId,
  ];
}
