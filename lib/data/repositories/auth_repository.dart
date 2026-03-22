import '../models/auth_tokens.dart';
import '../models/home_data.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  const AuthRepository(this._apiService);

  final AuthApiService _apiService;

  Future<void> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String ciudad,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiService.register(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      ciudad: ciudad,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<AuthTokens> login({
    required String correo,
    required String password,
  }) async {
    final response = await _apiService.login(
      correo: correo,
      password: password,
    );

    return AuthTokens.fromJson(response);
  }

  Future<HomeData> getHome(String token) async {
    final response = await _apiService.getHome(token);
    return HomeData.fromJson(response);
  }
}
