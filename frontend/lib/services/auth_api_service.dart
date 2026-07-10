import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:png_game/classes/data.dart';
import 'package:png_game/core/env.dart';
import 'package:png_game/models/my_user.dart';

class AuthApiService extends ChangeNotifier {
  AuthApiService() {
    _loadUser();
  }

  final String baseUrl = '${AppEnv.backendBaseUrl}/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  MyUser? _user;
  String? _token;
  Map<String, dynamic>? _stats;
  bool _isReady = false;

  MyUser? get user => _user;
  String? get token => _token;
  Map<String, dynamic>? get stats => _stats;
  bool get isReady => _isReady;

  Future<void> _loadUser() async {
    _token = await _storage.read(key: 'jwt_token');
    final userId = await _storage.read(key: 'user_id');
    final userEmail = await _storage.read(key: 'user_email');
    final userName = await _storage.read(key: 'user_name');

    if (_token != null && userId != null) {
      _user = MyUser(uid: userId, email: userEmail, name: userName);
      Data().updateUserId(userId);
      await fetchMyStats();
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    _token = data['access_token'] as String?;
    final userData = Map<String, dynamic>.from(data['user'] as Map);

    await _storage.write(key: 'jwt_token', value: _token);
    await _storage.write(key: 'user_id', value: userData['id']?.toString());
    await _storage.write(key: 'user_email', value: userData['email']?.toString());
    await _storage.write(key: 'user_name', value: userData['name']?.toString());

    _user = MyUser(
      uid: userData['id']?.toString() ?? '',
      email: userData['email']?.toString(),
      name: userData['name']?.toString(),
    );
    Data().updateUserId(_user?.uid ?? '');
    await fetchMyStats();
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    await _googleSignIn.signOut();
    _token = null;
    _user = null;
    _stats = null;
    Data().resetMatchState();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchMyStats() async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        _stats = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        notifyListeners();
        return _stats;
      }
    } catch (_) {
      // Keep the cached stats if the request fails.
    }

    return null;
  }

  Future<dynamic> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _saveSession(data);
        return _user;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return error['message'] ?? 'Failed to register';
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _saveSession(data);
        return _user;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return error['message'] ?? 'Failed to sign in';
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      debugPrint('[GoogleSignIn] Starting WebView OAuth flow at: $baseUrl/google');

      final callbackUrl = await FlutterWebAuth2.authenticate(
        url: '$baseUrl/google',
        callbackUrlScheme: 'pnggame',
      ).timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('Google sign-in timed out.'),
      );

      final callbackUri = Uri.parse(callbackUrl);
      final queryParameters = callbackUri.queryParameters;

      final accessToken = queryParameters['access_token'] ?? queryParameters['accessToken'];
      final error = queryParameters['error'];

      if (error != null) {
        throw Exception('Google sign-in error: $error');
      }

      if (accessToken == null) {
        throw Exception('Failed to get access token from callback.');
      }

      // If the backend returns user data in the query, we can parse it, or we can use the token.
      // Since our saveSession just needs the full response json, let's assume the backend 
      // sends the token and user data in the callback url, or we decode the JWT token.
      
      // We will parse the JWT token to get the user data
      final user = _userFromJwt(accessToken);
      
      final data = {
        'access_token': accessToken,
        'user': {
          'id': user.id,
          'email': user.email,
          'name': user.name,
        }
      };

      await _saveSession(data);
      return _user;
    } catch (e, st) {
      debugPrint('[GoogleSignIn] EXCEPTION: $e');
      debugPrint('[GoogleSignIn] StackTrace: $st');
      
      String message = 'Google sign-in failed';
      if (e.toString().contains('canceled') || e.toString().contains('Canceled')) {
        message = 'Google sign-in was canceled.';
      }
      
      return message;
    }
  }

  MyUser _userFromJwt(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length < 2) return MyUser(id: '', email: '', name: 'Google User', rating: 1200);

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      
      return MyUser(
        id: json['sub']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Google User',
        rating: 1200, // Default for new users
      );
    } catch (_) {
      return MyUser(id: '', email: '', name: 'Google User', rating: 1200);
    }
  }

  Future<List<dynamic>?> getLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateFcmToken(String token) async {
    if (_token == null) return;
    try {
      await http.patch(
        Uri.parse('$baseUrl/me/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'fcmToken': token}),
      );
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }

  Future<String?> fetchAnalysis(String gameId, int guessIndex) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('${AppEnv.backendBaseUrl}/game/$gameId/analyze/$guessIndex'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['analysis'] as String?;
      }
    } catch (e) {
      debugPrint('Failed to fetch analysis: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchGameDetails(String gameId) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('${AppEnv.backendBaseUrl}/game/$gameId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to fetch game details: $e');
    }
    return null;
  }
}
