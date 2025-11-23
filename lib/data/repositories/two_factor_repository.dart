import '../datasources/two_factor_remote_data_source.dart';
import '../models/dto/two_factor_secret_dto.dart';

class TwoFactorRepository {
  const TwoFactorRepository(this._remoteDataSource);

  final TwoFactorRemoteDataSource _remoteDataSource;

  Future<TwoFactorSecretDto> enable2FA() {
    return _remoteDataSource.enable2FA();
  }

  Future<List<String>> verify2FA(String code) {
    return _remoteDataSource.verify2FA(code);
  }

  Future<void> disable2FA(String code) {
    return _remoteDataSource.disable2FA(code);
  }

  Future<List<String>> getBackupCodes() {
    return _remoteDataSource.getBackupCodes();
  }

  Future<List<String>> regenerateBackupCodes() {
    return _remoteDataSource.regenerateBackupCodes();
  }
}
