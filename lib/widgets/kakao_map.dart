import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../controllers/map_controller.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({Key? key}) : super(key: key);

  @override
  State<KakaoMapScreen> createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late MapController _mapCtrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapCtrl = Provider.of<MapController>(context, listen: false);
  }

  Future<void> _onMapReady(KakaoMapController controller) async {
    await _mapCtrl.onMapCreated(controller);
  }

  Future<void> _onCameraMoveEnd(
      CameraPosition position, GestureType gestureType) async {
    // position.position: LatLng
    // position.zoomLevel: int
    _mapCtrl.updateCameraPosition(
      position.position,
      position.zoomLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapController>(
      builder: (_, ctrl, __) {
        return KakaoMap(
          option: KakaoMapOption(
            position: ctrl.currentCenter,
            zoomLevel: ctrl.currentZoom,
          ),
          onMapReady: _onMapReady,
          onCameraMoveEnd: _onCameraMoveEnd,
          onMapClick: (_, pos) => _mapCtrl.handleMapClick(pos),
          onMapError: (e) => debugPrint('지도 로딩 실패: $e'),
        );
      },
    );
  }
}
