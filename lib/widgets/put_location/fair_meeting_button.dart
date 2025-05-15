import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/location_controller.dart';
import 'package:fair_front/services/fair_meeting_service.dart';
import 'package:fair_front/screens/fair_result_screen.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // LatLng 사용을 위해 필요

class FairMeetingButton extends StatelessWidget {
  const FairMeetingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Provider.of<LocationController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: OutlinedButton(
        onPressed: () async {
          // 출발지 리스트 구성
          final startPoints = locationController.locations.map((loc) => {
            'latitude': loc.latitude,
            'longitude': loc.longitude,
          }).toList();

          if (startPoints.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('최소 2개의 출발 위치가 필요합니다.')),
            );
            return;
          }

          // 서버로 요청
          final result = await FairMeetingService.requestFairLocation(startPoints);

          if (result != null && result.midpointStation != null) {
            // 중간 지점 및 출발지 마커 좌표 리스트 구성
            final midpoint = result.midpointStation;
            final midpointLatLng = LatLng(midpoint.latitude, midpoint.longitude);

            final startLatLngs = locationController.locations
                .map((loc) => LatLng(loc.latitude, loc.longitude))
                .toList();

            final allCoordinates = [...startLatLngs, midpointLatLng];

            // 결과 화면 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FairResultMapScreen(
                  coordinates: allCoordinates,
                  center: midpointLatLng, // 중심 위치 지정
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('중간 지점을 찾을 수 없습니다.')),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD9C189), width: 2),
          foregroundColor: const Color(0xFFD9C189),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              'Fair Meeting !',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
