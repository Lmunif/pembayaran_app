import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      
      _isLoading = false;
      
      if (response.success) {
        _isAuthenticated = true;
        _token = response.token;
        _userData = response.userData;
        _errorMessage = null;
      } else {
        _isAuthenticated = false;
        _token = null;
        _userData = null;
        _errorMessage = response.message;
      }
      
      notifyListeners();
      return response.success;
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      _token = null;
      _userData = null;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String name, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(username, email, name, password);
      _isLoading = false;
      notifyListeners();
      return await login(username, password);
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      _token = null;
      _userData = null;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil API logout ke server
      await _authService.logout();
    } catch (e) {
      // Abaikan error network agar user tetap bisa logout secara lokal
      debugPrint('Logout API error: $e');
    }

    // Selalu hapus state lokal terlepas dari hasil API
    _isAuthenticated = false;
    _token = null;
    _userData = null;
    _errorMessage = null;
    _isLoading = false;
    
    // Bersihkan session cookie di AuthService
    AuthService.clearSession();
    
    notifyListeners();
    return true;
  }
}
