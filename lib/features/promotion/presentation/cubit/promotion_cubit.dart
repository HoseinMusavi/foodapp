import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promotion_state.dart';

class PromotionCubit extends Cubit<PromotionState> {
  PromotionCubit() : super(PromotionInitial());
}
