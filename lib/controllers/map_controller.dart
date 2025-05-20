import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../services/address_service.dart';
import '../models/place_autocomplete_response.dart';

class MapController with ChangeNotifier {
  KakaoMapController? mapController;

  final List<PlaceAutoCompleteResponse> selectedAddresses = [];
  final List<Poi> _pois = [];
  List<Poi> get pois => List.unmodifiable(_pois);

  int? selectedAddressIndex;

  static const LatLng _defaultCenter = LatLng(37.5651, 126.9784);
  LatLng currentCenter = _defaultCenter;

  static const int _defaultZoom = 17;
  int currentZoom = _defaultZoom;

  bool _hasInitialized = false;

  final KImage _poiIcon = KImage.fromAsset('assets/mapMarker.png', 35, 35);
  late PoiStyle _poiStyle;

  // 마지막 결과 저장용 필드
  List<LatLng>? _lastCoordinates;
  LatLng?      _lastCenter;

  bool get hasLastResult     => _lastCoordinates != null && _lastCenter != null;
  List<LatLng> get lastCoordinates => _lastCoordinates!;
  LatLng       get lastCenter      => _lastCenter!;

  void saveLastResult({
    required List<LatLng> coordinates,
    required LatLng       center,
  }) {
    _lastCoordinates = coordinates;
    _lastCenter      = center;
  }

  StreamSubscription<Position>? _positionSub;

  void updateCameraPosition(LatLng center, int zoomLevel) {
    currentCenter = center;
    currentZoom   = zoomLevel;
    notifyListeners();
  }

  Future<void> onMapCreated(KakaoMapController controller) async {
    mapController = controller;

    // POI 스타일 초기화
    _poiStyle = PoiStyle(icon: _poiIcon);
    final styleId = await mapController!
        .labelLayer
        .manager
        .addPoiStyle(_poiStyle);
    _poiStyle = PoiStyle(id: styleId, icon: _poiIcon);

    // 최초 진입 시 위치 설정
    if (!_hasInitialized) {
      await _setCurrentLocationAsCenter();
      _hasInitialized = true;
    }

    // 카메라 복원
    await moveCameraTo(
      currentCenter.latitude,
      currentCenter.longitude,
      zoomLevel: currentZoom,
    );

    // POI 복원
    await showMarkersForSelectedLocations();

    // 위치 스트림 구독 (10m 이동 시마다 currentCenter 갱신)
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      currentCenter = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> showMarkersForSelectedLocations() async {
    if (mapController == null) return;
    for (final poi in _pois) {
      await poi.remove();
    }
    _pois.clear();
    for (final addr in selectedAddresses) {
      final poi = await _createPoi(addr.latitude, addr.longitude);
      if (poi != null) _pois.add(poi);
    }
    notifyListeners();
  }

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
      animation: const CameraAnimation(400),
    );
  }

  Future<void> handleMapClick(LatLng pos) async {
    await moveCameraTo(pos.latitude, pos.longitude);
    await moveSelectedMarker(pos);
  }

  Future<Poi?> _createPoi(double lat, double lng) async {
    try {
      final poi = await mapController!.labelLayer.addPoi(
        LatLng(lat, lng),
        style: _poiStyle,
      );
      poi.onClick = () {
        final idx = _pois.indexOf(poi);
        if (idx != -1) selectAddress(idx);
      };
      return poi;
    } catch (e) {
      debugPrint('❗ POI 생성 실패: $e');
      return null;
    }
  }

  void selectAddress(int index) {
    if (index < 0 || index >= selectedAddresses.length) return;
    selectedAddressIndex = index;
    notifyListeners();
  }

  Future<void> addLocation(PlaceAutoCompleteResponse address) async {
    selectedAddresses.add(address);
    selectedAddressIndex = selectedAddresses.length - 1;
    final poi = await _createPoi(address.latitude, address.longitude);
    if (poi != null) {
      _pois.add(poi);
      await moveCameraTo(
        address.latitude,
        address.longitude,
        zoomLevel: currentZoom,
      );
      notifyListeners();
    }
  }

  Future<void> moveSelectedMarker(LatLng newLatLng) async {
    if (selectedAddressIndex == null) return;
    final idx = selectedAddressIndex!;
    if (idx < 0 || idx >= selectedAddresses.length) return;
    final poi = _pois[idx];
    await poi.move(newLatLng);
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

  Future<void> deleteAddressAt(int index) async {
    if (index < 0 || index >= selectedAddresses.length) return;
    await _pois[index].remove();
    _pois.removeAt(index);
    selectedAddresses.removeAt(index);
    if (selectedAddressIndex == index) {
      selectedAddressIndex = null;
    } else if (selectedAddressIndex != null &&
        selectedAddressIndex! > index) {
      selectedAddressIndex = selectedAddressIndex! - 1;
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    // POI·주소 모두 삭제
    for (final poi in _pois) {
      await poi.remove();
    }
    _pois.clear();
    selectedAddresses.clear();
    selectedAddressIndex = null;

    // 마지막 결과 초기화, forward 버튼 숨기기
    _lastCoordinates = null;
    _lastCenter      = null;

    // 최신 currentCenter 로 카메라 이동
    await moveCameraTo(
      currentCenter.latitude,
      currentCenter.longitude,
      zoomLevel: currentZoom,
    );
    notifyListeners();
  }

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
