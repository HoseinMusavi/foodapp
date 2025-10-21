// lib/core/error/failure.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {
  final String message;

  const ServerFailure({this.message = 'An unexpected error occurred.'});

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {}
