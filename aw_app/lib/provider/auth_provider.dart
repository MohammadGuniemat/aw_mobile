import 'package:aw_app/utils/extract_token.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _username;
  String? _role;
  String? _profilePictureURL;
  int? _userID;

  String? get token => _token;
  String? get username => _username;
  String? get role => _role;
  String? get profilePictureURL => _profilePictureURL;
  int? get userID => _userID;
  bool get isLoggedIn => _token != null;

  // Load token from SharedPreferences
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      _username = ExtractToken.extractUsername(_token!);
      _role = ExtractToken.extractRole(_token!);
      _role = ExtractToken.extractProfileImgUrl(_token!);
      _userID = ExtractToken.extractUserID(_token!);
    }
    notifyListeners();
  }

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    _token = token;
    _username = ExtractToken.extractUsername(token);
    _role = ExtractToken.extractRole(_token!);
    _role = ExtractToken.extractProfileImgUrl(_profilePictureURL!);
    _userID = ExtractToken.extractUserID(_token!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('token: ${token.toString()}');
    notifyListeners();
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    _token = null;
    _username = null;
    _profilePictureURL = null;
    _userID = 0;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  // Manually refresh username from token
  Future<void> getUserInfo() async {
    if (_token != null) {
      _username = ExtractToken.extractUsername(_token!);
      _role = ExtractToken.extractRole(_token!);
      _role = ExtractToken.extractProfileImgUrl(_profilePictureURL!);
      _userID = ExtractToken.extractUserID(_token!);
      notifyListeners();
    }
  }
}
