import '../models/dto/two_factor_secret_dto.dart';
import '../services/api_client.dart';

class TwoFactorRemoteDataSource {
  const TwoFactorRemoteDataSource(this._client);

  final ApiClient _client;

  Future<TwoFactorSecretDto> enable2FA() async {
    final response = await _client.post('/auth/2fa/enable');
    return TwoFactorSecretDto.fromJson(response as Map<String, dynamic>);
  }

  Future<List<String>> verify2FA(String code) async {
    final response = await _client.post(
      '/auth/2fa/verify',
      body: {'code': code},
    );
    return _parseBackupCodes(response);
  }

  Future<void> disable2FA(String code) async {
    await _client.post(
      '/auth/2fa/disable',
      body: {'code': code},
    );
  }

  Future<List<String>> getBackupCodes() async {
    final response = await _client.get('/auth/2fa/backup-codes');
    return _parseBackupCodes(response);
  }

  Future<List<String>> regenerateBackupCodes() async {
    final response = await _client.post('/auth/2fa/backup-codes/regenerate');
    return _parseBackupCodes(response);
  }

  List<String> _parseBackupCodes(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('codes')) {
      return (response['codes'] as List).map((e) => e.toString()).toList();
    }
    // Fallback if the API returns the list directly or wrapped differently
    // Adjust based on actual API response if needed
    if (response is List) {
      return response.map((e) => e.toString()).toList();
    }
    // If verify returns backup codes directly in a 'backupCodes' field
    if (response is Map<String, dynamic> && response.containsKey('backupCodes')) {
      return (response['backupCodes'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }
}
