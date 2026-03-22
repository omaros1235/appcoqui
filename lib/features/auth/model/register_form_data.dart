class RegisterFormData {
  const RegisterFormData({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.password,
    required this.confirmPassword,
  });

  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String ciudad;
  final String password;
  final String confirmPassword;
}
