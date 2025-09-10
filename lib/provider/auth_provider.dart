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
    if (_profilePictureURL != null) {
      newInfo['profilePictureURL'] = _profilePictureURL;
    }
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
        refreshSingleUserInfo();
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

  Future<void> refreshSingleUserInfo() async {
    _is_loading = true;
    try {
      final response = await Api.get.getSingleUserInfo(_token!, _userID!);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //  [{user_id: 1047, userName: new, role: user      , account_status: true, profilePictureURL: http://192.168.43.73:3003/uploads/e6ff5856e8c32e193bcbda95db90deff}]
        final user = data[0];

        _username = user['userName'];
        _role = user['role'];
        print(user['profilePictureURL']);
        _profilePictureURL = user['profilePictureURL'];
        savProfilePicture(user['profilePictureURL']);
        print("refresh ended successfully ");
        notifyListeners();
      } else {
        print("error refresh user info");
      }
    } catch (e) {
      print("Exception while refresh user info: $e");
    }
    _is_loading = false;
  }

  Future<void> uploadProfilePicture(
    String path,
    int userId,
    String token,
  ) async {
    try {
      final response = await Api.put.uploadProfilePicture(path, userId, token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // setUserinfo({'profilePictureURL': data['profilePictureURL']});
        savProfilePicture(data['profilePictureURL']);
        _profilePictureURL = data['profilePictureURL'];
        notifyListeners();
      } else {
        print(
          "error uploading profile picture: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      print("Exception while uploading profile picture: $e");
    }
  }

  /// Returns the token expiration date, or null if token is missing/invalid
  DateTime? get tokenExpiryDate {
    if (_token == null) return null;

    try {
      // JWT structure: header.payload.signature
      final parts = _token!.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);

      if (map.containsKey('exp')) {
        final exp = map['exp'];
        // JWT exp is in seconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
    } catch (e) {
      print("Error decoding token: $e");
    }

    return null;
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _role = null;
    _profilePictureURL = null;
    _authStatus = null;
    _userID = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }
}
