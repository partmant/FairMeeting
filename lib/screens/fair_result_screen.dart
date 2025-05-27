import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:fair_front/models/fair_location_response.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/fair_result/category_bar.dart';
import 'package:fair_front/widgets/fair_result/result_bottom_sheet.dart';
import 'package:fair_front/widgets/loading_dialog.dart';
import '../controllers/lod_poi_controller.dart';
import '../controllers/map_controller.dart';
import '../controllers/poi_controller.dart';

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

    // POI 스타일 초기화 (출발지 마커 + 중간지점 마커)
    await _poiController.initStyle(mapCtrl);
    await _poiController.initMidpointStyle(mapCtrl);

    // 출발지 마커
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

    // 중간지점 마커
    final mid = widget.fairLocationResponse.midpointStation;
    await _poiController.showMidpoint(mapCtrl, mid.latitude, mid.longitude);

    // 카메라 이동
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
          Navigator.of(context).pop();
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
              Consumer<LodPoiController>(
                builder: (_, lodCtrl, __) => Positioned(
                  top: 4,
                  left: 16,
                  right: 16,
                  child: CategoryBar(
                    state: lodCtrl.categoryState,
                    onTap: (code, nowOn) async {
                      final isFirst = !lodCtrl.hasCache(code);
                      if (isFirst) showLoadingDialog(context);
                      await lodCtrl.toggleCategory(code, widget.center);
                      if (isFirst) hideLoadingDialog(context);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FairLocationBottomSheet(
                  fairLocationResponse: widget.fairLocationResponse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
