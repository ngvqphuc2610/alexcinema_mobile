import '../../../data/models/dto/payment_dto.dart';
import '../common/bloc_status.dart';

enum PaymentFlowStatus {
  idle,
  creatingOrder,
  redirecting,
  polling,
  success,
  failure,
}

class PaymentState {
  const PaymentState({
    this.status = PaymentFlowStatus.idle,
    this.order,
    this.latestStatus,
    this.errorMessage,
  });

  final PaymentFlowStatus status;
  final ZaloPayOrderResponseDto? order;
  final PaymentStatusDto? latestStatus;
  final String? errorMessage;

  bool get isBusy =>
      status == PaymentFlowStatus.creatingOrder ||
      status == PaymentFlowStatus.redirecting ||
      status == PaymentFlowStatus.polling;

  PaymentState copyWith({
    PaymentFlowStatus? status,
    ZaloPayOrderResponseDto? order,
    PaymentStatusDto? latestStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      order: order ?? this.order,
      latestStatus: latestStatus ?? this.latestStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
