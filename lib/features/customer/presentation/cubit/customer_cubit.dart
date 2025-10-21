import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/get_customer_details.dart';
import '../../domain/usecases/update_customer_profile.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomerDetails getCustomerDetailsUseCase;
  final UpdateCustomerProfile updateCustomerProfileUseCase;

  CustomerCubit({
    required this.getCustomerDetailsUseCase,
    required this.updateCustomerProfileUseCase,
  }) : super(CustomerInitial());

  Future<void> fetchCustomerDetails() async {
    debugPrint("✅ [Cubit] -> fetchCustomerDetails: Starting to get profile information.");
    emit(CustomerLoading());
    final failureOrCustomer = await getCustomerDetailsUseCase(NoParams());

    failureOrCustomer.fold(
      (failure) {
        debugPrint("❌ [Cubit] -> fetchCustomerDetails: Information retrieval failed. Error: ${failure.toString()}");
        emit(CustomerError(failure.toString()));
      },
      (customer) {
        debugPrint("✅ [Cubit] -> fetchCustomerDetails: Information received successfully. Displaying profile.");
        emit(CustomerLoaded(customer));
      },
    );
  }

  Future<void> saveProfile({
    required String fullName,
    required String phone,
    File? imageFile,
  }) async {
    debugPrint("✅ [Cubit] -> saveProfile: Starting profile save operation.");
    emit(CustomerUpdating());

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      emit(const CustomerError('User not authenticated'));
      return;
    }

    String? currentAvatarUrl;
    int? currentDefaultAddressId;
    final currentState = state;
    if (currentState is CustomerLoaded) {
      currentAvatarUrl = currentState.customer.avatarUrl;
      currentDefaultAddressId = currentState.customer.defaultAddressId;
    }

    final customerData = CustomerEntity(
      id: user.id,
      fullName: fullName,
      email: user.email ?? '',
      phone: phone,
      avatarUrl: currentAvatarUrl,
      defaultAddressId: currentDefaultAddressId,
    );

    final params = UpdateCustomerParams(
      customer: customerData,
      imageFile: imageFile,
    );
    final failureOrSuccess = await updateCustomerProfileUseCase(params);

    failureOrSuccess.fold(
      (failure) {
        debugPrint("❌ [Cubit] -> saveProfile: Save failed. Error: ${failure.toString()}");
        emit(CustomerError(failure.toString()));
      },
      (updatedCustomer) {
        debugPrint("✅ [Cubit] -> saveProfile: Save successful. Displaying new profile.");
        emit(CustomerLoaded(updatedCustomer));
      },
    );
  }
}