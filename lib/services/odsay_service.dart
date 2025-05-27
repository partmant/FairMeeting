import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../models/odsay_route_response.dart';
import '../models/location_dto.dart';
import '../models/fair_location_response.dart';
import '../models/fair_location_route_detail.dart';
import '../services/api_config.dart';

class OdsayRouteService {
  /// 중간지점까지 여러 출발지의 경로 요청
  static Future<List<OdsayRouteResponse>> requestRoutesToMidpoint({
    required double mx,
    required double my,
    required List<LocationDto> startStations,
  }) async {
    debugPrint('🔍 [Odsay] requestRoutesToMidpoint 호출');
    debugPrint('    midpoint: ($mx, $my)');
    debugPrint('    startStations: $startStations');

    // 쿼리스트링 직접 조립
    final sb = StringBuffer('mx=$mx&my=$my');
    for (var s in startStations) {
      sb.write('&sx=${s.longitude}&sy=${s.latitude}');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/odsay/routes?$sb');
    debugPrint('    URI: $uri');

    final response = await http.get(uri);
    debugPrint('✅ [Odsay] HTTP 상태 코드: ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('❌ [Odsay] 비정상 상태 코드');
      throw Exception('ODsay 경로 요청 실패: ${response.statusCode}');
    }

    final body = utf8.decode(response.bodyBytes);
    debugPrint('📨 [Odsay] 응답 바디: $body');

    final List<dynamic> list = jsonDecode(body);
    return list.map((e) => OdsayRouteResponse.fromJson(e)).toList();
  }

  /// 중간지점 수정 후 최종 FairLocationResponse 생성
  static Future<FairLocationResponse?> requestFairLocationFromOdsay({
    required LatLng midpoint,
    required List<LocationDto> startStations,
  }) async {
    debugPrint('🔍 [Odsay] requestFairLocationFromOdsay 호출');
    debugPrint('    midpoint: (${midpoint.latitude}, ${midpoint.longitude})');
    debugPrint('    startStations: $startStations');

    final routes = await requestRoutesToMidpoint(
      mx: midpoint.longitude,
      my: midpoint.latitude,
      startStations: startStations,
    );

    debugPrint('👣 [Odsay] 받아온 routes 개수: ${routes.length}');
    if (routes.length != startStations.length) {
      debugPrint(
          '⚠️ [Odsay] routes 길이 불일치: ${routes.length} vs ${startStations.length}');
      return null;
    }

    final details = List<FairLocationRouteDetail>.generate(
      startStations.length,
          (i) => FairLocationRouteDetail(
        fromStation: startStations[i],
        route: routes[i],
      ),
    );

    final midStation = LocationDto(
      latitude: midpoint.latitude,
      longitude: midpoint.longitude,
      name: '중간지점',
    );

    debugPrint('✅ [Odsay] FairLocationResponse 생성 완료');
    return FairLocationResponse(
      midpointStation: midStation,
      routes: details,
    );
  }
}
