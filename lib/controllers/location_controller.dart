import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../services/address_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationController with ChangeNotifier {
  KakaoMapController? mapController;

  final List<Map<String, dynamic>> selectedAddresses = [];
  final Set<Marker> markers = {};
  int? selectedAddressIndex;
  LatLng currentCenter = LatLng(37.5651, 126.9784); // 기본 지도 중심

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
      print("✅ 지도에 ${markers.length}개의 마커 재추가 완료");
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
    print("📌 사용자 중심 위치 저장만: $currentCenter");
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
        currentCenter = LatLng(37.5651, 126.9784); // ✅ 명시적 기본 위치 설정
      }
    } catch (e) {
      print("❗ 위치 가져오기 실패: $e");
      currentCenter = LatLng(37.5651, 126.9784); // ✅ 예외 발생 시도 기본 위치 설정
    }
  }

  // 새로운 주소 및 마커 표시
  void addAddress(Map<String, dynamic> addressData) {
    final markerId = UniqueKey().toString();
    final lat = double.parse(addressData['lat'].toString());
    final lng = double.parse(addressData['lng'].toString());
    final position = LatLng(lat, lng);

    final marker = Marker(
      markerId: markerId,
      latLng: position,
      width: 30,
      height: 44,
      offsetX: 15,
      offsetY: 44,
    );

    addressData['marker'] = marker;
    selectedAddresses.add(addressData);
    selectedAddressIndex = selectedAddresses.length - 1;
    markers.add(marker);

    mapController?.addMarker(markers: markers.toList());
    notifyListeners();
  }

  // 선택된 주소의 마커 이동 및 주소 수정
  Future<void> moveSelectedMarker(LatLng newLatLng) async {
    if (selectedAddressIndex != null &&
        selectedAddressIndex! < selectedAddresses.length) {
      final address = selectedAddresses[selectedAddressIndex!];
      final Marker? oldMarker = address['marker'];

      if (oldMarker != null) {
        markers.remove(oldMarker);

        final newMarker = Marker(
          markerId: oldMarker.markerId,
          latLng: newLatLng,
          width: oldMarker.width,
          height: oldMarker.height,
          offsetX: oldMarker.offsetX,
          offsetY: oldMarker.offsetY,
        );

        address['marker'] = newMarker;
        address['lat'] = newLatLng.latitude;
        address['lng'] = newLatLng.longitude;
        markers.add(newMarker);

        try {
          final name = await AddressService.fetchAddressName(
            newLatLng.latitude,
            newLatLng.longitude,
          );
          address['name'] = name;
        } catch (e) {
          print("❗ 주소명 요청 중 예외 발생: $e");
        }

        mapController?.clearMarker();
        mapController?.addMarker(markers: markers.toList());
        notifyListeners();
      }
    }
  }

  // 주소와 마커 삭제
  void deleteAddressAt(int index) {
    if (index >= 0 && index < selectedAddresses.length) {
      final marker = selectedAddresses[index]['marker'];
      if (marker != null) {
        markers.remove(marker);
      }

      selectedAddresses.removeAt(index);

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
  void clearAll() async {
    selectedAddresses.clear();
    markers.clear();
    selectedAddressIndex = null;
    mapController?.clearMarker();

    // 위치 초기화 플래그
    _hasInitialized = false;

    // 사용자 위치로 중심 초기화
    await setCurrentLocationAsCenter();

    // 지도 중심 이동
    await moveMapCenter(currentCenter.latitude, currentCenter.longitude);

    notifyListeners();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
