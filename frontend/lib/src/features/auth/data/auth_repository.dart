import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/config/backend_config.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final String baseUrl;

  String? _currentUserId;
  String? _currentUserEmail;
  String? _idToken;

  bool get isAuthenticated => _currentUserId != null;
  String? get userId => _currentUserId;
  String? get userEmail => _currentUserEmail;
  String? get idToken => _idToken;

  AuthRepository({required this.baseUrl});

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/postsignIn/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUserId = data['uid'];
        _currentUserEmail = data['email'];
        _idToken = data['idToken'];
        return {'success': true, 'uid': data['uid'], 'email': data['email']};
      } else {
        return {'success': false, 'error': 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordRepeat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/postsignUp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_repeat': passwordRepeat,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Account created successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google-login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUserId = data['uid'];
        _currentUserEmail = data['email'];
        _idToken = idToken;
        return {'success': true, 'uid': data['uid'], 'email': data['email']};
      } else {
        return {'success': false, 'error': 'Google login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> signOut() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      rethrow;
    } finally {
      _currentUserId = null;
      _currentUserEmail = null;
      _idToken = null;
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(baseUrl: BackendConfig.baseUrl);
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated;
}
