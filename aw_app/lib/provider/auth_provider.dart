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
  int? _userID;
  bool _is_loading = false;

  String? get token => _token;
  String? get username => _username;
  String? get role => _role;
  String? get profilePictureURL => _profilePictureURL;
  int? get userID => _userID;
  bool get isLoggedIn => _token != null;
  bool get is_loading => _is_loading;

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

  Future<void> updateUsername(String newUsername) async {
    final response = await Api.put.updateUserInfo(_token!, userID!, {
      'userName': newUsername,
    });
    notifyListeners();
  }

  Future<void> resetPassword(String newPassword) async {
    // Implement password reset logic here
    // This is a placeholder function
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
