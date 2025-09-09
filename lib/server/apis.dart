import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';

class Api {
  static const String baseUrl = 'http://192.168.43.73:3003/api/';
  static const String loginEndpoint = 'login';
  static const String usersInfoEndpoint = 'usersInfo';
  static const String usersInfoUpdateEndpoint = 'users';
  // http://10.10.15.21:3003/api/users/1045

  static final post = _Post();
  static final get = _Get();
  static final put = _Put();
}

class _Post {
  Future<http.Response> login(String username, String password) async {
    final url = Uri.parse('${Api.baseUrl}${Api.loginEndpoint}');
    print(url);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    print(response);
    return response;
  }
}

class _Get {
  Future<http.Response> usersInfo() async {
    final url = Uri.parse('${Api.baseUrl}${Api.usersInfoEndpoint}');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  // git single user info

  Future<http.Response> getSingleUserInfo(String token, int userId) async {
    final url = Uri.parse('${Api.baseUrl}userInfo/$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint(response.body); // raw

    return response;
  }

  // GET SPECIFIC USER TASKS -ALL OF THEM

  Future<http.Response> userTasks(String token, int userId) async {
    final url = Uri.parse('${Api.baseUrl}tasks/$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint(response.body); // raw

    return response;
  }
}

class _Put {
  Future<http.Response> updateUserInfo(
    String token,
    int userId,
    Map<String, dynamic> updatedData,
  ) async {
    final url = Uri.parse(
      '${Api.baseUrl}${Api.usersInfoUpdateEndpoint}/$userId',
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData), // send updated fields
    );
    print(response.body);

    await Future.delayed(Duration(seconds: 3));
    return response;
  }

  Future<http.Response> uploadProfilePicture(
    String filePath,
    int userId,
    String token,
  ) async {
    final url = Uri.parse('${Api.baseUrl}upload-profile-picture/$userId');
    print("🌐 Upload URL: $url");

    try {
      // Build multipart request
      var request = http.MultipartRequest("POST", url);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // Don't set Content-Type manually
      });

      // Attach file (ensure you pass correct mime type)
      final file = await http.MultipartFile.fromPath(
        "profilePicture",
        filePath,
        contentType: MediaType("image", "jpeg"), // adjust if PNG, etc.
      );
      request.files.add(file);

      // Send request
      print("🚀 Sending request with file: $filePath");
      var streamedResponse = await request.send();

      // Convert to Response for easier handling
      var response = await http.Response.fromStream(streamedResponse);

      print("📩 Response status: ${response.statusCode}");
      print("📜 Response body: ${response.body}");
    // await Future.delayed(Duration(seconds: 10));
      return response;
    } catch (e) {
      print("❌ Error creating multipart request: $e");
      rethrow;
    }
  }
}

// router.get('/tasks/:userId',authenticateToken, getController.get_task);
