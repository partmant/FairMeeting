import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fair_front/services/api_config.dart';
import 'package:fair_front/models/appointment_dto.dart';

class AppointmentService {
  // 해당 kakaoId 의 약속 목록 가져옴
  static Future<List<AppointmentDto>> getAppointments(String kakaoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments?kakaoId=$kakaoId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('약속 조회 실패: ${res.statusCode}');
    }
    final jsonString = utf8.decode(res.bodyBytes);
    final List data = jsonDecode(jsonString) as List;
    return data
        .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 새로운 약속을 생성
  static Future<void> createAppointment({
    required String kakaoId,
    required String date, // "yyyy-MM-dd"
    required String time, // "HH:mm"
    required String location,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'kakaoId': kakaoId,
        'date': date,
        'time': time,
        'location': location,
      }),
    );

    if (res.statusCode == 409) {
      final msg = utf8.decode(res.bodyBytes);
      throw Exception(msg);
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      final msg = utf8.decode(res.bodyBytes);
      throw Exception('약속 저장 실패: ${res.statusCode} $msg');
    }
  }

  // 약속 수정
  static Future<void> updateAppointment({
    required int id,
    required String kakaoId,
    required String date,
    required String time,
    required String location,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments/$id');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'kakaoId': kakaoId,
        'date': date,
        'time': time,
        'location': location,
      }),
    );
    if (res.statusCode == 409 || res.statusCode == 404) {
      throw Exception(utf8.decode(res.bodyBytes));
    }
    if (res.statusCode != 200) {
      throw Exception('약속 수정 실패: ${res.statusCode}');
    }
  }

  // 약속 삭제
  static Future<void> deleteAppointment({
    required int id,
    required String kakaoId,
  }) async {
    final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/appointments/${id.toString()}?kakaoId=$kakaoId'
    );
    final res = await http.delete(uri);
    if (res.statusCode == 404 || res.statusCode == 403) {
      throw Exception(utf8.decode(res.bodyBytes));
    }
    if (res.statusCode != 200) {
      throw Exception('약속 삭제 실패: ${res.statusCode}');
    }
  }
}