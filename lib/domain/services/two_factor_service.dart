import '../../data/models/dto/two_factor_secret_dto.dart';
import '../../data/repositories/two_factor_repository.dart';

class TwoFactorService {
  const TwoFactorService(this._repository);

  final TwoFactorRepository _repository;

  Future<TwoFactorSecretDto> enable2FA() {
    return _repository.enable2FA();
  }

  Future<List<String>> verify2FA(String code) {
    return _repository.verify2FA(code);
  }

  Future<void> disable2FA(String code) {
    return _repository.disable2FA(code);
  }

  Future<List<String>> getBackupCodes() {
    return _repository.getBackupCodes();
  }

  Future<List<String>> regenerateBackupCodes() {
    return _repository.regenerateBackupCodes();
  }
}
