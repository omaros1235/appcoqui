import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class ApiService {
  ApiService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  String get _baseUrl => AppConstants.baseUrl;

  Future<List<ProductModel>> getProductos() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/productos/'),
      headers: {'Content-Type': 'application/json'},
    );

    final decoded = _decodeResponse(response);
    final rawList = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
            ? decoded['results'] ?? decoded['productos'] ?? decoded['items'] ?? <dynamic>[]
            : <dynamic>[];

    if (rawList is! List) {
      throw ApiException('La API devolvio productos en un formato no valido.');
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList(growable: false);
  }

  Future<CartModel> getCarrito() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/carrito/'),
      headers: await _authorizedHeaders(),
    );

    final decoded = _decodeResponse(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('La API devolvio un carrito no valido.');
    }
    return CartModel.fromJson(decoded);
  }

  Future<CartModel> agregarAlCarrito({
    required int productoId,
    required int cantidad,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/carrito/agregar/'),
      headers: await _authorizedHeaders(json: true),
      body: jsonEncode({
        'producto_id': productoId,
        'cantidad': cantidad,
      }),
    );

    final decoded = _decodeResponse(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('La API devolvio una respuesta no valida al agregar al carrito.');
    }
    return CartModel.fromJson(decoded);
  }

  Future<OrderModel> crearPedido() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/pedido/crear/'),
      headers: await _authorizedHeaders(json: true),
      body: jsonEncode(<String, dynamic>{}),
    );

    final decoded = _decodeResponse(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('La API devolvio un pedido no valido.');
    }
    return OrderModel.fromJson(decoded);
  }

  Future<Map<String, dynamic>> pagarPedido(int pedidoId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/pago/'),
      headers: await _authorizedHeaders(json: true),
      body: jsonEncode({'pedido_id': pedidoId}),
    );

    final decoded = _decodeResponse(response);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('La API devolvio una respuesta no valida al pagar.');
    }
    return decoded;
  }

  Future<Map<String, String>> _authorizedHeaders({bool json = false}) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) {
      throw ApiException('No se encontro un token de acceso para continuar.');
    }

    return <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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
            'Error ${response.statusCode} al consumir la API.',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      'Error ${response.statusCode} al consumir la API.',
      statusCode: response.statusCode,
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
