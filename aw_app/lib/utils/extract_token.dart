import 'dart:convert';

abstract class ExtractToken {
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded);

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  static String extractUsername(String token) {
    final payload = parseJwt(token);
    print(payload['username']);
    return payload['username'] ?? 'Unknown UserName';
  }

  static String extractRole(String token) {
    final payload = parseJwt(token);
    print(payload['role']);
    return payload['role'] ?? 'Unknown Role';
  }

  static int extractUserID(String token) {
    final payload = parseJwt(token);
    print(payload['id']);
    return payload['id'] ?? 0;
  }

  // static String extractProfileImgUrl(String token) {
  //   final payload = parseJwt(token);
  //   print(payload['profilePictureURL']);
  //   return payload['profilePictureURL'] ?? 'profilePictureURL Role';
  // }
}
