import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final ok = await authViewModel.login(
      correo: _correoController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (ok) {
      final loaded = await authViewModel.getHome();
      if (!mounted) {
        return;
      }

      if (loaded) {
        context.go('/home');
        return;
      }
    }

    final message =
        authViewModel.errorMessage ?? 'No fue posible iniciar sesion.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF7EF);
    const card = Color(0xFFFFFCF8);
    const textPrimary = Color(0xFF4B2A18);
    const textSecondary = Color(0xFF8C5A3C);
    const accent = Color.fromARGB(255, 165, 146, 22);
    const accentDark = Color(0xFF8E231D);
    const accentGold = Color(0xFFF2A007);
    const fieldFill = Color(0xFFF8E9DA);
    const fieldBorder = Color(0xFFEED7C2);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -30,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x33F2A007), Color(0x00F2A007)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -60,
                  top: 180,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x22C63D2F), Color(0x00C63D2F)],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Container(
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: const Color(0xFFF1DFD1)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1FA54C1A),
                              blurRadius: 30,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.vertical(top: Radius.circular(34)),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [accentDark, accentGold],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      _BrandDot(color: Colors.white),
                                      SizedBox(width: 8),
                                      _BrandDot(color: Color(0xFFFFD7A7)),
                                      SizedBox(width: 8),
                                      _BrandDot(color: Color(0xFFFFF2E4)),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  Center(
                                    child: Container(
                                      width: 102,
                                      height: 102,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.18),
                                        ),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x22000000),
                                              blurRadius: 14,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.lunch_dining_rounded,
                                          size: 42,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const Center(
                                    child: Text(
                                      'Fast Bites',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      'Ingresa y pide tus combos favoritos en minutos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFFEFE2),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Bienvenido de nuevo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: textPrimary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Accede a tu cuenta para ver promociones, favoritos y tu pedido.',
                                      style: TextStyle(
                                        color: textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _InputLabel(label: 'Correo electronico'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _correoController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(color: textPrimary),
                                      decoration: _buildInputDecoration(
                                        hint: 'ejemplo@correo.com',
                                        fillColor: fieldFill,
                                        icon: Icons.mail_outline_rounded,
                                        borderColor: fieldBorder,
                                        focusedColor: accent,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Ingresa tu correo.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _InputLabel(label: 'Contrasena'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      style: const TextStyle(color: textPrimary),
                                      decoration: _buildInputDecoration(
                                        hint: 'Tu contrasena',
                                        fillColor: fieldFill,
                                        icon: Icons.lock_outline_rounded,
                                        borderColor: fieldBorder,
                                        focusedColor: accent,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingresa tu password.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1E5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFF1DECE),
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.delivery_dining_rounded,
                                            color: accent,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Entrega rapida, combos calientes y seguimiento de tu pedido.',
                                              style: TextStyle(
                                                color: textSecondary,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 52,
                                      child: FilledButton(
                                        onPressed:
                                            authViewModel.isLoading ? null : _submit,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: accent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: authViewModel.isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Ingresar ahora',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    TextButton(
                                      onPressed: authViewModel.isLoading
                                          ? null
                                          : () {
                                              context.push('/register');
                                            },
                                      style: TextButton.styleFrom(
                                        foregroundColor: textSecondary,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      child: const Text('Crear una cuenta'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required Color fillColor,
    required IconData icon,
    required Color borderColor,
    required Color focusedColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.brown.shade300),
      prefixIcon: Icon(icon, color: focusedColor),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: focusedColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6E4024),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BrandDot extends StatelessWidget {
  const _BrandDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

