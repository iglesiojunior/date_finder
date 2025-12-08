import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  String? _token;
  late final Future<void> _initialization;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  AuthController() {
    _initialization = _loadStoredAuth();
  }

  Future<void> ensureInitialized() async {
    await _initialization;
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');

      if (token != null && userId != null && email != null) {
        _token = token;
        _currentUser = User(
          id: userId,
          email: email,
          password: '', // Não armazenamos senha
          name: name,
        );
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      // Ignorar erros ao carregar
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String? name) async {
    try {
      final result = await ApiService.register(
        email: email,
        password: password,
        name: name,
      );

      if (result['success'] == true) {
        final data = result['data'];
        _token = data['token'];
        _currentUser = User(
          id: data['user']['id'],
          email: data['user']['email'],
          password: '',
          name: data['user']['name'],
        );
        _isAuthenticated = true;

        // Salvar no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setInt('user_id', _currentUser!.id!);
        await prefs.setString('user_email', _currentUser!.email);
        if (_currentUser!.name != null) {
          await prefs.setString('user_name', _currentUser!.name!);
        }

        notifyListeners();
        return {'success': true};
      } else {
        return {'success': false, 'error': result['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erro ao registrar: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final data = result['data'];
        _token = data['token'];
        _currentUser = User(
          id: data['user']['id'],
          email: data['user']['email'],
          password: '',
          name: data['user']['name'],
        );
        _isAuthenticated = true;

        // Salvar no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setInt('user_id', _currentUser!.id!);
        await prefs.setString('user_email', _currentUser!.email);
        if (_currentUser!.name != null) {
          await prefs.setString('user_name', _currentUser!.name!);
        }

        notifyListeners();
        return {'success': true};
      } else {
        return {'success': false, 'error': result['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erro ao fazer login: ${e.toString()}'};
    }
  }

  void logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _token = null;

    // Limpar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');

    notifyListeners();
  }
}

