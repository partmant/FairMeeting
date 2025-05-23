import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../models/place_autocomplete_response.dart';

/// POI(마커) 관리 전담 컨트롤러
class PoiController with ChangeNotifier {
  final List<Poi> _pois = [];
  late PoiStyle _poiStyle;
  final KImage _poiIcon = KImage.fromAsset('assets/markers/map_marker.png', 35, 35);

  /// 클릭된 마커 인덱스를 MapController에 전달할 콜백
  void Function(int index)? onMarkerSelected;

  /// 초기 설정: 스타일 등록
  Future<void> initStyle(KakaoMapController mapController) async {
    _poiStyle = PoiStyle(icon: _poiIcon);
    final styleId = await mapController.labelLayer.manager.addPoiStyle(_poiStyle);
    _poiStyle = PoiStyle(id: styleId, icon: _poiIcon);
  }

  /// 선택된 주소에 맞춰 마커 보여주기
  Future<void> showMarkers(
      KakaoMapController mapController,
      List<PlaceAutoCompleteResponse> addresses,
      ) async {
    await clearMarkers();
    for (final addr in addresses) {
      final poi = await _createPoi(mapController, addr.latitude, addr.longitude);
      if (poi != null) _pois.add(poi);
    }
    notifyListeners();
  }

  Future<Poi?> _createPoi(
      KakaoMapController mapController,
      double lat,
      double lng,
      ) async {
    try {
      final poi = await mapController.labelLayer.addPoi(
        LatLng(lat, lng),
        style: _poiStyle,
      );
      poi.onClick = () {
        final idx = _pois.indexOf(poi);
        if (idx != -1) selectMarker(idx);
      };
      return poi;
    } catch (e) {
      debugPrint('❗ POI 생성 실패: $e');
      return null;
    }
  }

  /// 개별 마커 선택 콜백 (외부로 노티)
  void selectMarker(int index) {
    onMarkerSelected?.call(index);
    notifyListeners();
  }

  /// 선택된 마커 이동
  Future<void> moveMarker(int index, LatLng newPos) async {
    if (index < 0 || index >= _pois.length) return;
    await _pois[index].move(newPos);
    notifyListeners();
  }

  /// 특정 마커 제거
  Future<void> removeMarker(int index) async {
    if (index < 0 || index >= _pois.length) return;
    await _pois[index].remove();
    _pois.removeAt(index);
    notifyListeners();
  }

  /// 모든 마커 제거
  Future<void> clearMarkers() async {
    for (final poi in _pois) {
      await poi.remove();
    }
    _pois.clear();
  }

  List<Poi> get pois => List.unmodifiable(_pois);
}
