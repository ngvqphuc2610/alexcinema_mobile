import '../datasources/payment_method_remote_data_source.dart';
import '../models/entity/payment_method_entity.dart';

class PaymentMethodRepository {
  const PaymentMethodRepository(this._remoteDataSource);

  final PaymentMethodRemoteDataSource _remoteDataSource;

  Future<List<PaymentMethodEntity>> getPaymentMethods({
    bool includeInactive = false,
  }) {
    return _remoteDataSource.fetchPaymentMethods(
      includeInactive: includeInactive,
    );
  }

  Future<PaymentMethodEntity> getPaymentMethod(int id) {
    return _remoteDataSource.fetchPaymentMethod(id);
  }
}
