import '../models/entity/payment_method_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class PaymentMethodRemoteDataSource {
  const PaymentMethodRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<PaymentMethodEntity>> fetchPaymentMethods({
    bool includeInactive = false,
  }) async {
    final response = await _client.get(
      'payment-methods',
      queryParameters: includeInactive ? {'includeInactive': true} : null,
    );
    final list = ensureList(response, errorMessage: 'Invalid payment methods response');
    return list
        .whereType<Map<String, dynamic>>()
        .map(PaymentMethodEntity.fromJson)
        .toList(growable: false);
  }

  Future<PaymentMethodEntity> fetchPaymentMethod(int id) async {
    final response = await _client.get('payment-methods/$id');
    final map = ensureMap(response, errorMessage: 'Invalid payment method response');
    return PaymentMethodEntity.fromJson(map);
  }
}
