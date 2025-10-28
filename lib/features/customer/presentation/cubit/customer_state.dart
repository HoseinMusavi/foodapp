part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final CustomerEntity customer;

  const CustomerLoaded({required this.customer});

  @override
  List<Object?> get props => [customer];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError({required this.message});

  @override
  List<Object?> get props => [message];
}

// State های زیر را اضافه کنید

class CustomerAddressesLoading extends CustomerState {}

class CustomerAddressesLoaded extends CustomerState {
  final List<AddressEntity> addresses;

  const CustomerAddressesLoaded({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}

class CustomerAddressSaving extends CustomerState {}

class CustomerAddressSaved extends CustomerState {}

class CustomerAddressesError extends CustomerState {
  final String message;

  const CustomerAddressesError({required this.message});

  @override
  List<Object?> get props => [message];
}