import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fair_front/services/api_config.dart';
import 'package:fair_front/models/appointment_dto.dart';
import 'package:fair_front/services/notification_service.dart';

class AppointmentService {
  /// 해당 kakaoId 의 약속 목록 가져옴
  static Future<List<AppointmentDto>> getAppointments(String kakaoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments?kakaoId=$kakaoId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('약속 조회 실패: ${res.statusCode}');
    }
    final jsonString = utf8.decode(res.bodyBytes);
    final List data = jsonDecode(jsonString) as List;
    return data.map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 새로운 약속을 생성
  /// 응답 바디에 생성된 id를 포함한다고 가정
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
      body: jsonEncode({'kakaoId': kakaoId, 'date': date, 'time': time, 'location': location}),
    );

    if (res.statusCode == 409) {
      final msg = utf8.decode(res.bodyBytes);
      throw Exception(msg);
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      final msg = utf8.decode(res.bodyBytes);
      throw Exception('약속 저장 실패: ${res.statusCode} $msg');
    }

    // 서버에서 생성된 ID 파싱
    final responseBody = utf8.decode(res.bodyBytes);
    final Map<String, dynamic> created = jsonDecode(responseBody);
    final int newId = created['id'] as int;
    final eventDt = DateTime.parse('$date $time');

    // 하루 전 알림 예약
    await NotificationService().scheduleDailyBefore(
      id: newId,
      title: '약속 리마인더',
      body: location,
      eventDateTime: eventDt,
    );

    // 즉시 알림
    await NotificationService().showImmediateNotification(
      id: newId + 200000,
      title: '약속이 등록되었습니다',
      body: '$date $time - $location',
    );
  }

  /// 약속 수정
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
      body: jsonEncode({'kakaoId': kakaoId, 'date': date, 'time': time, 'location': location}),
    );
    if (res.statusCode == 409 || res.statusCode == 404) throw Exception(utf8.decode(res.bodyBytes));
    if (res.statusCode != 200) throw Exception('약속 수정 실패: ${res.statusCode}');

    // 기존 알림 취소 후 재예약
    await NotificationService().cancelNotification(id);
    final eventDt = DateTime.parse('$date $time');
    await NotificationService().scheduleDailyBefore(
      id: id,
      title: '약속 리마인더',
      body: location,
      eventDateTime: eventDt,
    );

    // 즉시 알림
    await NotificationService().showImmediateNotification(
      id: id + 200000,
      title: '약속이 수정되었습니다',
      body: '$date $time - $location',
    );
  }

  /// 약속 삭제
  static Future<void> deleteAppointment({
    required int id,
    required String kakaoId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments/$id?kakaoId=$kakaoId');
    final res = await http.delete(uri);
    if (res.statusCode == 404 || res.statusCode == 403) throw Exception(utf8.decode(res.bodyBytes));
    if (res.statusCode != 200) throw Exception('약속 삭제 실패: ${res.statusCode}');

    // 알림 취소
    await NotificationService().cancelNotification(id);

    // 즉시 알림
    await NotificationService().showImmediateNotification(
      id: id + 200000,
      title: '약속이 삭제되었습니다',
      body: 'ID: $id',
    );
  }
}
