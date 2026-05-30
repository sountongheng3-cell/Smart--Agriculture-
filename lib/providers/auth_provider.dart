import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Login
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.login(email: email, password: password);
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
