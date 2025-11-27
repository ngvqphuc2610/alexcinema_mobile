import '../models/dto/payment_dto.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ZaloPayOrderResponseDto> createZaloPayOrder({
    required int bookingId,
    double? amount,
    String? description,
  }) async {
    final response = await _client.post(
      'payments/zalopay/order',
      body: {
        'bookingId': bookingId,
        if (amount != null) 'amount': amount,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    final map = ensureMap(response, errorMessage: 'Invalid ZaloPay order response');
    return ZaloPayOrderResponseDto.fromJson(map);
  }

  Future<PaymentStatusDto> fetchPaymentStatus(String transactionId) async {
    final response = await _client.get('payments/status/$transactionId');
    final map = ensureMap(response, errorMessage: 'Invalid payment status response');
    return PaymentStatusDto.fromJson(map);
  }
}
