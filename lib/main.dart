import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/auth_api_service.dart';

void main() {
  runApp(
    MyApp(
      authRepository: AuthRepository(const AuthApiService()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return AppRoot(authRepository: authRepository);
  }
}
