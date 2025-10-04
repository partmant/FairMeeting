import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/controllers/map_controller.dart';
import 'package:fair_front/services/fair_meeting_service.dart';
import 'package:fair_front/models/fair_location_response.dart';
import 'package:fair_front/providers/fair_result_provider.dart';
import '../../screens/fair_result_screen.dart';
import '../loading_dialog.dart';

class FairMeetingButton extends StatelessWidget {
  const FairMeetingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        child: OutlinedButton(
          onPressed: () async {
            final sel = mapController.selectedAddresses;
            if (sel.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('최소 2개의 출발 위치가 필요합니다.')),
              );
              return;
            }

            showLoadingDialog(context);
            FairLocationResponse? result;
            final startPoints = sel
                .map((a) => {
              'name': a.placeName,
              'latitude': a.latitude,
              'longitude': a.longitude,
            })
                .toList();

            try {
              result = await FairMeetingService.requestFairLocation(startPoints);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('출발지를 다시 설정해 주세요.'),
                  duration: Duration(seconds: 3),
                ),
              );
              hideLoadingDialog(context);
              return;
            }

            // 예외가 발생하지 않은 경우에만 result 검사
            if (result == null || result.midpointStation == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('출발지를 다시 설정해 주세요.'),
                  duration: Duration(seconds: 3),
                ),
              );
              hideLoadingDialog(context);
              return;
            }

            // 결과 저장 및 화면 전환
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
            context.read<FairResultProvider>().updateResponse(result);

            hideLoadingDialog(context);

            Navigator.of(context).push(
              PageRouteBuilder(
                settings: const RouteSettings(name: '/fair-result'),
                pageBuilder: (_, __, ___) => FairResultMapScreen(
                  initialCenter: midLatLng,
                  initialResponse: result!,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD9C189), width: 2),
            foregroundColor: const Color(0xFFD9C189),
            padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
