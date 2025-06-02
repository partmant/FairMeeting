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
            // 1) API 호출
            result = await FairMeetingService.requestFairLocation(startPoints);
            if (result == null || result.midpointStation == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('중간 지점을 찾을 수 없습니다.')),
              );
              return;
            }

            // 2) MapController에 저장
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
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('오류 발생: $e')),
            );
            return;
          } finally {
            // 반드시 스피너 닫기
            hideLoadingDialog(context);
          }

          // 3) 화면 전환: 로딩 종료 후 수행
          final mid = result!.midpointStation!;
          final midLatLng = LatLng(mid.latitude, mid.longitude);
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
    );
  }
}
