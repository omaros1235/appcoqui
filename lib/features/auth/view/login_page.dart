import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../model/login_credentials.dart';
import '../viewmodel/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.repository,
  });

  final AuthRepository repository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(widget.repository);
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ok = await _viewModel.login(
      LoginCredentials(
        correo: _correoController.text.trim(),
        password: _passwordController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    if (ok && _viewModel.tokens != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: _viewModel.tokens!.access,
      );
      return;
    }

    final message = _viewModel.errorMessage ?? 'No fue posible iniciar sesion.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Iniciar sesion',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Conecta Flutter con tu API Django usando JWT.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _correoController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa tu correo.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu password.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _viewModel.isLoading ? null : _submit,
                              child: _viewModel.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Entrar'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _viewModel.isLoading
                                  ? null
                                  : () => Navigator.pushNamed(context, AppRoutes.register),
                              child: const Text('Crear cuenta nueva'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
