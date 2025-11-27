import '../../data/models/dto/payment_dto.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentService {
  const PaymentService(this._repository);

  final PaymentRepository _repository;

  Future<ZaloPayOrderResponseDto> createZaloPayOrder({
    required int bookingId,
    double? amount,
    String? description,
  }) {
    return _repository.createZaloPayOrder(
      bookingId: bookingId,
      amount: amount,
      description: description,
    );
  }

  Future<PaymentStatusDto> getPaymentStatus(String transactionId) {
    return _repository.getPaymentStatus(transactionId);
  }
}
