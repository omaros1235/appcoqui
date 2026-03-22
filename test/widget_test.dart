import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appcoqui/data/repositories/auth_repository.dart';
import 'package:appcoqui/data/services/auth_api_service.dart';
import 'package:appcoqui/main.dart';

void main() {
  testWidgets('muestra la pantalla de login al iniciar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: AuthRepository(const AuthApiService()),
      ),
    );

    expect(find.text('Iniciar sesion'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
