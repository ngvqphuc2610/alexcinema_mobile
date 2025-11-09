import 'api_exception.dart';

Map<String, dynamic> ensureMap(dynamic data, {String? errorMessage}) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  throw ApiException(message: errorMessage ?? 'Unexpected response format.');
}

List<Map<String, dynamic>> ensureList(dynamic data, {String? errorMessage}) {
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }
  throw ApiException(message: errorMessage ?? 'Unexpected list response format.');
}
