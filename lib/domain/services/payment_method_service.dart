import '../../data/models/entity/payment_method_entity.dart';
import '../../data/repositories/payment_method_repository.dart';

class PaymentMethodService {
  const PaymentMethodService(this._repository);

  final PaymentMethodRepository _repository;

  Future<List<PaymentMethodEntity>> getPaymentMethods({
    bool includeInactive = false,
  }) {
    return _repository.getPaymentMethods(includeInactive: includeInactive);
  }

  Future<PaymentMethodEntity> getPaymentMethod(int id) {
    return _repository.getPaymentMethod(id);
  }
}
