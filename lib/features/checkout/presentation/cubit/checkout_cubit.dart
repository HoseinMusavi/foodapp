import 'package:bloc/bloc.dart';
import 'package:customer_app/core/error/failure.dart'; // <-- ایمپورت Failure
// import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart'; // اگر از UseCase استفاده کنیم، این لازم نیست
import 'package:customer_app/features/checkout/domain/usecases/place_order_usecase.dart'; // <-- ایمپورت UseCase
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:equatable/equatable.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  // final CheckoutRepository checkoutRepository; // <-- حذف شد
  final PlaceOrderUsecase placeOrderUsecase; // <-- جایگزین با UseCase

  CheckoutCubit({required this.placeOrderUsecase}) : super(CheckoutInitial()); // <-- تغییر constructor

  // تابع کمکی برای مدیریت پیام خطا (مانند CustomerCubit)
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    // میتوانید انواع دیگر Failure را هم اینجا مدیریت کنید
    return 'یک خطای ناشناخته رخ داد';
  }


  Future<void> submitOrder({
    required AddressEntity address,
    String? couponCode,
    String? notes,
  }) async {
    emit(CheckoutProcessing());
    // استفاده از UseCase با پارامترهایش
    final failureOrOrderId = await placeOrderUsecase(
      PlaceOrderParams(
        address: address,
        couponCode: couponCode,
        notes: notes,
      ),
    );

    failureOrOrderId.fold(
      (failure) => emit(CheckoutFailure(message: _mapFailureToMessage(failure))), // <-- اصلاح شد
      (orderId) => emit(CheckoutSuccess(orderId: orderId)),
    );
  }
}