import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:appcoqui/models/user_model.dart';
import 'package:appcoqui/services/auth_service.dart';
import 'package:appcoqui/viewmodels/auth_viewmodel.dart';
import 'package:appcoqui/views/login_view.dart';

class FakeAuthService extends AuthService {
  @override
  Future<bool> hasSession() async => false;

  @override
  Future<UserModel> getHome() async {
    throw const AuthException('No implementado en test.');
  }
}

void main() {
  testWidgets('muestra el login al iniciar sin sesion', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(authService: FakeAuthService()),
        child: const MaterialApp(home: LoginView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesion'), findsOneWidget);
    expect(find.text('Crear una cuenta'), findsOneWidget);
  });
}
