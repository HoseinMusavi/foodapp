import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart'; //
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:customer_app/features/customer/domain/usecases/add_address_usecase.dart';
import 'package:customer_app/features/customer/domain/usecases/get_addresses_usecase.dart';
import 'package:customer_app/features/customer/domain/usecases/get_customer_details.dart';
import 'package:customer_app/features/customer/domain/usecases/update_customer_profile.dart';
import 'package:equatable/equatable.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomerDetails getCustomerDetailsUsecase;
  final UpdateCustomerProfile updateCustomerProfileUsecase;
  final GetAddressesUsecase getAddressesUsecase;
  final AddAddressUsecase addAddressUsecase;

  CustomerCubit({
    required this.getCustomerDetailsUsecase,
    required this.updateCustomerProfileUsecase,
    required this.getAddressesUsecase,
    required this.addAddressUsecase,
  }) : super(CustomerInitial());

  // تابع کمکی برای مدیریت پیام خطا
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> fetchCustomerDetails() async {
    emit(CustomerLoading());
    final failureOrCustomer = await getCustomerDetailsUsecase(NoParams());
    failureOrCustomer.fold(
      (failure) => emit(CustomerError(message: _mapFailureToMessage(failure))), // اصلاح شد
      (customer) => emit(CustomerLoaded(customer: customer)),
    );
  }

  Future<void> updateCustomer(CustomerEntity customer) async {
    emit(CustomerLoading());
    // پارامتر customer مستقیما پاس داده شد (مطابق با UseCase اصلاح شده)
    final failureOrUpdatedCustomer =
        await updateCustomerProfileUsecase(customer); 
    failureOrUpdatedCustomer.fold(
      (failure) => emit(CustomerError(message: _mapFailureToMessage(failure))), // اصلاح شد
      (customer) => emit(CustomerLoaded(customer: customer)),
    );
  }

  Future<void> getAddresses() async {
    emit(CustomerAddressesLoading());
    final failureOrAddresses = await getAddressesUsecase(NoParams());
    failureOrAddresses.fold(
      (failure) => emit(CustomerAddressesError(message: _mapFailureToMessage(failure))), // اصلاح شد
      (addresses) => emit(CustomerAddressesLoaded(addresses: addresses)),
    );
  }

  Future<void> saveAddress(AddressEntity address) async {
    emit(CustomerAddressSaving());
    final failureOrSuccess = await addAddressUsecase(address);
    failureOrSuccess.fold(
      (failure) => emit(CustomerAddressesError(message: _mapFailureToMessage(failure))), // اصلاح شد
      (_) => emit(CustomerAddressSaved()),
    );
  }
}