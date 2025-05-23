// lib/screens/fair_result_map_screen.dart

import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:fair_front/models/fair_location_response.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/result_bottom_sheet.dart';
import '../controllers/poi_controller.dart';
import '../controllers/map_controller.dart';
import '../screens/put_location_screen.dart';

class FairResultMapScreen extends StatefulWidget {
  final LatLng center;
  final FairLocationResponse fairLocationResponse;

  const FairResultMapScreen({
    Key? key,
    required this.center,
    required this.fairLocationResponse,
  }) : super(key: key);

  @override
  State<FairResultMapScreen> createState() => _FairResultMapScreenState();
}

class _FairResultMapScreenState extends State<FairResultMapScreen> {
  late final PoiController _poiController;
  late final MapController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // 결과 화면 전용 컨트롤러 인스턴스 생성
    _poiController = PoiController();
    _controller = MapController(poiController: _poiController);
  }

  Future<void> _onMapReady(KakaoMapController mapCtrl) async {
    // 1) POI 스타일만 초기화 (MapController.onMapCreated 호출하지 않음)
    await _poiController.initStyle(mapCtrl);

    // 2) 출발지점(fromStation) 마커 표시
    final origins = widget.fairLocationResponse.routes.map((detail) {
      final st = detail.fromStation;
      return PlaceAutoCompleteResponse(
        placeName: st.name,
        roadAddress: '',
        latitude: st.latitude,
        longitude: st.longitude,
      );
    }).toList();
    await _poiController.showMarkers(mapCtrl, origins);

    // 3) 중간지점(midpointStation) 마커 추가
    final mid = widget.fairLocationResponse.midpointStation;
    final allMarkers = [
      ...origins,
      PlaceAutoCompleteResponse(
        placeName: mid.name,
        roadAddress: '',
        latitude: mid.latitude,
        longitude: mid.longitude,
      ),
    ];
    await _poiController.showMarkers(mapCtrl, allMarkers);

    // 4) 결과 화면의 중심을 중간지점으로 강제 설정
    await mapCtrl.moveCamera(
      CameraUpdate.newCenterPosition(widget.center, zoomLevel: 17),
      animation: const CameraAnimation(400),
    );

    // 로딩 해제
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/put-location'),
            pageBuilder: (_, __, ___) => const PutLocationScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: common_appbar(context, title: '결과 화면'),
        body: Stack(
          children: [
            KakaoMap(
              option: KakaoMapOption(
                position: widget.center,
                zoomLevel: 17,
              ),
              onMapReady: _onMapReady,
            ),
            if (_loading)
              Container(
                color: Colors.white.withOpacity(0.6),
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (!_loading)
              FairLocationBottomSheet(
                fairLocationResponse: widget.fairLocationResponse,
              ),
          ],
        ),
      ),
    );
  }
}
