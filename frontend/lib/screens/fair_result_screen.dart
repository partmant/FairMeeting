import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:fair_front/models/place_autocomplete_response.dart';
import 'package:fair_front/models/fair_location_response.dart';
import 'package:fair_front/widgets/common_appbar.dart';
import 'package:fair_front/widgets/fair_result/category_bar.dart';
import 'package:fair_front/widgets/fair_result/result_bottom_sheet.dart';
import 'package:fair_front/widgets/loading_dialog.dart';
import 'package:fair_front/services/edit_result_service.dart';
import 'package:provider/provider.dart';
import '../controllers/lod_poi_controller.dart';
import '../controllers/poi_controller.dart';
import '../controllers/map_controller.dart';
import '../models/edit_result_response.dart';
import '../models/fair_location_route_detail.dart';
import '../models/location_dto.dart';
import 'edit_result_screen.dart';

class FairResultMapScreen extends StatefulWidget {
  final LatLng initialCenter;
  final FairLocationResponse initialResponse;

  const FairResultMapScreen({
    Key? key,
    required this.initialCenter,
    required this.initialResponse,
  }) : super(key: key);

  @override
  _FairResultMapScreenState createState() => _FairResultMapScreenState();
}

class _FairResultMapScreenState extends State<FairResultMapScreen> {
  late final PoiController _poiController;
  late final MapController _mapController;
  late final LodPoiController _lodPoiController;
  late LatLng _currentCenter;
  late FairLocationResponse _currentResponse;

  KakaoMapController? _mapCtrl;
  LatLng? _lastDrawnCenter;

  @override
  void initState() {
    super.initState();
    _poiController = PoiController();
    _mapController = MapController(poiController: _poiController);
    _lodPoiController = LodPoiController(_mapController);
    _currentCenter = widget.initialCenter;
    _currentResponse = widget.initialResponse;
  }

  Future<void> _initializeMap(KakaoMapController mapCtrl) async {
    _mapCtrl = mapCtrl;
    showLoadingDialog(context);
    try {
      _mapController.mapController = mapCtrl;
      await _poiController.initStyle(mapCtrl);
      await _poiController.initMidpointStyle(mapCtrl);
      await _lodPoiController.initWithMapController(mapCtrl);
      await _drawAndPosition(_currentCenter, _currentResponse, animate: false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지도를 불러오는 중 오류가 발생했습니다.')));
    } finally {
      hideLoadingDialog(context);
    }
  }

  Future<void> _drawAndPosition(
    LatLng center,
    FairLocationResponse response, {
    required bool animate,
  }) async {
    final mapCtrl = _mapCtrl!;
    await _poiController.clearMarkers();
    final origins =
        response.routes.map((detail) {
          final st = detail.fromStation;
          return PlaceAutoCompleteResponse(
            placeName: st.name,
            roadAddress: '',
            latitude: st.latitude,
            longitude: st.longitude,
          );
        }).toList();
    await _poiController.showMarkers(mapCtrl, origins);
    await _poiController.showMidpoint(
      mapCtrl,
      center.latitude,
      center.longitude,
    );
    if (_lastDrawnCenter == null || _lastDrawnCenter != center) {
      await mapCtrl.moveCamera(
        CameraUpdate.newCenterPosition(center, zoomLevel: 17),
        animation:
            animate ? const CameraAnimation(400) : const CameraAnimation(0),
      );
      _lastDrawnCenter = center;
    }
  }

  Future<void> _handleEdit() async {
    final newCenter = await Navigator.of(context).push<LatLng>(
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => EditResultScreen(initialCenter: _currentCenter),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    if (newCenter == null) return;

    showLoadingDialog(context);
    _lodPoiController.clearCache();

    final stationDtos =
        _currentResponse.routes.map((d) => d.fromStation).toList();

    EditResultResponse editResult;
    try {
      editResult = await EditResultService.fetchEditResult(
        mx: newCenter.longitude,
        my: newCenter.latitude,
        startStations: stationDtos,
      );
    } catch (e) {
      hideLoadingDialog(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('중간지점 수정 후 경로 요청에 실패했습니다.')));
      return;
    }
    hideLoadingDialog(context);

    final midDto = LocationDto(
      latitude: editResult.midpoint.latitude,
      longitude: editResult.midpoint.longitude,
      name: editResult.midpoint.name,
    );
    final details = List<FairLocationRouteDetail>.generate(
      editResult.routes.length,
      (i) => FairLocationRouteDetail(
        fromStation: stationDtos[i],
        route: editResult.routes[i],
      ),
    );
    final updatedResponse = FairLocationResponse(
      midpointStation: midDto,
      routes: details,
    );

    setState(() {
      _currentCenter = LatLng(
        updatedResponse.midpointStation.latitude,
        updatedResponse.midpointStation.longitude,
      );
      _currentResponse = updatedResponse;
    });
    await _drawAndPosition(_currentCenter, _currentResponse, animate: true);

    Provider.of<MapController>(context, listen: false).saveLastResult(
      coordinates: [
        ...updatedResponse.routes.map(
          (d) => LatLng(d.fromStation.latitude, d.fromStation.longitude),
        ),
        _currentCenter,
      ],
      center: _currentCenter,
      response: updatedResponse,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LodPoiController>.value(
      value: _lodPoiController,
      child: Scaffold(
        appBar: common_appbar(
          context,
          title: '결과 화면',
          extraActions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: _handleEdit,
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              KakaoMap(
                option: KakaoMapOption(position: _currentCenter, zoomLevel: 17),
                onMapReady: _initializeMap,
              ),
              Positioned(
                top: 4,
                left: 16,
                right: 16,
                child: Consumer<LodPoiController>(
                  builder:
                      (ctx, lodCtrl, _) => CategoryBar(
                        state: lodCtrl.categoryState,
                        onTap: (code, nowOn) async {
                          final isFirst = !lodCtrl.hasCache(code);
                          if (isFirst) showLoadingDialog(context);
                          await lodCtrl.toggleCategory(code, _currentCenter);
                          if (isFirst) hideLoadingDialog(context);
                        },
                      ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FairLocationBottomSheet(
                  fairLocationResponse: _currentResponse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
