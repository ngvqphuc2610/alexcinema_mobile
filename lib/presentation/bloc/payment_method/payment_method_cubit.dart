import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/services/payment_method_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'payment_method_state.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  PaymentMethodCubit(this._service) : super(const PaymentMethodState());

  final PaymentMethodService _service;

  Future<void> fetch({bool includeInactive = false}) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final methods = await _service.getPaymentMethods(
        includeInactive: includeInactive,
      );
      emit(
        state.copyWith(
          status: BlocStatus.success,
          items: methods,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }
}
