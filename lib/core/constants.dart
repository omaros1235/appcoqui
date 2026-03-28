import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  // URL base para endpoints versionados bajo /api.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Si tu backend de pagos usa JWT en lugar de Token, cambia a Bearer.
  static const String esquemaAutorizacionPagos = 'Token';
}

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    return 'http://10.0.2.2:8000';
  }

  static const String registerEndpoint = '/register/';
  static const String loginEndpoint = '/login/';
  static const String homeEndpoint = '/home/';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
