import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> requestFairLocation(List<Map<String, double>> startPoints) async {
  const url = 'http://localhost:8088/api/fair-location'; // 실제 IP 또는 도메인으로 변경 필요

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'startPoints': startPoints,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data; // 중간지점 응답 데이터 반환
    } else {
      print('서버 오류: ${response.statusCode}');
    }
  } catch (e) {
    print('요청 실패: $e');
  }

  return null;
}
