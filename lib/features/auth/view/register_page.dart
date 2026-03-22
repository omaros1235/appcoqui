import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../model/register_form_data.dart';
import '../viewmodel/register_view_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.repository,
  });

  final AuthRepository repository;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(widget.repository);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ok = await _viewModel.register(
      RegisterFormData(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        ciudad: _ciudadController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    final message = ok
        ? _viewModel.successMessage ?? 'Registro exitoso.'
        : _viewModel.errorMessage ?? 'No fue posible registrarte.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Crear cuenta')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nombreController,
                                    decoration: const InputDecoration(labelText: 'Nombre'),
                                    validator: _required,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _apellidoController,
                                    decoration: const InputDecoration(labelText: 'Apellido'),
                                    validator: _required,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _correoController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Correo'),
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _telefonoController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Telefono'),
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ciudadController,
                              decoration: const InputDecoration(labelText: 'Ciudad'),
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Este campo es obligatorio.';
                                }
                                if (value.length < 6) {
                                  return 'Usa al menos 6 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Confirmar password'),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Las contrasenas no coinciden.';
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
                                  : const Text('Registrarme'),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }
}
