import 'package:flutter/foundation.dart';

class AppEnvironment {
  const AppEnvironment._();

  static String get host {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000';
    }
  }

  static String get apiHost => '$host/api';
}

class ApiConstants {
  const ApiConstants._();

  static String get baseUrl => AppEnvironment.apiHost;

  // Si tu backend de pagos usa JWT en lugar de Token, cambia a Bearer.
  static const String esquemaAutorizacionPagos = 'Bearer';
}

class AppConstants {
  static String get baseUrl => AppEnvironment.host;

  static const String registerEndpoint = '/register/';
  static const String loginEndpoint = '/login/';
  static const String homeEndpoint = '/home/';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
