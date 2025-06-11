import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fair_front/services/api_config.dart';
import 'package:fair_front/models/appointment_dto.dart';
import 'package:fair_front/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment_create_response.dart';

class AppointmentService {
  /// 해당 kakaoId 의 약속 목록 가져옴
  static Future<List<AppointmentDto>> getAppointments(String kakaoId) async {
    final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/appointments?kakaoId=$kakaoId');
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

  /// 새로운 약속을 생성
  static Future<void> createAppointment({
    required String kakaoId,
    required String date, // "yyyy-MM-dd"
    required String time, // "HH:mm"
    required String location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final basicEnabled = prefs.getBool('basicNotificationsEnabled') ?? false;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'kakaoId': kakaoId,
        'date': date,
        'time': time,
        'location': location
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

    // 생성된 약속 ID 파싱
    final bodyString = utf8.decode(res.bodyBytes);
    final data = jsonDecode(bodyString) as Map<String, dynamic>;
    final newId = data['id'] as int;
    final eventDt = DateTime.parse('$date $time');

    if (basicEnabled) {
      // 하루 전 알림 예약
      NotificationService().scheduleDailyBefore(
        id: newId,
        title: '약속 리마인더',
        body: location,
        eventDateTime: eventDt,
      );
      // 즉시 알림: 알림 예약 시점을 알려주는 메시지
      NotificationService().showImmediateNotification(
        id: newId + 200000,
        title: '알림이 예약되었습니다',
        body: '$date $time - $location',
      );
    }
  }

  /// 약속 수정
  static Future<void> updateAppointment({
    required int id,
    required String kakaoId,
    required String date,
    required String time,
    required String location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final basicEnabled = prefs.getBool('basicNotificationsEnabled') ?? false;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/appointments/$id');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'kakaoId': kakaoId,
        'date': date,
        'time': time,
        'location': location
      }),
    );
    if (res.statusCode == 409 || res.statusCode == 404) throw Exception(
        utf8.decode(res.bodyBytes));
    if (res.statusCode != 200) throw Exception('약속 수정 실패: ${res.statusCode}');

    if (basicEnabled) {
      // 기존 알림 취소 및 재예약
      await NotificationService().cancelNotification(id);
      final eventDt = DateTime.parse('$date $time');
      await NotificationService().scheduleDailyBefore(
        id: id,
        title: '약속 리마인더',
        body: location,
        eventDateTime: eventDt,
      );
      // 즉시 알림: 알림 수정 시점을 알려주는 메시지
      await NotificationService().showImmediateNotification(
        id: id + 200000,
        title: '알림이 수정되었습니다',
        body: '$date $time - $location',
      );
    }
  }

  /// 약속 삭제
  static Future<void> deleteAppointment({
    required int id,
    required String kakaoId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final basicEnabled = prefs.getBool('basicNotificationsEnabled') ?? false;

    final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/appointments/$id?kakaoId=$kakaoId');
    final res = await http.delete(uri);
    if (res.statusCode == 404 || res.statusCode == 403) throw Exception(
        utf8.decode(res.bodyBytes));
    if (res.statusCode != 200) throw Exception('약속 삭제 실패: ${res.statusCode}');

    if (basicEnabled) {
      // 알림 취소
      await NotificationService().cancelNotification(id);
      // 즉시 알림: 알림 취소 사실을 알려주는 메시지
      await NotificationService().showImmediateNotification(
        id: id + 200000,
        title: '알림이 삭제되었습니다',
        body: '' ,
      );
    }
  }
}

