import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/controllers/map_controller.dart';
import 'package:fair_front/services/fair_meeting_service.dart';
import 'package:fair_front/models/fair_location_response.dart';

import '../../screens/fair_result_screen.dart';

class FairMeetingButton extends StatelessWidget {
  const FairMeetingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: OutlinedButton(
        onPressed: () async {
          final sel = mapController.selectedAddresses;
          if (sel.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('최소 2개의 출발 위치가 필요합니다.')),
            );
            return;
          }

          final startPoints =
              sel
                  .map(
                    (a) => {'latitude': a.latitude, 'longitude': a.longitude},
                  )
                  .toList();

          // 1) API 호출 (await)
          final FairLocationResponse? result =
              await FairMeetingService.requestFairLocation(startPoints);

          if (result == null || result.midpointStation == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('중간 지점을 찾을 수 없습니다.')));
            return;
          }

          final mid = result.midpointStation!;
          final midLatLng = LatLng(mid.latitude, mid.longitude);
          final allCoords = [
            ...sel.map((a) => LatLng(a.latitude, a.longitude)),
            midLatLng,
          ];

          mapController.saveLastResult(
            coordinates: allCoords,
            center: midLatLng,
            response: result,
          );

          // 2) pushReplacement (결과 화면은 내부 스피너로 로딩)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/fair-result'),
              builder:
                  (_) => FairResultMapScreen(
                    center: midLatLng,
                    fairLocationResponse: result,
                  ),
            ),
          );
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
            child: Text('Fair Meeting !', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
