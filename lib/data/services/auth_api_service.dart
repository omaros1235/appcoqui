import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AuthApiService {
  const AuthApiService();

  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String ciudad,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
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

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'password': password,
      }),
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> getHome(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.home}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw AuthApiException(
        message: 'La API devolvio una respuesta no valida.',
        statusCode: response.statusCode,
        body: const {},
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw AuthApiException(
      message: decoded['detail']?.toString() ??
          decoded['message']?.toString() ??
          'Error ${response.statusCode} al consumir la API.',
      statusCode: response.statusCode,
      body: decoded,
    );
  }
}

class AuthApiException implements Exception {
  const AuthApiException({
    required this.message,
    required this.statusCode,
    required this.body,
  });

  final String message;
  final int statusCode;
  final Map<String, dynamic> body;

  @override
  String toString() => message;
}
