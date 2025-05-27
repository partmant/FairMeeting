import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/odsay_route_response.dart';
import '../services/api_config.dart';

class OdsayRouteService {
  static Future<List<OdsayRouteResponse>> requestRoutesToMidpoint({
    required double mx,
    required double my,
    required List<Map<String, double>> startPoints,
  }) async {
    // URL 생성
    final queryParams = {
      'mx': mx.toString(),
      'my': my.toString(),
      for (var point in startPoints) ...{
        'sx': point['longitude'].toString(),
        'sy': point['latitude'].toString(),
      },
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/odsay/routes')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((e) => OdsayRouteResponse.fromJson(e)).toList();
      } else {
        throw Exception("ODsay 경로 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print('ODsay 요청 실패: $e');
      return [];
    }
  }
}
