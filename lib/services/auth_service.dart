import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String ciudad,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'telefono': telefono,
        'ciudad': ciudad,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    return _parseMapResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'password': password,
      }),
    );

    final data = _parseMapResponse(response);
    await saveTokens(
      access: data['access']?.toString() ?? '',
      refresh: data['refresh']?.toString() ?? '',
    );
    return data;
  }

  Future<UserModel> getHome() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('No se encontro un token de acceso.');
    }

    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.homeEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await clearTokens();
      throw AuthException('Tu sesion expiro. Inicia sesion nuevamente.', statusCode: 401);
    }

    final data = _parseMapResponse(response);
    return UserModel.fromJson(data);
  }

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: access);
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: refresh);
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  Map<String, dynamic> _parseMapResponse(http.Response response) {
    final dynamic decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw AuthException(
        'La API devolvio una respuesta no valida.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw AuthException(
      decoded['detail']?.toString() ??
          decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          'Error ${response.statusCode} al consumir la API.',
      statusCode: response.statusCode,
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
