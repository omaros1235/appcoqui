import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  UserModel? user;

  Future<bool> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String ciudad,
    required String password,
    required String confirmPassword,
  }) async {
    _startLoading();

    try {
      await _authService.register(
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        ciudad: ciudad,
        password: password,
        confirmPassword: confirmPassword,
      );
      successMessage = 'Registro exitoso. Ahora puedes iniciar sesion.';
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<bool> login({
    required String correo,
    required String password,
  }) async {
    _startLoading();

    try {
      await _authService.login(
        correo: correo,
        password: password,
      );
      successMessage = 'Inicio de sesion exitoso.';
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<bool> getHome() async {
    _startLoading();

    try {
      user = await _authService.getHome();
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      if (error is AuthException && error.statusCode == 401) {
        user = null;
      }
      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<bool> restoreSession() async {
    final hasSession = await _authService.hasSession();
    if (!hasSession) {
      return false;
    }

    return getHome();
  }

  Future<void> logout() async {
    await _authService.clearTokens();
    user = null;
    successMessage = null;
    errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  void _startLoading() {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }
}
