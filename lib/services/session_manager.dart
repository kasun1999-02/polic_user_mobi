import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _userDataKey = 'userData';
  static const _tokenKey = 'token';

  // Save user data as JSON string
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user));
    await prefs.setString(_tokenKey, user['token']);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear user data (for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_tokenKey);
  }
}
