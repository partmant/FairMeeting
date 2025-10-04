import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../models/edit_result_response.dart';
import '../models/location_dto.dart';
import '../models/fair_location_response.dart';
import '../models/fair_location_route_detail.dart';
import '../services/api_config.dart';

// 수정된 중간지점 정보와 경로 정보를 요청
class EditResultService {
  static Future<EditResultResponse> fetchEditResult({
    required double mx,
    required double my,
    required List<LocationDto> startStations, // 모든 출발지 및 도착지 리스트
  }) async {
    debugPrint('🔍 [EditResultService] fetchEditResult 호출');

    // 모든 출발지 좌표를 queryParametersAll로 전달
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/edit/result').replace(
      queryParameters: {
        'mx': [mx.toString()],
        'my': [my.toString()],
        'sx': startStations.map((s) => s.longitude.toString()).toList(),
        'sy': startStations.map((s) => s.latitude.toString()).toList(),
      },
    );
    debugPrint('    URI: $uri');

    final response = await http.get(uri);
    debugPrint('[EditResultService] HTTP 상태 코드: ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('[EditResultService] 비정상 상태 코드');
      throw Exception('EditResult 요청 실패: ${response.statusCode}');
    }

    final body = utf8.decode(response.bodyBytes);
    debugPrint('📨 [EditResultService] 응답 바디: $body');

    try {
      final Map<String, dynamic> jsonMap = json.decode(body);
      return EditResultResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint('[EditResultService] 파싱 오류: $e');
      throw Exception('EditResult 응답 파싱 실패');
    }
  }

  // 중간지점을 업데이트한 후, FairLocationResponse 생성
  static Future<FairLocationResponse> requestFairLocationFromEditResult({
    required LatLng midpoint,
    required List<LocationDto> startStations,
  }) async {
    debugPrint('🔍 [EditResultService] requestFairLocationFromEditResult 호출');

    final EditResultResponse editResult = await fetchEditResult(
      mx: midpoint.longitude,
      my: midpoint.latitude,
      startStations: startStations,
    );

    final details = List<FairLocationRouteDetail>.generate(
      startStations.length,
          (i) => FairLocationRouteDetail(
        fromStation: startStations[i],
        route: editResult.routes[i],
      ),
    );

    final midStation = LocationDto(
      latitude: editResult.midpoint.latitude,
      longitude: editResult.midpoint.longitude,
      name: editResult.midpoint.name,
    );

    debugPrint('[EditResultService] FairLocationResponse 생성 완료');
    return FairLocationResponse(
      midpointStation: midStation,
      routes: details,
    );
  }
}
