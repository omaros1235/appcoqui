import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../model/register_form_data.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._repository);

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> register(RegisterFormData formData) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        nombre: formData.nombre,
        apellido: formData.apellido,
        correo: formData.correo,
        telefono: formData.telefono,
        ciudad: formData.ciudad,
        password: formData.password,
        confirmPassword: formData.confirmPassword,
      );
      successMessage = 'Cuenta creada correctamente. Ahora puedes iniciar sesion.';
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
