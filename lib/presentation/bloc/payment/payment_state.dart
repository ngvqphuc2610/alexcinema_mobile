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
    this.zaloOrder,
    this.vnpayOrder,
    this.momoOrder,
    this.latestStatus,
    this.errorMessage,
  });

  final PaymentFlowStatus status;
  final ZaloPayOrderResponseDto? zaloOrder;
  final VNPayOrderResponseDto? vnpayOrder;
  final MoMoOrderResponseDto? momoOrder;
  final PaymentStatusDto? latestStatus;
  final String? errorMessage;

  bool get isBusy =>
      status == PaymentFlowStatus.creatingOrder ||
      status == PaymentFlowStatus.redirecting ||
      status == PaymentFlowStatus.polling;

  String? get transactionId =>
      latestStatus?.transactionId ??
      zaloOrder?.appTransId ??
      vnpayOrder?.txnRef ??
      momoOrder?.orderId;

  PaymentState copyWith({
    PaymentFlowStatus? status,
    ZaloPayOrderResponseDto? zaloOrder,
    VNPayOrderResponseDto? vnpayOrder,
    MoMoOrderResponseDto? momoOrder,
    PaymentStatusDto? latestStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      zaloOrder: zaloOrder ?? this.zaloOrder,
      vnpayOrder: vnpayOrder ?? this.vnpayOrder,
      momoOrder: momoOrder ?? this.momoOrder,
      latestStatus: latestStatus ?? this.latestStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
