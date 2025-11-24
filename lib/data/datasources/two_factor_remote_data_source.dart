import '../models/dto/two_factor_secret_dto.dart';
import '../services/api_client.dart';

class TwoFactorRemoteDataSource {
  const TwoFactorRemoteDataSource(this._client);

  final ApiClient _client;

  Future<TwoFactorSecretDto> enable2FA() async {
    final response = await _client.post('/users/me/2fa/setup');
    return TwoFactorSecretDto.fromJson(response as Map<String, dynamic>);
  }

  Future<List<String>> verify2FA(String code) async {
    final response = await _client.post(
      '/users/me/2fa/enable',
      body: {'token': code},
    );
    return _parseBackupCodes(response);
  }

  Future<void> disable2FA(String code) async {
    await _client.post('/users/me/2fa/disable', body: {'token': code});
  }

  Future<List<String>> getBackupCodes() async {
    final response = await _client.get('/users/me/2fa/backup-codes');
    return _parseBackupCodes(response);
  }

  Future<List<String>> regenerateBackupCodes() async {
    final response = await _client.post(
      '/users/me/2fa/backup-codes/regenerate',
    );
    return _parseBackupCodes(response);
  }

  List<String> _parseBackupCodes(dynamic response) {
    // Backend returns { user: {...}, backupCodes: [...] }
    if (response is Map<String, dynamic> &&
        response.containsKey('backupCodes')) {
      return (response['backupCodes'] as List)
          .map((e) => e.toString())
          .toList();
    }
    // Fallback for 'codes' field
    if (response is Map<String, dynamic> && response.containsKey('codes')) {
      return (response['codes'] as List).map((e) => e.toString()).toList();
    }
    // Fallback if the API returns the list directly
    if (response is List) {
      return response.map((e) => e.toString()).toList();
    }
    return [];
  }
}
