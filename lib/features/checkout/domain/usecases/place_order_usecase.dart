import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
// import 'package:customer_app/features/checkout/domain/entities/order_entity.dart'; // این احتمالا لازم نیست
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Use case for placing an order
// It returns the order ID (int) on success
class PlaceOrderUsecase extends UseCase<int, PlaceOrderParams> { // <-- نوع برگشتی اصلاح شد به int
  final CheckoutRepository repository;

  PlaceOrderUsecase(this.repository);

  @override
  Future<Either<Failure, int>> call(PlaceOrderParams params) async { // <-- نوع برگشتی اصلاح شد به int
    return await repository.placeOrder( // <-- فراخوانی متد ریپازیتوری
      address: params.address,
      couponCode: params.couponCode,
      notes: params.notes,
    );
  }
}

// Parameters required for placing an order
class PlaceOrderParams extends Equatable {
  final AddressEntity address;
  final String? couponCode;
  final String? notes;

  const PlaceOrderParams({
    required this.address,
    this.couponCode,
    this.notes,
  });

  @override
  List<Object?> get props => [address, couponCode, notes];
}