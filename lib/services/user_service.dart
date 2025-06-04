import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fair_front/models/user_dto.dart';
import 'package:fair_front/services/api_config.dart';

class UserService {
  // 서버에 사용자 정보 등록 : 햣성공 시 HTTP 200 또는 201 반환, 그 외는 예외 발생
  static Future<void> registerUser(UserDto user) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/users');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('회원 등록 실패: ${response.statusCode}(${response.body})');
    }
  }
}
