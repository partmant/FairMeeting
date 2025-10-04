import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../models/fair_location_response.dart';
import '../services/address_service.dart';
import '../models/place_autocomplete_response.dart';
import 'poi_controller.dart';

class MapController with ChangeNotifier {
  KakaoMapController? mapController;

  final List<PlaceAutoCompleteResponse> selectedAddresses = [];
  int? selectedAddressIndex;

  static const LatLng _defaultCenter = LatLng(37.5651, 126.9784);
  LatLng currentCenter = _defaultCenter;

  static const int _defaultZoom = 17;
  int currentZoom = _defaultZoom;

  bool _hasInitialized = false;
  StreamSubscription<Position>? _positionSub;

  List<LatLng>? _lastCoordinates;
  LatLng? _lastCenter;
  FairLocationResponse? _lastResponse;

  bool get hasLastResult =>
      _lastCoordinates != null && _lastCenter != null && _lastResponse != null;
  List<LatLng> get lastCoordinates => _lastCoordinates!;
  LatLng get lastCenter => _lastCenter!;
  FairLocationResponse get lastFairLocationResponse => _lastResponse!;

  /// POI(마커) 전담 컨트롤러
  final PoiController poiController;

  MapController({required this.poiController}) {
    // POI 클릭 이벤트 처리
    poiController.onMarkerSelected = (idx) {
      selectedAddressIndex = idx;
      notifyListeners();
    };
  }

  /// 마지막 결과 저장
  void saveLastResult({
    required List<LatLng> coordinates,
    required LatLng center,
    required FairLocationResponse response,
  }) {
    _lastCoordinates = coordinates;
    _lastCenter = center;
    _lastResponse = response;
    notifyListeners();
  }

  /// 카메라 위치 정보 업데이트
  void updateCameraPosition(LatLng center, int zoomLevel) {
    currentCenter = center;
    currentZoom = zoomLevel;
    notifyListeners();
  }

  /// 지도 생성 시 초기화
  Future<void> onMapCreated(KakaoMapController controller) async {
    mapController = controller;

    // POI 스타일 초기화 및 기존 마커 표시
    await poiController.initStyle(controller);
    await poiController.showMarkers(controller, selectedAddresses);

    if (!_hasInitialized) {
      await _setCurrentLocationAsCenter();
      _hasInitialized = true;
    }

    await moveCameraTo(
      currentCenter.latitude,
      currentCenter.longitude,
      zoomLevel: currentZoom,
    );

    // 사용자 위치 스트림 시작
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      currentCenter = LatLng(pos.latitude, pos.longitude);
    });
  }

  /// 선택된 주소에 따른 마커(POI) 갱신
  Future<void> showMarkersForSelectedLocations() async {
    if (mapController == null) return;
    await poiController.showMarkers(mapController!, selectedAddresses);
    notifyListeners();
  }

  /// 카메라 이동
  Future<void> moveCameraTo(
      double lat,
      double lng, {
        int? zoomLevel,
      }) async {
    if (mapController == null) return;
    currentCenter = LatLng(lat, lng);
    if (zoomLevel != null) currentZoom = zoomLevel;
    await mapController!.moveCamera(
      CameraUpdate.newCenterPosition(
        currentCenter,
        zoomLevel: zoomLevel,
      ),
      animation: const CameraAnimation(300),
    );
  }

  /// 지도 클릭 핸들링
  Future<void> handleMapClick(LatLng pos) async {
    await moveCameraTo(pos.latitude, pos.longitude);
    if (selectedAddressIndex != null) {
      await moveSelectedMarker(pos);
    }
  }

  /// 주소 추가
  Future<void> addLocation(PlaceAutoCompleteResponse address) async {
    selectedAddresses.add(address);
    selectedAddressIndex = selectedAddresses.length - 1;
    await poiController.showMarkers(mapController!, selectedAddresses);
    await moveCameraTo(address.latitude, address.longitude);
    notifyListeners();
  }

  /// 선택된 마커 이동 후 주소명 갱신
  Future<void> moveSelectedMarker(LatLng newLatLng) async {
    if (selectedAddressIndex == null) return;
    final idx = selectedAddressIndex!;
    await poiController.moveMarker(idx, newLatLng);
    try {
      final geo = await AddressService.fetchAddressName(
        newLatLng.latitude,
        newLatLng.longitude,
      );
      final old = selectedAddresses[idx];
      selectedAddresses[idx] = PlaceAutoCompleteResponse(
        placeName: geo.name,
        roadAddress: old.roadAddress,
        latitude: newLatLng.latitude,
        longitude: newLatLng.longitude,
      );
    } catch (e) {
      debugPrint('❗ 주소명 요청 중 예외 발생: $e');
    }
    notifyListeners();
  }

  /// 주소 삭제
  Future<void> deleteAddressAt(int index) async {
    if (index < 0 || index >= selectedAddresses.length) return;
    await poiController.removeMarker(index);
    selectedAddresses.removeAt(index);
    if (selectedAddressIndex == index) {
      selectedAddressIndex = null;
    } else if (selectedAddressIndex != null &&
        selectedAddressIndex! > index) {
      selectedAddressIndex = selectedAddressIndex! - 1;
    }
    notifyListeners();
  }

  /// 모두 초기화
  Future<void> clearAll() async {
    await poiController.clearMarkers();
    selectedAddresses.clear();
    selectedAddressIndex = null;
    _lastCoordinates = null;
    _lastCenter = null;
    _lastResponse = null;

    await _setCurrentLocationAsCenter();
    await moveCameraTo(
      currentCenter.latitude,
      currentCenter.longitude,
      zoomLevel: _defaultZoom,
    );
    notifyListeners();
  }

  /// 현재 위치를 기본 중심으로 설정
  Future<void> _setCurrentLocationAsCenter() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        currentCenter = LatLng(pos.latitude, pos.longitude);
      } else {
        currentCenter = _defaultCenter;
      }
    } catch (_) {
      currentCenter = _defaultCenter;
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
