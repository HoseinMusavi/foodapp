import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart'; 
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:customer_app/features/customer/domain/usecases/add_address_usecase.dart';
import 'package:customer_app/features/customer/domain/usecases/get_addresses_usecase.dart';
import 'package:customer_app/features/customer/domain/usecases/get_customer_details.dart';
import 'package:customer_app/features/customer/domain/usecases/update_customer_profile.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev; // ۱. ایمپورت کتابخانه لاگ

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
    dev.log('[LOG-CUBIT] 1. fetchCustomerDetails() called.', name: 'CustomerCubit');
    emit(CustomerLoading());
    final failureOrCustomer = await getCustomerDetailsUsecase(NoParams());
    
    failureOrCustomer.fold(
      (failure) {
        // --- ۲. اصلاحیه ارور ---
        // ارورهای شما به این دلیل بود که failure.message وجود نداشت
        // ما باید از تابع کمکی _mapFailureToMessage استفاده کنیم
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('[LOG-CUBIT] 2. fetchCustomerDetails FAILURE: $errorMessage', name: 'CustomerCubit', error: failure);
        emit(CustomerError(message: errorMessage));
      },
      (customer) {
        dev.log('[LOG-CUBIT] 2. fetchCustomerDetails SUCCESS. Customer name: "${customer.fullName}"', name: 'CustomerCubit');
        emit(CustomerLoaded(customer: customer));
      },
    );
  }

  Future<void> updateCustomer(CustomerEntity customer) async {
    dev.log('[LOG-CUBIT] updateCustomer() called for "${customer.fullName}".', name: 'CustomerCubit');
    emit(CustomerLoading());
    // پارامتر customer مستقیما پاس داده شد (مطابق با UseCase اصلاح شده)
    final failureOrUpdatedCustomer =
        await updateCustomerProfileUsecase(customer); 
    
    failureOrUpdatedCustomer.fold(
      (failure) {
        // --- ۳. اصلاحیه ارور ---
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('[LOG-CUBIT] Update FAILURE: $errorMessage', name: 'CustomerCubit', error: failure);
        emit(CustomerError(message: errorMessage));
      },
      (customer) {
        dev.log('[LOG-CUBIT] Update SUCCESS.', name: 'CustomerCubit');
        emit(CustomerLoaded(customer: customer));
      },
    );
  }

  Future<void> getAddresses() async {
    dev.log('[LOG-CUBIT] getAddresses() called.', name: 'CustomerCubit');
    emit(CustomerAddressesLoading());
    final failureOrAddresses = await getAddressesUsecase(NoParams());
    
    failureOrAddresses.fold(
      (failure) {
        // --- ۴. اصلاحیه ارور ---
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('[LOG-CUBIT] GetAddresses FAILURE: $errorMessage', name: 'CustomerCubit', error: failure);
        emit(CustomerAddressesError(message: errorMessage));
      },
      (addresses) {
        dev.log('[LOG-CUBIT] GetAddresses SUCCESS. Found ${addresses.length} addresses.', name: 'CustomerCubit');
        emit(CustomerAddressesLoaded(addresses: addresses));
      },
    );
  }

  Future<void> saveAddress(AddressEntity address) async {
    dev.log('[LOG-CUBIT] saveAddress() called.', name: 'CustomerCubit');
    emit(CustomerAddressSaving());
    final failureOrSuccess = await addAddressUsecase(address);
    
    failureOrSuccess.fold(
      (failure) {
        // --- ۵. اصلاحیه ارور ---
        final errorMessage = _mapFailureToMessage(failure);
        dev.log('[LOG-CUBIT] SaveAddress FAILURE: $errorMessage', name: 'CustomerCubit', error: failure);
        emit(CustomerAddressesError(message: errorMessage));
      },
      (_) {
        dev.log('[LOG-CUBIT] SaveAddress SUCCESS. Emitting CustomerAddressSaved().', name: 'CustomerCubit');
        emit(CustomerAddressSaved());
      },
    );
  }
}