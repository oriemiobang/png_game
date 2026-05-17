import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:png_game/models/my_user.dart';
import 'package:flutter/material.dart';

class AuthApiService extends ChangeNotifier {
  final String baseUrl = 'http://127.0.0.1:3000/auth';
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  MyUser? _user;
  String? _token;

  MyUser? get user => _user;
  String? get token => _token;

  AuthApiService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _token = await _storage.read(key: 'jwt_token');
    final userId = await _storage.read(key: 'user_id');
    final userEmail = await _storage.read(key: 'user_email');
    final userName = await _storage.read(key: 'user_name');

    if (_token != null && userId != null) {
      _user = MyUser(uid: userId, email: userEmail, name: userName);
      notifyListeners();
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    _token = data['access_token'];
    final userData = data['user'];
    
    await _storage.write(key: 'jwt_token', value: _token);
    await _storage.write(key: 'user_id', value: userData['id']);
    await _storage.write(key: 'user_email', value: userData['email']);
    await _storage.write(key: 'user_name', value: userData['name']);

    _user = MyUser(uid: userData['id'], email: userData['email'], name: userData['name']);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    await _googleSignIn.signOut();
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<dynamic> registerWithEmailAndPassword({required String email, required String password, required String name}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveSession(data);
        return _user;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Failed to register';
      }
    } catch (e) {
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
        final data = jsonDecode(response.body);
        await _saveSession(data);
        return _user;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Failed to sign in';
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) return 'Failed to get Google ID token';

      final response = await http.post(
        Uri.parse('$baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveSession(data);
        return _user;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Failed to authenticate with Google on server';
      }
    } catch (e) {
      return null;
    }
  }
}
