import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final ok = await authViewModel.register(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    final message = ok
        ? authViewModel.successMessage ?? 'Registro exitoso.'
        : authViewModel.errorMessage ?? 'No fue posible registrarte.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (ok) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF7EF);
    const card = Color(0xFFFFFCF8);
    const textPrimary = Color(0xFF4B2A18);
    const textSecondary = Color(0xFF8C5A3C);
    const accent = Color(0xFFC63D2F);
    const accentDark = Color(0xFF8E231D);
    const accentGold = Color(0xFFF2A007);
    const fieldFill = Color(0xFFF8E9DA);
    const fieldBorder = Color(0xFFEED7C2);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Crear cuenta',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
                  top: 220,
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
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
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
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        width: 66,
                                        height: 66,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.16),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_add_alt_1_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Unete a Fast Bites',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              'Crea tu cuenta para guardar favoritos, pedir rapido y seguir tus ordenes.',
                                              style: TextStyle(
                                                color: Color(0xFFFFEFE2),
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _FormFieldBlock(
                                            label: 'Nombre',
                                            child: TextFormField(
                                              controller: _nombreController,
                                              style: const TextStyle(color: textPrimary),
                                              decoration: _buildInputDecoration(
                                                hint: 'Tu nombre',
                                                fillColor: fieldFill,
                                                icon: Icons.badge_outlined,
                                                borderColor: fieldBorder,
                                                focusedColor: accent,
                                              ),
                                              validator: _required,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _FormFieldBlock(
                                            label: 'Apellido',
                                            child: TextFormField(
                                              controller: _apellidoController,
                                              style: const TextStyle(color: textPrimary),
                                              decoration: _buildInputDecoration(
                                                hint: 'Tu apellido',
                                                fillColor: fieldFill,
                                                icon: Icons.person_outline_rounded,
                                                borderColor: fieldBorder,
                                                focusedColor: accent,
                                              ),
                                              validator: _required,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _FormFieldBlock(
                                      label: 'Correo electronico',
                                      child: TextFormField(
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
                                        validator: _required,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _FormFieldBlock(
                                            label: 'Telefono',
                                            child: TextFormField(
                                              controller: _telefonoController,
                                              keyboardType: TextInputType.phone,
                                              style: const TextStyle(color: textPrimary),
                                              decoration: _buildInputDecoration(
                                                hint: '0999999999',
                                                fillColor: fieldFill,
                                                icon: Icons.call_outlined,
                                                borderColor: fieldBorder,
                                                focusedColor: accent,
                                              ),
                                              validator: _required,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _FormFieldBlock(
                                            label: 'Ciudad',
                                            child: TextFormField(
                                              controller: _ciudadController,
                                              style: const TextStyle(color: textPrimary),
                                              decoration: _buildInputDecoration(
                                                hint: 'Tu ciudad',
                                                fillColor: fieldFill,
                                                icon: Icons.location_on_outlined,
                                                borderColor: fieldBorder,
                                                focusedColor: accent,
                                              ),
                                              validator: _required,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _FormFieldBlock(
                                      label: 'Contrasena',
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        style: const TextStyle(color: textPrimary),
                                        decoration: _buildInputDecoration(
                                          hint: 'Minimo 6 caracteres',
                                          fillColor: fieldFill,
                                          icon: Icons.lock_outline_rounded,
                                          borderColor: fieldBorder,
                                          focusedColor: accent,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingresa tu password.';
                                          }
                                          if (value.length < 6) {
                                            return 'Usa al menos 6 caracteres.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _FormFieldBlock(
                                      label: 'Confirmar contrasena',
                                      child: TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: true,
                                        style: const TextStyle(color: textPrimary),
                                        decoration: _buildInputDecoration(
                                          hint: 'Repite tu contrasena',
                                          fillColor: fieldFill,
                                          icon: Icons.verified_user_outlined,
                                          borderColor: fieldBorder,
                                          focusedColor: accent,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Confirma tu password.';
                                          }
                                          if (value != _passwordController.text) {
                                            return 'Las contrasenas no coinciden.';
                                          }
                                          return null;
                                        },
                                      ),
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
                                            Icons.local_fire_department_rounded,
                                            color: accent,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Con tu cuenta podras pedir mas rapido y guardar tus productos favoritos.',
                                              style: TextStyle(
                                                color: textSecondary,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),
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
                                                'Crear mi cuenta',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                      ),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }
}

class _FormFieldBlock extends StatelessWidget {
  const _FormFieldBlock({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E4024),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
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


