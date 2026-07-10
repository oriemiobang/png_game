import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

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
      debugPrint('[GoogleSignIn] Starting sign-in flow...');

      // Sign out first so the account picker always shows
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[GoogleSignIn] Cancelled by user.');
        return 'Google sign-in was cancelled.';
      }
      debugPrint('[GoogleSignIn] Got account: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      debugPrint('[GoogleSignIn] accessToken=${accessToken != null ? "OK" : "NULL"}');

      if (accessToken == null) {
        return 'Failed to get Google access token. Please try again.';
      }

      debugPrint('[GoogleSignIn] Sending accessToken to backend: $baseUrl/google/token');
      final response = await http.post(
        Uri.parse('$baseUrl/google/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );
      debugPrint('[GoogleSignIn] Backend response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _saveSession(data);
        return _user;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return error['message'] ?? 'Failed to authenticate with Google on server';
    } catch (e, st) {
      debugPrint('[GoogleSignIn] EXCEPTION: $e');
      debugPrint('[GoogleSignIn] StackTrace: $st');
      return 'Google Sign-In error: $e';
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
