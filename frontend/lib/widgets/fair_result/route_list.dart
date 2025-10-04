import 'package:flutter/material.dart';
import '../../models/fair_location_route_detail.dart';
import 'package:fair_front/services/open_naver_map_service.dart';

// FairLocationRouteDetail에서 출발지·경로 정보를 받아 텍스트로 보여 줌
// onTap 시 네이버 웹 라우팅 호출
class RouteListItem extends StatelessWidget {
  final FairLocationRouteDetail detail;
  final String centerName;
  final double centerLat; // 도착지(중심역) 위도
  final double centerLng; // 도착지(중심역) 경도

  const RouteListItem({
    Key? key,
    required this.detail,
    required this.centerName,
    required this.centerLat,
    required this.centerLng,
  }) : super(key: key);

  String _formatFare(int fare) {
    return fare.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = detail.fromStation;
    final route = detail.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // 터치 시 네이버 웹으로 라우팅 정보 전달
          openNaverWebRoute(
            sName: start.name,
            sLat: start.latitude,
            sLng: start.longitude,
            dName: centerName,
            dLat: centerLat,
            dLng: centerLng,
          );
        },
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 출발지 아이콘 + 이름
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_subway, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    start.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 총 소요 시간
              Text(
                '총 ${route.totalTime}분',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // 환승 횟수 | 도보 시간 | 요금
              Row(
                children: [
                  Text(
                    '환승 ${route.totalTransitCount}회',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '|',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  Text(
                    '도보 ${route.totalWalkTime}분',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '|',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  Text(
                    '${_formatFare(route.payment)}원',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
