import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;
  String? _authToken;

  void updateAuthToken(String? token) {
    _authToken = token?.isNotEmpty == true ? token : null;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) {
    return _send(
      'POST',
      path,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) {
    return _send(
      'PATCH',
      path,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) {
    return _send(
      'DELETE',
      path,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    if (_authToken != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $_authToken';
    }

    final request = http.Request(method, uri);
    request.headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      final response = await http.Response.fromStream(
        await _httpClient.send(request),
      );
      return _handleResponse(response);
    } on SocketException catch (error) {
      throw ApiException(message: 'Network error: ${error.message}');
    } on HttpException catch (error) {
      throw ApiException(message: 'HTTP error: ${error.message}');
    } on FormatException catch (error) {
      throw ApiException(message: 'Invalid response format: ${error.message}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        return null;
      }
      return jsonDecode(body);
    }

    dynamic decoded;
    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    final message = decoded is Map<String, dynamic>
        ? (decoded['message'] as String?) ?? 'Request failed with status $statusCode'
        : 'Request failed with status $statusCode';

    throw ApiException(
      message: message,
      statusCode: statusCode,
      details: decoded,
    );
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$normalizedBase$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final filtered = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value == null) {
        return;
      }
      final stringValue = value.toString();
      if (stringValue.isEmpty) {
        return;
      }
      filtered[key] = stringValue;
    });

    return uri.replace(queryParameters: filtered.isEmpty ? null : filtered);
  }

  void close() {
    _httpClient.close();
  }
}
