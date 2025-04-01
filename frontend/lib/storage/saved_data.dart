import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedData {
  Future<void> setUserId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? "";
  }

  Future<void> setGameId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gameId', id);
  }

  Future<String> getSaveGameId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('gameId') ?? "";
  }

  Future<void> setData(data) async {
    String jsonString = jsonEncode(data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonString);
  }

  Future<Map> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String jsonString = prefs.getString('data') ?? '{}';
    return jsonDecode(jsonString);
  }
}
