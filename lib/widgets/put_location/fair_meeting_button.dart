import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:provider/provider.dart';
import 'package:fair_front/controllers/map_controller.dart';
import 'package:fair_front/services/fair_meeting_service.dart';
import 'package:fair_front/screens/fair_result_screen.dart';
import 'package:fair_front/widgets/loading_dialog.dart';

class FairMeetingButton extends StatelessWidget {
  const FairMeetingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: OutlinedButton(
        onPressed: () async {
          final selectedAddresses = mapController.selectedAddresses;
          if (selectedAddresses.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('최소 2개의 출발 위치가 필요합니다.')),
            );
            return;
          }

          final startPoints = selectedAddresses.map((addr) => {
            'latitude': addr.latitude,
            'longitude': addr.longitude,
          }).toList();

          // 로딩 스피너 표시 및 화면 인터랙션 차단
          showLoadingDialog(context);
          try {
            final result = await FairMeetingService.requestFairLocation(startPoints);
            hideLoadingDialog(context);

            final midpoint = result?.midpointStation;
            if (midpoint != null) {
              final midpointLatLng = LatLng(midpoint.latitude, midpoint.longitude);
              final startLatLngs = selectedAddresses
                  .map((addr) => LatLng(addr.latitude, addr.longitude))
                  .toList();
              final allCoordinates = [...startLatLngs, midpointLatLng];

              // 마지막 결과 저장
              mapController.saveLastResult(
                coordinates: allCoordinates,
                center:      midpointLatLng,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/fair-result'),
                  builder: (_) => FairResultMapScreen(
                    coordinates: allCoordinates,
                    center:      midpointLatLng,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('중간 지점을 찾을 수 없습니다.')),
              );
            }
          } catch (e) {
            hideLoadingDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('요청 중 오류 발생: $e')),
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