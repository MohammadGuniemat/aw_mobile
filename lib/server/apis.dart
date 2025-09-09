import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';

class Api {
  static const String baseUrl = 'http://10.10.15.21:3003/api/';
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

  Future<void> uploadProfilePicture(
    String filePath,
    int userId,
    String token,
  ) async {
    print("📂 File path: $filePath");

    final url = Uri.parse('${Api.baseUrl}upload-profile-picture/$userId');
    print("🌐 URL: $url");

    try {
      // Build multipart request
      var request = http.MultipartRequest("POST", url);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // DO NOT set Content-Type manually for Multipart
      });
      print("📝 Headers: ${request.headers}");

      // Attach file
      final file = await http.MultipartFile.fromPath(
        "profilePicture",
        filePath,
        contentType: MediaType("image", "jpeg"), // for .jpg/.jpeg
      );
      request.files.add(file);
      print("📦 File attached: ${file.filename}, length: ${file.length}");

      // Debug: print all files in request
      for (var f in request.files) {
        print("➡️ File in request: field=${f.field}, filename=${f.filename}");
      }

      // Send request
      print("🚀 Sending request...");
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final respJson = jsonDecode(respStr);

      if (response.statusCode == 200) {
        print("✅ Upload success: $respStr");

        // Update user info on backend
        await updateUserInfo(token, userId, {
          'profilePictureURL': respJson['profilePictureURL'],
        });
      } else {
        print("❌ Upload failed: ${response.statusCode}, $respStr");
      }
    } catch (e, stack) {
      print("⚠️ Exception occurred: $e");
      print(stack);
    }
  }
}

// router.get('/tasks/:userId',authenticateToken, getController.get_task);
