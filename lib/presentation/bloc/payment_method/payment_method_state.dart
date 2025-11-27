import '../../../data/models/entity/payment_method_entity.dart';
import '../common/bloc_status.dart';

class PaymentMethodState {
  const PaymentMethodState({
    this.status = BlocStatus.initial,
    this.items = const <PaymentMethodEntity>[],
    this.errorMessage,
  });

  final BlocStatus status;
  final List<PaymentMethodEntity> items;
  final String? errorMessage;

  PaymentMethodState copyWith({
    BlocStatus? status,
    List<PaymentMethodEntity>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentMethodState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
