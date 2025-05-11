import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart';

import '../services/address_service.dart';
import '../models/place_autocomplete_response.dart';
import '../models/geocoding_response.dart';

class LocationController with ChangeNotifier {
  KakaoMapController? mapController;

  final List<PlaceAutoCompleteResponse> selectedAddresses = [];
  final Set<Marker> markers = {};
  int? selectedAddressIndex;
  LatLng currentCenter = LatLng(37.5651, 126.9784); // 디폴트 지도 중심

  bool _hasInitialized = false; // 최초 진입 여부 플래그

  // 지도 초기화 함수
  void onMapCreated(KakaoMapController controller) async {
    mapController = controller;

    if (!_hasInitialized) {
      await setCurrentLocationAsCenter();
      _hasInitialized = true;
    }

    await moveMapCenter(currentCenter.latitude, currentCenter.longitude); // 지도 중심 이동

    if (markers.isNotEmpty) {
      mapController?.addMarker(markers: markers.toList());
      print("✅ 지도에 \${markers.length}개의 마커 재추가 완료");
    } else {
      print("ℹ️ 현재 markers는 비어있음");
    }
  }

  // 좌표로 지도 중심 이동 및 상태 반영
  Future<void> moveMapCenter(double lat, double lng) async {
    currentCenter = LatLng(lat, lng);
    await mapController?.panTo(currentCenter);
    notifyListeners();
  }

  // 지도 중심만 설정
  void setMapCenter(double lat, double lng) {
    currentCenter = LatLng(lat, lng);
    print("📌 사용자 중심 위치 저장만: \$currentCenter");
  }

  // 사용자 위치를 지도 중심으로 설정
  Future<void> setCurrentLocationAsCenter() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      // 권한 있으면 사용자 위치로 지도 중심 설정
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        currentCenter = LatLng(position.latitude, position.longitude);
      }
      // 없으면 기본(서울시청)으로 설정
      else {
        print("📛 위치 권한이 거부되었습니다.");
        currentCenter = LatLng(37.5651, 126.9784); // 명시적 기본 위치 설정
      }
    } catch (e) {
      print("❗ 위치 가져오기 실패: \$e");
      currentCenter = LatLng(37.5651, 126.9784); // 예외 발생 시 기본 위치 설정
    }
  }

  // 새로운 주소 및 마커 표시
  void addAddress(PlaceAutoCompleteResponse address) {
    final markerId = UniqueKey().toString();
    final position = LatLng(address.latitude, address.longitude);

    final marker = Marker(
      markerId: markerId,
      latLng: position,
      width: 30,
      height: 44,
      offsetX: 15,
      offsetY: 44,
    );

    selectedAddresses.add(address);
    selectedAddressIndex = selectedAddresses.length - 1;
    markers.add(marker);

    mapController?.addMarker(markers: markers.toList());
    notifyListeners();
  }

  // 선택된 주소의 마커 이동 및 주소 수정
  Future<void> moveSelectedMarker(LatLng newLatLng) async {
    if (selectedAddressIndex != null && selectedAddressIndex! < selectedAddresses.length) {
      final oldAddress = selectedAddresses[selectedAddressIndex!];

      // 기존 마커 찾기
      final oldMarker = markers.firstWhere(
            (m) => m.latLng.latitude == oldAddress.latitude && m.latLng.longitude == oldAddress.longitude,
      );

      // 기존 마커 제거
      markers.remove(oldMarker);

      // 새 마커 생성
      final newMarker = Marker(
        markerId: oldMarker.markerId,
        latLng: newLatLng,
        width: oldMarker.width,
        height: oldMarker.height,
        offsetX: oldMarker.offsetX,
        offsetY: oldMarker.offsetY,
      );

      try {
        // 새 위치의 주소명 요청
        final GeocodingResponse response = await AddressService.fetchAddressName(
          newLatLng.latitude,
          newLatLng.longitude,
        );
        final updatedAddress = PlaceAutoCompleteResponse(
          placeName: response.name,
          roadAddress: oldAddress.roadAddress, // 기존 도로명 유지
          latitude: newLatLng.latitude,
          longitude: newLatLng.longitude,
        );

        // 리스트, 마커 업데이트
        selectedAddresses[selectedAddressIndex!] = updatedAddress;
        markers.add(newMarker);

        mapController?.clearMarker();
        mapController?.addMarker(markers: markers.toList());
        notifyListeners();
      } catch (e) {
        print("❗ 주소명 요청 중 예외 발생: \$e");
      }
    }
  }

  // 주소와 마커 삭제
  void deleteAddressAt(int index) {
    if (index >= 0 && index < selectedAddresses.length) {
      final address = selectedAddresses[index];

      // 해당 주소의 마커 찾기
      final marker = markers.firstWhere(
            (m) => m.latLng.latitude == address.latitude && m.latLng.longitude == address.longitude,
      );

      // 마커 제거 및 리스트 갱신
      markers.remove(marker);
      selectedAddresses.removeAt(index);

      // 선택 인덱스 보정
      if (selectedAddressIndex == index) {
        selectedAddressIndex = null;
      } else if (selectedAddressIndex != null && selectedAddressIndex! > index) {
        selectedAddressIndex = selectedAddressIndex! - 1;
      }

      mapController?.clearMarker();
      mapController?.addMarker(markers: markers.toList());
      notifyListeners();
    }
  }

  // 화면 전체 초기화 및 지도 중심 재설정
  Future<void> clearAll() async {
    selectedAddresses.clear();
    markers.clear();
    selectedAddressIndex = null;
    mapController?.clearMarker();

    _hasInitialized = false;
    await setCurrentLocationAsCenter();
    await moveMapCenter(currentCenter.latitude, currentCenter.longitude);
    notifyListeners();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
