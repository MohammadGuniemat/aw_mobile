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

  Future<void> getUserInfo() async {
    if (_token != null) {
      _username = ExtractToken.extractUsername(_token!);
      _role = ExtractToken.extractRole(_token!);
      _userID = ExtractToken.extractUserID(_token!);
      notifyListeners();
    }
  }
}
