import 'package:flutter/foundation.dart';

import '../../../data/models/auth_tokens.dart';
import '../../../data/repositories/auth_repository.dart';
import '../model/login_credentials.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._repository);

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  AuthTokens? tokens;

  Future<bool> login(LoginCredentials credentials) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tokens = await _repository.login(
        correo: credentials.correo,
        password: credentials.password,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
