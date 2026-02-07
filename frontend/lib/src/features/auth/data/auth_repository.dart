import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/config/backend_config.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final String baseUrl;
  final http.Client _httpClient;

  String? _currentUserId;
  String? _currentUserEmail;
  String? _idToken;
  bool get isAuthenticated => _currentUserId != null;

  AuthRepository({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
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
      final response = await _httpClient.post(
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
      final response = await _httpClient.post(
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
      await _httpClient.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {'Content-Type': 'application/json'},
      );

      _currentUserId = null;
      _currentUserEmail = null;
    } catch (e) {
      _currentUserId = null;
      _currentUserEmail = null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_photo/'),
      );
      if (_idToken != null) {
        request.headers['Authorization'] = 'Bearer $_idToken';
      }
      request.files.add(
        http.MultipartFile.fromBytes('photo', fileBytes, filename: fileName),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'url': data['saved done'] ?? data['url']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Upload failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  String? get userId => _currentUserId;
  String? get userEmail => _currentUserEmail;
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(baseUrl: BackendConfig.baseUrl);
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated;
}
