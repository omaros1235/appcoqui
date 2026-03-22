import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/register_page.dart';
import '../features/home/view/home_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Coqui',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute<void>(
              builder: (_) => LoginPage(repository: authRepository),
            );
          case AppRoutes.register:
            return MaterialPageRoute<void>(
              builder: (_) => RegisterPage(repository: authRepository),
            );
          case AppRoutes.home:
            final token = settings.arguments as String? ?? '';
            return MaterialPageRoute<void>(
              builder: (_) => HomePage(
                repository: authRepository,
                token: token,
              ),
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => LoginPage(repository: authRepository),
            );
        }
      },
    );
  }
}
