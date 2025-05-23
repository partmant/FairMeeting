import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:fair_front/models/fair_location_response.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/category_bar.dart';
import 'package:fair_front/widgets/result_bottom_sheet.dart';
import 'package:fair_front/widgets/loading_dialog.dart';
import '../controllers/lod_poi_controller.dart';
import '../controllers/map_controller.dart';
import '../controllers/poi_controller.dart';
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
  late final LodPoiController _lodPoiController;

  @override
  void initState() {
    super.initState();
    _poiController = PoiController();
    _controller = MapController(poiController: _poiController);
    _lodPoiController = LodPoiController(_controller);
  }

  Future<void> _onMapReady(KakaoMapController mapCtrl) async {
    showLoadingDialog(context);

    await _lodPoiController.initWithMapController(mapCtrl);

    _controller.mapController = mapCtrl;

    await _poiController.initStyle(mapCtrl);

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

    // 중간지점 마커 표시
    final mid = widget.fairLocationResponse.midpointStation;
    final midMarker = PlaceAutoCompleteResponse(
      placeName: mid.name,
      roadAddress: '',
      latitude: mid.latitude,
      longitude: mid.longitude,
    );
    await _poiController.showMarkers(mapCtrl, [...origins, midMarker]);

    // 결과 화면 중심 이동
    await mapCtrl.moveCamera(
      CameraUpdate.newCenterPosition(widget.center, zoomLevel: 17),
      animation: const CameraAnimation(400),
    );
    hideLoadingDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LodPoiController>.value(
      value: _lodPoiController,
      child: WillPopScope(
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
          body: Column(
            children: [
              // 상단 카테고리 바
              Consumer<LodPoiController>(
                builder: (_, lodCtrl, __) => CategoryBar(
                  state: lodCtrl.categoryState,
                  onTap: (code, nowOn) async {
                    final isFirst = !lodCtrl.hasCache(code);
                    if (isFirst) showLoadingDialog(context);
                    await lodCtrl.toggleCategory(code, widget.center);
                    if (isFirst) hideLoadingDialog(context);
                  },
                ),
              ),
              // 지도 및 결과 바텀시트
              Expanded(
                child: Stack(
                  children: [
                    KakaoMap(
                      option: KakaoMapOption(
                        position: widget.center,
                        zoomLevel: 17,
                      ),
                      onMapReady: _onMapReady,
                    ),
                    // 바텀 시트
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FairLocationBottomSheet(
                        fairLocationResponse: widget.fairLocationResponse,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
