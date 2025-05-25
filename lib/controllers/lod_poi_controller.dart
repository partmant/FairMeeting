import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../controllers/map_controller.dart';
import '../models/category_response.dart';
import '../services/category_service.dart';

class LodPoiController with ChangeNotifier {
  final MapController _mapCtrl;
  LodLabelController? _lodController;

  LodPoiController(this._mapCtrl);

  Future<void> initWithMapController(KakaoMapController mapCtrl) async {
    // 1) MapController에도 연결
    _mapCtrl.mapController = mapCtrl;

    // 2) 레이어가 아직 없으면 생성, 있으면 기존 컨트롤러 사용
    try {
      // 무조건 레이어를 생성하여 초기화 보장
      _lodController = await mapCtrl.addLodLabelLayer(
        LodLabelController.defaultId,
        radius: LodLabelController.defaultRadius,
      );
    } on DuplicatedOverlayException {
      // 이미 생성된 레이어가 있다면, 기본 레이어 컨트롤러를 가져오기
      _lodController = mapCtrl.lodLabelLayer;

      // 내부 초기화가 지연될 수 있으므로 약간의 대기 추가
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (_lodController == null) {
      throw StateError('LodLabelLayer 초기화에 실패했습니다.');
    }
  }

  String? activeCategory;
  final Map<String, bool> categoryState = {
    'CT1': false,
    'FD6': false,
    'CE7': false,
  };

  static const Map<String, String> _iconPaths = {
    'CT1': 'assets/markers/cultural_facilities_marker.png',
    'FD6': 'assets/markers/restaurant_marker.png',
    'CE7': 'assets/markers/cafe_marker.png',
  };

  final Map<String, List<CategoryResponse>> _responseCache = {};
  final Map<String, List<LodPoi>> _poiCache = {};

  bool hasCache(String code) => _responseCache.containsKey(code);

  Future<void> toggleCategory(String code, LatLng center) async {
    if (_lodController == null) {
      throw StateError('initWithMapController()를 먼저 호출해주세요.');
    }

    final lod = _lodController!;

    // 이미 활성화된 카테고리이면 숨기고 리턴
    if (activeCategory == code) {
      await _hideCategory(code);
      categoryState[code] = false;
      activeCategory = null;
      notifyListeners();
      return;
    }

    // 전에 켰던 카테고리 숨기기
    if (activeCategory != null) {
      await _hideCategory(activeCategory!);
      categoryState[activeCategory!] = false;
    }

    // 새 카테고리 활성화
    categoryState[code] = true;
    activeCategory = code;

    // 캐시에 없으면 API 호출 & POI 생성
    if (!_responseCache.containsKey(code)) {
      final lon = center.longitude;
      final lat = center.latitude;

      final places = await CategoryService.fetchByCategory(
        categoryCode: code,
        lon: lon,
        lat: lat,
      );
      _responseCache[code] = places;

      // 스타일은 addPoiStyle로 등록
      final icon = KImage.fromAsset(_iconPaths[code]!, 25, 30);
      final baseStyle = PoiStyle(icon: icon);
      final styleId = await lod.manager.addPoiStyle(baseStyle);
      final style = PoiStyle(id: styleId, icon: icon);

      final List<LodPoi> pois = [];
      for (final place in places) {
        final poi = await lod.addLodPoi(
          LatLng(double.parse(place.y), double.parse(place.x)),
          style: style,
          id: place.placeUrl,
          text: place.placeName,
          rank: 0,
          onClick: () async {
            final uri = Uri.parse(place.placeUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          visible: true,
        );
        pois.add(poi);
      }
      _poiCache[code] = pois;
    } else {
      // 캐시된 LodPoi 재노출
      for (final poi in _poiCache[code]!) {
        await poi.show();
      }
    }

    notifyListeners();
  }

  Future<void> _hideCategory(String code) async {
    if (_poiCache.containsKey(code)) {
      for (final poi in _poiCache[code]!) {
        await poi.hide();
      }
    }
  }
}
