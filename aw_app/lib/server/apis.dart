import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  static const String baseUrl = 'http://10.10.15.21:3003/api/';
  static const String loginEndpoint = 'login';
  static const String usersInfoEndpoint = 'usersInfo';

  static final post = _Post();
  static final get = _Get();
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
}
