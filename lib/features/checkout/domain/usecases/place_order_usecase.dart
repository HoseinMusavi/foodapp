// lib/features/checkout/domain/usecases/place_order_usecase.dart

import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/usecase/usecase.dart';
import 'package:customer_app/features/customer/domain/entities/address_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../repositories/checkout_repository.dart';

class PlaceOrderUsecase implements UseCase<int, PlaceOrderParams> {
  final CheckoutRepository repository;

  PlaceOrderUsecase(this.repository);

  @override
  Future<Either<Failure, int>> call(PlaceOrderParams params) async {
    // --- اصلاح شد: ---
    // یوزکیس باید آبجکت params را مستقیماً به ریپازیتوری پاس دهد
    // (قبلاً به اشتباه تلاش می‌کرد پارامترها را باز کند)
    return await repository.placeOrder(params);
    // --- پایان اصلاح ---
  }
}

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