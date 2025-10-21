part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final CustomerEntity customer;
  const CustomerLoaded(this.customer);
  @override
  List<Object> get props => [customer];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
  @override
  List<Object> get props => [message];
}

// A state to show a loading indicator on the button while saving
class CustomerUpdating extends CustomerState {}