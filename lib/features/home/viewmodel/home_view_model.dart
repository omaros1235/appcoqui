import 'package:flutter/foundation.dart';

import '../../../data/models/home_data.dart';
import '../../../data/repositories/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AuthRepository repository,
    required String token,
  })  : _repository = repository,
        _token = token;

  final AuthRepository _repository;
  final String _token;

  bool isLoading = true;
  String? errorMessage;
  HomeData? homeData;

  Future<void> loadHome() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      homeData = await _repository.getHome(_token);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
