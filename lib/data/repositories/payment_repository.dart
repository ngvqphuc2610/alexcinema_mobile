import '../datasources/payment_remote_data_source.dart';
import '../models/dto/payment_dto.dart';

class PaymentRepository {
  const PaymentRepository(this._remoteDataSource);

  final PaymentRemoteDataSource _remoteDataSource;

  Future<ZaloPayOrderResponseDto> createZaloPayOrder({
    required int bookingId,
    double? amount,
    String? description,
  }) {
    return _remoteDataSource.createZaloPayOrder(
      bookingId: bookingId,
      amount: amount,
      description: description,
    );
  }

  Future<VNPayOrderResponseDto> createVNPayOrder({
    required int bookingId,
    double? amount,
    String? description,
    String? bankCode,
    String? locale,
  }) {
    return _remoteDataSource.createVNPayOrder(
      bookingId: bookingId,
      amount: amount,
      description: description,
      bankCode: bankCode,
      locale: locale,
    );
  }

  Future<PaymentStatusDto> getPaymentStatus(String transactionId) {
    return _remoteDataSource.fetchPaymentStatus(transactionId);
  }
}
