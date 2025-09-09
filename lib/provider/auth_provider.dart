import 'dart:convert';
import 'dart:ffi';

import 'package:aw_app/utils/extract_token.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/server/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _username;
  String? _role;
  String? _profilePictureURL;
  String? _authStatus;
  int? _userID;
  bool _is_loading = false;

  String? get token => _token;
  String? get username => _username;
  String? get role => _role;
  String? get profilePictureURL => _profilePictureURL;
  String? get authStatus => _authStatus;
  int? get userID => _userID;
  bool get isLoggedIn => _token != null;
  bool get is_loading => _is_loading;

  set authStatus(String? newStatus) {
    _authStatus = newStatus;
    notifyListeners(); // if you're using ChangeNotifier
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      _username = ExtractToken.extractUsername(_token!);
      _role = ExtractToken.extractRole(_token!);
      _userID = ExtractToken.extractUserID(_token!);
    }
    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    _username = ExtractToken.extractUsername(token);
    _role = ExtractToken.extractRole(token);
    _userID = ExtractToken.extractUserID(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    print('token: $token');
    notifyListeners();
  }

  Future<void> savProfilePicture(String imgUrl) async {
    if (imgUrl != null) {
      _profilePictureURL = imgUrl;
    } else {
      _profilePictureURL =
          'https://aw.jo/web/assets/uploads/media-uploader/aw21661878799.png';
    }

    notifyListeners();
  }

  Future<void> setUserinfo(Map<String, dynamic> newInfo) async {
    print('newInfo: $newInfo');
    _is_loading = true;
    _authStatus = "⏳ Waiting for your actions ...";
    notifyListeners();

    if (_token == null || userID == null) {
      _authStatus = "❌ Cannot update username: missing token or userID";
      _is_loading = false;
      notifyListeners();
      return;
    }

    _authStatus = "🔄 Attempting to update username to: ${newInfo['userName']}";
    notifyListeners();

    try {
      final response = await Api.put.updateUserInfo(_token!, userID!, newInfo);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _username = newInfo['userName'];
        _authStatus = "✅ ${data['message'] ?? 'Username updated successfully'}";
      } else {
        _authStatus =
            "❌ Failed to update username: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      _authStatus = "❌ Exception while updating username: $e";
    }

    _is_loading = false;
    notifyListeners();
  }

  Future<void> getUserInfo() async {
    _is_loading = true;
    if (_token != null) {
      _username = ExtractToken.extractUsername(_token!);
      _role = ExtractToken.extractRole(_token!);
      _userID = ExtractToken.extractUserID(_token!);
      _is_loading = false;

      notifyListeners();
    }
  }
}
