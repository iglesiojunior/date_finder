import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Altere para o IP/URL do seu servidor
  // Para emulador Android: http://10.0.2.2:3000
  // Para dispositivo físico: http://SEU_IP_LOCAL:3000
  // Para produção: https://seu-dominio.com
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Para dispositivo físico, use seu IP local:
  // static const String baseUrl = 'http://192.168.1.X:3000/api';

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erro ao registrar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erro ao fazer login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Email enviado com sucesso',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erro ao solicitar recuperação',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Senha redefinida com sucesso',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erro ao redefinir senha',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyResetToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify-reset-token/$token'),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'valid': data['valid'] ?? false,
        };
      } else {
        return {
          'success': false,
          'valid': false,
          'error': data['error'] ?? 'Token inválido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
}

