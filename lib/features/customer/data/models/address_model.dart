import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required int id,
    required String title,
    required String fullAddress,
    required String postalCode,
    required String city,
  }) : super(
         id: id,
         title: title,
         fullAddress: fullAddress,
         postalCode: postalCode,
         city: city,
       );

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      title: json['title'] as String,
      fullAddress: json['full_address'] as String,
      postalCode: json['postal_code'] as String,
      city: json['city'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'full_address': fullAddress,
      'postal_code': postalCode,
      'city': city,
    };
  }
}
