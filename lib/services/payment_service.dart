import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/payment_model.dart';
import 'api_service.dart';

class PaymentService {
  PaymentService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  Future<Payment> createTransferPayment(TransferPaymentRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/transfer/'),
        headers: await _headersAutorizados(json: true),
        body: jsonEncode(request.toJson()),
      );

      final decoded = _decodeResponse(response);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Respuesta no valida al registrar transferencia.');
      }
      return Payment.fromJson(decoded);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('No se pudo registrar la transferencia: $error');
    }
  }

  Future<Payment> createCashPayment(CashPaymentRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/cash/'),
        headers: await _headersAutorizados(json: true),
        body: jsonEncode(request.toJson()),
      );

      final decoded = _decodeResponse(response);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Respuesta no valida al registrar pago en efectivo.');
      }
      return Payment.fromJson(decoded);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('No se pudo registrar el pago en efectivo: $error');
    }
  }

  Future<Payment> getPayment(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/payments/$id/'),
        headers: await _headersAutorizados(),
      );

      final decoded = _decodeResponse(response);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Respuesta no valida al obtener el pago.');
      }
      return Payment.fromJson(decoded);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('No se pudo obtener el pago: $error');
    }
  }

  Future<Payment> confirmPayment(int id) async {
    try {
      final response = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/payments/$id/confirm/'),
        headers: await _headersAutorizados(json: true),
        body: jsonEncode(<String, dynamic>{}),
      );

      final decoded = _decodeResponse(response);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Respuesta no valida al confirmar el pago.');
      }
      return Payment.fromJson(decoded);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('No se pudo confirmar el pago: $error');
    }
  }

  Future<List<Payment>> listPayments({
    String? method,
    String? status,
  }) async {
    try {
      final query = <String, String>{};
      if (method != null && method.isNotEmpty) {
        query['method'] = method;
      }
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/payments/').replace(
        queryParameters: query.isEmpty ? null : query,
      );

      final response = await _client.get(
        uri,
        headers: await _headersAutorizados(),
      );

      final decoded = _decodeResponse(response);
      final lista = decoded is List
          ? decoded
          : decoded is Map<String, dynamic>
              ? decoded['results'] ?? decoded['payments'] ?? <dynamic>[]
              : <dynamic>[];

      if (lista is! List) {
        throw const ApiException('Respuesta no valida al listar pagos.');
      }

      return lista
          .whereType<Map<String, dynamic>>()
          .map(Payment.fromJson)
          .toList(growable: false);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('No se pudo listar los pagos: $error');
    }
  }

  Future<Map<String, String>> _headersAutorizados({bool json = false}) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) {
      throw const ApiException('No hay token de autenticacion disponible.');
    }

    return <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Authorization': '${ApiConstants.esquemaAutorizacionPagos} $token',
    };
  }

  dynamic _decodeResponse(http.Response response) {
    final dynamic decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      throw ApiException(
        decoded['detail']?.toString() ??
            decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Error ${response.statusCode} al consumir pagos.',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      'Error ${response.statusCode} al consumir pagos.',
      statusCode: response.statusCode,
    );
  }
}
