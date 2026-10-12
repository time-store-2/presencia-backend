import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../services/api_service.dart';

/// Authentification via le backend Payload CMS (JWT).
/// Les comptes sont créés par l'admin de l'organisation :
/// pas d'inscription publique dans l'app.
class AuthProvider with ChangeNotifier {
  AuthProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  ApiService get apiService => _apiService;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _apiService.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Restaure la session sauvegardée (token JWT). À appeler au démarrage.
  Future<bool> tryRestoreSession() async {
    try {
      final restored = await _apiService.tryRestoreSession();
      _user = _apiService.currentUser;
      notifyListeners();
      return restored;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }
}
