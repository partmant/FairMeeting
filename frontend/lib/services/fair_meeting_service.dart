import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fair_location_response.dart';
import '../services/api_config.dart';

class FairMeetingService {
  static Future<FairLocationResponse?> requestFairLocation(List<Map<String, dynamic>> startPoints) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/fair_location');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'startPoints': startPoints}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return FairLocationResponse.fromJson(json);
      } else {
        throw Exception("공정 위치 계산 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('요청 실패: $e');
      return null;
    }
  }
}
