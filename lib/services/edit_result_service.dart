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
    required List<LocationDto> startStations, // [0]=출발지, [1]=원래 목적지
  }) async {
    debugPrint('🔍 [EditResultService] fetchEditResult 호출');

    // startStations[0] → 출발 지점(LocationDto)
    // startStations[1] → 원래 도착 지점(LocationDto)
    final start = startStations[0];
    final dest = startStations[1];
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/edit/result').replace(
      queryParameters: {
        'mx': mx.toString(),
        'my': my.toString(),
        'sx': start.longitude.toString(), // 출발지 경도
        'sy': start.latitude.toString(), // 출발지 위도
        'dx': dest.longitude.toString(), // 도착지 경도
        'dy': dest.latitude.toString(), // 도착지 위도
      },
    );
    debugPrint('    URI: $uri'); // 최종 예시:
    // …/api/edit/result?mx=126.90719550713634&my=37.525453306659784
    // &sx=126.823828819915&sy=37.4923999909922
    // &dx=126.97209238331357&dy=37.55597933890212

    final response = await http.get(uri);
    debugPrint('✅ [EditResultService] HTTP 상태 코드: ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('❌ [EditResultService] 비정상 상태 코드');
      throw Exception('EditResult 요청 실패: ${response.statusCode}');
    }

    final body = utf8.decode(response.bodyBytes);
    debugPrint('📨 [EditResultService] 응답 바디: $body');

    try {
      final Map<String, dynamic> jsonMap = json.decode(body);
      return EditResultResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint('❌ [EditResultService] 파싱 오류: $e');
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

    // 파싱된 결과에서 FairLocationResponse 생성
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

    debugPrint('✅ [EditResultService] FairLocationResponse 생성 완료');
    return FairLocationResponse(midpointStation: midStation, routes: details);
  }
}
