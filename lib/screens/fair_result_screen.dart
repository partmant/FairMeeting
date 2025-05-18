import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../controllers/map_controller.dart';
import '../models/place_autocomplete_response.dart';

class FairResultMapScreen extends StatefulWidget {
  final List<LatLng> coordinates;
  final LatLng center;

  const FairResultMapScreen({
    super.key,
    required this.coordinates,
    required this.center,
  });

  @override
  State<FairResultMapScreen> createState() => _FairResultMapScreenState();
}

class _FairResultMapScreenState extends State<FairResultMapScreen> {
  late MapController controller;

  @override
  void initState() {
    super.initState();
    controller = MapController(); // 새 인스턴스 생성 or Provider 사용
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공정한 만남 위치')),
      body: KakaoMap(
        option: KakaoMapOption(
          position: widget.center,
          zoomLevel: 17,
        ),
        onMapReady: (mapCtrl) async {
          // MapController 내부에 controller 저장
          await controller.onMapCreated(mapCtrl);

          // 기존 POI 초기화
          await controller.clearAll();

          // 전달받은 좌표들로 POI 추가
          for (final coord in widget.coordinates) {
            await controller.addLocation(
              PlaceAutoCompleteResponse(
                placeName: "중간지점",
                roadAddress: "",
                latitude: coord.latitude,
                longitude: coord.longitude,
              ),
            );
          }
        },
      ),
    );
  }
}
