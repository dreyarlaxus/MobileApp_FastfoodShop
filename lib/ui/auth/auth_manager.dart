import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../ui/cart/cart_manager.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;

  User? _loggedInUser;
  final CartManager _cartManager;

  AuthManager(this._cartManager) {
    _authService = AuthService(onAuthChange: (User? user) {
      _loggedInUser = user;
      if (user != null) {
        _cartManager.fetchCartItems(user.id); // Fetch cart items after login
      }
      notifyListeners();
    });
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  Future<User> signup(String email, String password, String phone, String name) {
    return _authService.signup(email, password, phone, name);
  }

  Future<User> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (user != null) {
      _loggedInUser = user;
      _cartManager.fetchCartItems(user.id);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    return _authService.logout();
  }

  Future<void> updateUser(User user) async {
    final updatedUser = await _authService.updateUser(user);
    if (updatedUser != null) {
      _loggedInUser = updatedUser;
      notifyListeners();
    }
  }
}
