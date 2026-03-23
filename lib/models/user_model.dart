class UserModel {
  const UserModel({
    required this.nombre,
    required this.correo,
    required this.mensaje,
  });

  final String nombre;
  final String correo;
  final String mensaje;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nombre: json['nombre']?.toString() ??
          json['name']?.toString() ??
          json['usuario']?['nombre']?.toString() ??
          '',
      correo: json['correo']?.toString() ??
          json['email']?.toString() ??
          json['usuario']?['correo']?.toString() ??
          '',
      mensaje: json['message']?.toString() ??
          json['mensaje']?.toString() ??
          'Bienvenido a App Coqui',
    );
  }
}
